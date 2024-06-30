import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_main/Desarrolador.dart';
import 'package:stock_main/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_main/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_main/register.dart';


class desarrolladorscreen extends StatefulWidget {
  const desarrolladorscreen({super.key});

  @override
  State<desarrolladorscreen> createState() => _desarrolladorscreenState();
}

class _desarrolladorscreenState extends State<desarrolladorscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

body: Center(

child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [


    Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(onPressed: () {
        
      }, child: const Text('Crear admin')),
    ),

     Padding(
       padding: const EdgeInsets.all(8.0),
       child: ElevatedButton(onPressed: () {
         
       }, child:  Text('Gestionar admins')),
     )



    
  ],

),

  

),



    );
  }
}