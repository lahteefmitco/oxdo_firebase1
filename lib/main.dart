import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oxdo_firebase1/screens/home_screen.dart';
import 'firebase_options.dart';


// late initializing firestore instance as globally
late final FirebaseFirestore fdb;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 

  // Initalizing firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // set settings
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

   // firestore database initializing
  fdb = FirebaseFirestore.instance;

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      
      home: const HomeScreen(),
    );
  }
}




