import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project2/homepage.dart';
import 'package:project2/database_helper.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

// class AuthSelect extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else if (snapshot.hasData) {
//           return HomePage();
//         } else {
//           return LoginForm();
//         }
//       },
//     );
//   }
// }

class LoginForm extends StatefulWidget {
  LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } else if (!(value.contains(
                    RegExp(r'^[a-z0-9]+@[a-z]+.([a-z]+.)*(com|edu|org)$')))) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Email",
              ),
            ),
            TextFormField(
              // The validator receives the text that the user has entered.
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } else if (!(value.contains(RegExp(r'^[a-z0-9]+$')))) {
                  return 'Please enter a valid username';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Username",
              ),
            ),
            TextFormField(
              controller: _passController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                } else if (!(value.contains(RegExp(r'\W')) &&
                    value.contains(RegExp(r'[A-Z]')) &&
                    value.contains(RegExp(r'[0-9]')))) {
                  return 'Password must contain one uppercase letter, one number, one special character';
                }
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Password",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ButtonBar(children: [
                // Sign up
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      try {
                        UserCredential signUp =
                            await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passController.text,
                        );
                        debugPrint("Got credentials");

                        // Add user to Firestore database
                        _db
                            .collection("users")
                            .doc(signUp.user!.uid)
                            .set({
                              "username": _usernameController.text,
                              "date": Timestamp.now(),
                              "conversations": [],
                              "properties": [],
                            })
                            .then((value) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Registered successfully'))))
                            .catchError((error) => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                    SnackBar(content: Text("FAILED. $error"))));

                        // if (!Navigator.of(context).canPop()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                        // }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          debugPrint('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          debugPrint(
                              'The account already exists for that email.');
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                  },
                  child: const Text('Sign up'),
                ),
                ElevatedButton(
                  // Log in
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      try {
                        await _auth.signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passController.text,
                        );
                        debugPrint("Got credentials");
                        // if (!Navigator.of(context).canPop()) {

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                        // }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          debugPrint('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          debugPrint('Wrong password provided for that user.');
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                  },
                  child: const Text('Log in'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
