import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstitucionesScreen extends StatefulWidget {
  const InstitucionesScreen({Key? key}) : super(key: key);

  @override
  _InstitucionesScreenState createState() => _InstitucionesScreenState();
}

class _InstitucionesScreenState extends State<InstitucionesScreen> {
  String busqueda = '';

  Future<void> agregarInstitucion(BuildContext context) async {
    String nombre = '';
    String domicilio = '';
    String telefono = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Institución'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => nombre = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Domicilio'),
                onChanged: (value) => domicilio = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) => telefono = value,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                agregarInstitucionFirestore(nombre, domicilio, telefono);
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> agregarInstitucionFirestore(String nombre, String domicilio, String telefono) async {
    await FirebaseFirestore.instance.collection('instituciones').add({
      "nombre": nombre,
      "domicilio": domicilio,
      "telefono": telefono,
    });
  }

  Future<void> gestionarAdministradores(BuildContext context, String institucionId) async {
    String dni = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Administrador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'DNI del Usuario'),
                onChanged: (value) => dni = value,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final userSnapshot = await FirebaseFirestore.instance
                    .collection('Usuarios')
                    .where('DNI', isEqualTo: dni)
                    .limit(1)
                    .get();

                if (userSnapshot.docs.isNotEmpty) {
                  final userDoc = userSnapshot.docs.first;
                  final userData = userDoc.data();

                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content: Text(
                          '¿Deseas hacer administrador a ${userData['Nombre']} ${userData['Apellido']}?',
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sí'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmar == true) {
                    await FirebaseFirestore.instance
                        .collection('Usuarios')
                        .doc(userDoc.id)
                        .update({
                      'id_institucion': institucionId,
                      'rol': 'admin',
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Administrador agregado')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario no encontrado')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarAdministrador(BuildContext context, String userId, String institucionId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar a este administrador?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('Usuarios').doc(userId).update({
        'id_institucion': null,
        'rol': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Administrador eliminado')),
      );

      // Refrescar el estado después de eliminar
      setState(() {});
    }
  }

  Future<void> mostrarAdministradores(BuildContext context, String institucionId) async {
    final administradoresSnapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .where('id_institucion', isEqualTo: institucionId)
        .where('rol', isEqualTo: 'admin')
        .get();

    final administradores = administradoresSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nombreCompleto': "${data['Nombre']} ${data['Apellido']}",
      };
    }).toList();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Administradores'),
          content: administradores.isEmpty
              ? const Text('No hay administradores asignados.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: administradores.map((admin) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(admin['nombreCompleto']!),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            eliminarAdministrador(context, admin['id']!, institucionId);
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Instituciones'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextField(
                decoration: InputDecoration(labelText: 'Buscar institución'),
                onChanged: (value) {
                  setState(() {
                    busqueda = value.toLowerCase();
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                agregarInstitucion(context);
              },
              child: const Text('Agregar'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('instituciones').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final filteredInstituciones = snapshot.data!.docs.where((document) {
                    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] as String;
                    return nombre.toLowerCase().contains(busqueda);
                  }).toList();

                  if (filteredInstituciones.isEmpty) {
                    return const Center(child: Text('No hay instituciones'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Domicilio')),
                        DataColumn(label: Text('Teléfono')),
                        DataColumn(label: Text('Administradores')),
                        DataColumn(label: Text('Editar')),
                        DataColumn(label: Text('Gestión de Admins')),
                      ],
                      rows: filteredInstituciones.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        final String docId = document.id;
                        return DataRow(
                          cells: [
                            DataCell(Text(data['nombre'])),
                            DataCell(Text(data['domicilio'])),
                            DataCell(Text(data['telefono'])),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  mostrarAdministradores(context, docId);
                                },
                              ),
                            ),
                            DataCell(IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Funcionalidad para editar institución
                              },
                            )),
                            DataCell(IconButton(
                              icon: const Icon(Icons.admin_panel_settings),
                              onPressed: () {
                                gestionarAdministradores(context, docId);
                              },
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
