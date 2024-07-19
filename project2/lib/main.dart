import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/auth.dart';
import 'package:project2/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project2/homepage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'real-estate-project-5a668',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({Key? key}) : super(key: key);

  // final Future<FirebaseApp> _initFirebase = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Real Estate Time',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) {
            final FirebaseAuth _auth = FirebaseAuth.instance;
            _auth.idTokenChanges().listen((event) {});
            if (_auth.currentUser == null) {
              return LoginForm();
            } else {
              return HomePage();
            }
          },
          '/auth': (context) => LoginForm(),
          '/home': (context) => HomePage(),
        });
  }
}