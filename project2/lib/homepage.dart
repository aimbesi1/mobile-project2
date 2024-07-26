import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project2/auth.dart';
import 'package:project2/propertytile.dart';
import 'package:project2/sellers.dart';
import 'package:project2/conversation_list_screen.dart';
import 'package:project2/settings_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final CollectionReference _properties =
      FirebaseFirestore.instance.collection('properties');
  List<DocumentSnapshot> _filteredProperties = [];
  final String currentUserId = _auth.currentUser!.uid;

  bool _filterHasPool = false;
  bool _filterHasPatio = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    _properties.get().then((querySnapshot) {
      setState(() {
        _filteredProperties = querySnapshot.docs;
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Properties'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CheckboxListTile(
                title: Text('Has Pool'),
                value: _filterHasPool,
                onChanged: (bool? value) {
                  setState(() {
                    _filterHasPool = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Has Patio'),
                value: _filterHasPatio,
                onChanged: (bool? value) {
                  setState(() {
                    _filterHasPatio = value!;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    _properties.get().then((querySnapshot) {
      setState(() {
        _filteredProperties = querySnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (_filterHasPool && !data['hasPool']) return false;
          if (_filterHasPatio && !data['hasPatio']) return false;
          return true;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            IconButton(
              icon: Icon(Icons.settings),
               onPressed: () {
                Navigator.pushNamed(context, '/settings');
                },
            ),
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginForm()));
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConversationsListScreen(currentUserId: currentUserId),
                    ),
                  );
                },
                child: Text("Conversations"),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: _filteredProperties.length,
                  itemBuilder: (context, index) {
                    final documentSnapshot = _filteredProperties[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: PropertyTile(documentSnapshot as DocumentSnapshot<Map<String, dynamic>>),
                    );
                  },
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SellerPage()),
                      );
                    },
                    child: const Text("My Properties"),
                  ),
                ],
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   tooltip: 'Add Item',
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}