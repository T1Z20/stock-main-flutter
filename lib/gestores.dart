import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GestoresScreen extends StatefulWidget {
  @override
  _GestoresScreenState createState() => _GestoresScreenState();
}

class _GestoresScreenState extends State<GestoresScreen> {
  String busqueda = '';
  String? institucionAdmin;

  @override
  void initState() {
    super.initState();
    _obtenerInstitucionAdmin();
  }

  Future<void> _obtenerInstitucionAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      
      var adminDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(user.uid).get();
      if (adminDoc.exists) {
        setState(() {
          institucionAdmin = (adminDoc.data() as Map<String, dynamic>)['id_institucion'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Gestores'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextField(
                decoration: InputDecoration(labelText: 'Buscar gestor'),
                onChanged: (value) {
                  setState(() {
                    busqueda = value.toLowerCase();
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _agregarGestor(context);
              },
              child: const Text('Agregar Gestor'),
            ),
            Expanded(
              child: institucionAdmin == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('Usuarios')
                          .where('rol', isEqualTo: 'gestor')
                          .where('id_institucion', isEqualTo: institucionAdmin)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error ${snapshot.error}'));
                        }

                        final filteredGestores = snapshot.data!.docs.where((document) {
                          final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          final nombre = data['Nombre'] as String;
                          return nombre.toLowerCase().contains(busqueda.toLowerCase());
                        }).toList();

                        if (filteredGestores.isEmpty) {
                          return Center(child: Text('No hay gestores'));
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Telefono')),
                              DataColumn(label: Text('DNI')),
                              DataColumn(label: Text('Eliminar')),
                            ],
                            rows: filteredGestores.map((DocumentSnapshot document) {
                              final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                              final String docId = document.id;
                              return DataRow(
                                cells: [
                                  DataCell(Text(data['Nombre'])),
                                  DataCell(Text(data['Telefono'])),
                                  DataCell(Text(data['DNI'].toString())),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete_rounded),
                                    onPressed: () {
                                      _eliminarGestor(docId);
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

  Future<void> _agregarGestor(BuildContext context) async {
    String? dni;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Gestor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'DNI'),
                onChanged: (value) => dni = value,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (dni != null && dni!.isNotEmpty) {
                  var usuariosQuery = await FirebaseFirestore.instance.collection('Usuarios')
                      .where('DNI', isEqualTo: dni)
                      .get();

                  if (usuariosQuery.docs.isNotEmpty) {
                    var usuarioDoc = usuariosQuery.docs.first;
                    var usuarioData = usuarioDoc.data() as Map<String, dynamic>;

                    
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmar Agregar Gestor'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Nombre: ${usuarioData['Nombre']}'),
                              Text('Apellido: ${usuarioData['Apellido']}'),
                              Text('DNI: ${usuarioData['DNI']}'),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                if (usuarioData['rol'] != 'gestor') {
                                  await FirebaseFirestore.instance.collection('Usuarios')
                                      .doc(usuarioDoc.id)
                                      .update({
                                    'rol': 'gestor',
                                    'id_institucion': institucionAdmin,
                                  });
                                  Navigator.of(context).pop(); 
                                  Navigator.of(context).pop(); 
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('El usuario ya es un gestor')),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Confirmar'),
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se encontró ningún usuario con ese DNI')),
                    );
                  }
                }
              },
              child: const Text('Buscar'),
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

  Future<void> _eliminarGestor(String docId) async {
    bool confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este gestor?'),
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
    ) ?? false;

    if (confirmed) {
      await FirebaseFirestore.instance.collection('Usuarios').doc(docId).update({
        'rol': FieldValue.delete(),
        
      });
    }
  }
}
