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
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: filteredInstituciones.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        final String docId = document.id;
                        return DataRow(
                          cells: [
                            DataCell(Text(data['nombre'])),
                            DataCell(Text(data['domicilio'])),
                            DataCell(Text(data['telefono'])),
                            DataCell(IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                
                              },
                            )),
                            DataCell(IconButton(
                              icon: const Icon(Icons.admin_panel_settings),
                              onPressed: () {
                                
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
