import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_main/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_main/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_main/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

var usuario = '' ;
var contra = ''; 
FirebaseAuth auth = FirebaseAuth.instance;

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
    body: Center(

      child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
  children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              onChanged: (value) => usuario = value,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText:'Contrase;a'),
              onChanged: (value) => contra = value,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton(
                    onPressed: () async {

          try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: usuario, 
                password: contra,);
      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Stock()),
                      );
      } catch (error) {
        showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(error.toString()),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const Login()),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

}                    
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                ),
                 
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton(
                    onPressed: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Register()),
                      );
                    },
                    child: const Text('Crear cuenta'),),
                )
  ],

 ),
  ]
    ),
    )
    );
  }
}