
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_main/Login.dart';
import 'package:stock_main/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    const MyApp());
  firebaseinit();
  }

  Future<void> firebaseinit() async {

var usuarioAPPBAR = '';


    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
       
    );
  }
}

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}
  List<String> listaDeOpciones = ["Mothers","Placas de video","Procesadores","Memorias Ram","Memorias de almacenamiento"];
  String categoria = '';
  String nombre = '';
  int precio = 0;
  int cantidad = 0;
  String busqueda = '';


Future<void> editarproductos(BuildContext context,data,docId) async {

showDialog(
  context: context,
   builder: (BuildContext context) {

        String nuevoNombre = data['nombre'];
        int nuevoPrecio = data['precio'];
        int nuevaCantidad = data['cantidad'];
        String nuevaCategoria = data['categoria'];

return AlertDialog(
          title: Text('Editar Producto'),
          content: Column(
mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => nuevoNombre = value,
                controller: TextEditingController(text: nuevoNombre),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Precio'),
                onChanged: (value) => nuevoPrecio = int.tryParse(value) ?? nuevoPrecio,
                controller: TextEditingController(text: nuevoPrecio.toString()),
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Cantidad'),
                onChanged: (value) => nuevaCantidad = int.tryParse(value) ?? nuevaCantidad,
                controller: TextEditingController(text: nuevaCantidad.toString()),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField(
  items: listaDeOpciones.map((e) {
    return DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(
          e,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      value: e,
    );
  }).toList(),
  value: nuevaCategoria, 
  onChanged: (value) => nuevaCategoria = value as String, 
  isDense: true,
  isExpanded: true,
)
            ]
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
    try {
      await FirebaseFirestore.instance.collection('stock').doc(docId).update({
        'nombre': nuevoNombre,
        'precio': nuevoPrecio,
        'cantidad': nuevaCantidad,
        'categoria': nuevaCategoria
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Error al actualizar el producto: $e');
    }
  },
  child: Text('Guardar'),
),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('Cancelar'),
            ),
          ],
);

   }
   
   
   );


}


 Future<void> eliminarproductos(docId) async {
try {

   

    await FirebaseFirestore.instance.collection('stock').doc(docId).delete();
  } catch (e) {
    print('Error al eliminar el documento: $e');
  }
}

  Future<void> agregarboton(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => nombre = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Precio'),
                onChanged: (value) => precio = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                onChanged: (value) => cantidad = int.tryParse(value) ?? 0,
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField(
  items: listaDeOpciones.map((e){
    return DropdownMenuItem(
      child: SizedBox(
        width: double.infinity,
        child: Text(
          e,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      value: e,
    );
  }).toList(),
  onChanged: (value) => categoria = value!,
  isDense: true,
  isExpanded: true,
)
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                agregarStock(nombre, precio, cantidad);
                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
             ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),

          ],
        );
      },
    );
  }

  Future<void> agregarStock(nombre,precio,cantidad) async {
    await FirebaseFirestore.instance
    .collection('stock')
    .add({
      "nombre": nombre,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    });
  }


class _StockState extends State<Stock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Usuarios').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Cargando...');
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('No hay datos para este usuario');
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String usuarioAppBar = userData['Nombre'];

            return Text('Hola querido $usuarioAppBar');
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(

          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextField(
                decoration: InputDecoration(labelText: 'Buscar producto'),
                onChanged: (value) {
                  setState(() {
                    busqueda = value.toLowerCase();
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                agregarboton(context);
              },
              child: const Text('Agregar'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('stock')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error ${snapshot.error}'));
                  }

                  final filteredProducts = snapshot.data!.docs.where((document) {
                    final Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] as String;
                    return nombre.toLowerCase().contains(busqueda.toLowerCase());
                  }).toList();

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay productos'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Precio')),
                        DataColumn(label: Text('Cantidad')),
                        DataColumn(label: Text('Categoria')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: filteredProducts.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        final String docId = document.id;
                        return DataRow(
                          cells: [
                            DataCell(Text(data['nombre'])),
                            DataCell(Text(data['precio'].toString())),
                            DataCell(Text(data['cantidad'].toString())),
                            DataCell(Text(data['categoria'])),
                            DataCell(IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                editarproductos(context, data, docId);
                              },
                            )),
                            DataCell(IconButton(
                              icon: Icon(Icons.delete_rounded),
                              onPressed: () {
                                eliminarproductos(docId);
                              },
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}