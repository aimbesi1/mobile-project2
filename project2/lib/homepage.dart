import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project2/auth.dart';

// Placeholder widget for home page
class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: const Text("Thank you kindly")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _auth.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginForm()));
        },
        child: Icon(Icons.exit_to_app),
      ),
    );
  }
}
