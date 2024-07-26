import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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

  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  final maxDistanceController = TextEditingController();
  final targetAddressController = TextEditingController();
  final bedroomsController = TextEditingController();
  final bathroomsController = TextEditingController();
  final floorsController = TextEditingController();
  final minAreaController = TextEditingController();
  final maxAreaController = TextEditingController();

  
  bool _filterHasPool = false;
  bool _filterHasPatio = false;

  double? _lng;
  double? _lat;
  bool _validCoords = false;
  

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

  Future<void> getCoordinates(String? address) async {
    List<Location> coords = [];
    if (address == null || address.isEmpty) {
      _validCoords = false;
      setState(() {});
      return;
    }
    try {
      coords = await locationFromAddress(address);
    } on NoResultFoundException catch (_) {
      _validCoords = false;
      setState(() {});
      return;
    }
    // if (coords.isEmpty) return;
    _lng = coords[0].longitude;
    _lat = coords[0].latitude;
    _validCoords = true;
    setState(() {});
  }

  void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Filter Properties'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: minPriceController,
                    decoration: const InputDecoration(labelText: 'Minimum Sell Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxPriceController,
                    decoration: const InputDecoration(labelText: 'Maximum Sell Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxDistanceController,
                    decoration: const InputDecoration(labelText: 'Maximum Distance from Target Address (miles)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: targetAddressController,
                    decoration: const InputDecoration(labelText: 'Target Address'),
                    onChanged: (value) async {
                      await getCoordinates(targetAddressController.text);
                      setState(() {});
                    }
                  ),
                  TextField(
                    controller: bedroomsController,
                    decoration: const InputDecoration(labelText: 'Number of Bedrooms'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: bathroomsController,
                    decoration: const InputDecoration(labelText: 'Number of Bathrooms'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: floorsController,
                    decoration: const InputDecoration(labelText: 'Number of Floors'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: minAreaController,
                    decoration: const InputDecoration(labelText: 'Minimum Square Footage'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxAreaController,
                    decoration: const InputDecoration(labelText: 'Maximum Square Footage'),
                    keyboardType: TextInputType.number,
                  ),
                  CheckboxListTile(
                    title: const Text('Has Pool'),
                    value: _filterHasPool,
                    onChanged: (bool? value) {
                      setState(() {
                        _filterHasPool = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Has Patio'),
                    value: _filterHasPatio,
                    onChanged: (bool? value) {
                      setState(() {
                        _filterHasPatio = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Apply'),
                onPressed: () {
                  setState(() {
                    
                  });
                  Navigator.of(context).pop();
                  _applyFilters();
                },
              ),
              TextButton(
                child: Text('Remove Filter'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeFilters();
                },
              ),
            ],
          );
        },
      );
    },
  );
}


  double _calculateDistance (lat, lng, propertyLat, propertyLong) {
    return sqrt(pow(lat - propertyLat, 2) + pow(lng - propertyLong, 2));
  }

  void _applyFilters() {
    
  _properties.get().then((querySnapshot) {
    setState(() {
      _filteredProperties = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        if (_filterHasPool && !data['hasPool']) return false;
        if (_filterHasPatio && !data['hasPatio']) return false;
        
        if (minAreaController.text.isNotEmpty && data['area'] < int.parse(minAreaController.text)) return false;
        if (maxAreaController.text.isNotEmpty && data['area'] > int.parse(maxAreaController.text)) return false;
        if (minPriceController.text.isNotEmpty && data['sellPrice'] < int.parse(minPriceController.text)) return false;
        if (maxPriceController.text.isNotEmpty && data['sellPrice'] > int.parse(maxPriceController.text)) return false;
        if (bedroomsController.text.isNotEmpty && data['bedrooms'] != int.parse(bedroomsController.text)) return false;
        if (bathroomsController.text.isNotEmpty && data['bathrooms'] != int.parse(bathroomsController.text)) return false;
        if (floorsController.text.isNotEmpty && data['floors'] != int.parse(floorsController.text)) return false;
        
        if (_validCoords && maxDistanceController.text.isNotEmpty) {
          final double distance = _calculateDistance(_lat, _lng, data['latitude'], data['longitude']);
          if (distance > int.parse(maxDistanceController.text)) return false;
        }

        return true;
      }).toList();
    });
  });
}


  void _removeFilters() async {
      _properties.get().then((querySnapshot) {
        setState(() {
          _filteredProperties = querySnapshot.docs.toList();
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
                      child: PropertyTile(documentSnapshot
                          as DocumentSnapshot<Map<String, dynamic>>),
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
                        MaterialPageRoute(
                            builder: (context) => const SellerPage()),
                      );
                    },
                    child: const Text("My Properties"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
