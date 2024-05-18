import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_main/Login.dart';
import 'package:stock_main/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_main/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

var usuario = '';
var contra = '';
var contra2 = '';
FirebaseAuth auth = FirebaseAuth.instance;

class _RegisterState extends State<Register> {
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
              decoration: const InputDecoration(labelText: 'Contrase;a'),
              obscureText: true,
              onChanged: (value) => contra = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Confirma contrase;a'),
              obscureText: true,
              onChanged: (value) => contra2 = value,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (usuario.isNotEmpty && contra.isNotEmpty && contra2.isNotEmpty) {
                        if (contra == contra2) {
                          try {
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: usuario,
                              password: contra,
                            );
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Usuario creado correctamente"),
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
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Las contrase;as no coinciden'),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Debes llenar todos los campos'),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Registrar este Usuario'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
