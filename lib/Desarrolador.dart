// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_main/desarrolladorscreen.dart';
import 'package:stock_main/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var usuario = '';
  var contrasea = '';

  Future<void> _iniciarSesion() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usuario,
        password: contrasea,
      );
      String uid = userCredential.user?.uid ?? '';

      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('desarrolador').doc(uid).get();
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        if (userData['rol'] == 'desarrollador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InstitucionesScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No tienes permisos de desarrollador')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario no encontrado en la base de datos')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email de desarrollador'),
              onChanged: (value) => usuario = value,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              onChanged: (value) => contrasea = value,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: _iniciarSesion,
                child: Text('Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
