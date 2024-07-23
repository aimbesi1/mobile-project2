import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project2/addproperty.dart';
import 'package:project2/auth.dart';
import 'package:project2/propertytile.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// Placeholder widget for home page
class SellerPage extends StatefulWidget {
  @override
  SellerPageState createState() {
    return SellerPageState();
  }
}

class SellerPageState extends State<SellerPage> {
  final CollectionReference _properties =
      FirebaseFirestore.instance.collection('properties');
  CollectionReference _filteredProperties =
      FirebaseFirestore.instance.collection('properties');

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) => false,
        child: Scaffold(
          appBar: AppBar(title: const Text("My Properties"), actions: [
            IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginForm()));
                },
                icon: Icon(Icons.exit_to_app))
          ]),
          body: Center(
            child: Column(
              children: [
                Expanded(child: StreamBuilder(
                  stream: _properties.where('sellerID', isEqualTo: _auth.currentUser!.uid).snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Card(
                              margin: const EdgeInsets.all(10),
                              child: GestureDetector(
                                  child: PropertyTile(documentSnapshot
                                      as DocumentSnapshot<
                                          Map<String, dynamic>>)));
                        },
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                ),
                ButtonBar(children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddScreen(editMode: true))
                        );
                    },
                    child: const Text("Add a Property")
                  ),
                ])
              ],
            ),
          ),
          
        ));
  }
}
