import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';
import 'package:project2/addproperty.dart';
import 'package:project2/chat_screen.dart';
import 'package:project2/database_helper.dart';
import 'package:project2/models/conversation.dart';
import 'package:project2/models/property.dart';
import 'package:project2/tour.dart';

class PropertyPage extends StatefulWidget {
  late Property property;

  PropertyPage(Property p, {super.key}) {
    property = p;
  }

  @override
  PropertyPageState createState() {
    return PropertyPageState();
  }
}

class PropertyPageState extends State<PropertyPage> {
  late String? sellerName = "Loading";
  final _dh = DatabaseHelper();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final propertyData = await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.property.id)
        .get();
    setState(() {
      widget.property =
          Property.fromJson(propertyData.id, propertyData.data()!);
    });

    final sellerData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.property.sellerID)
        .get();
    setState(() {
      sellerName = sellerData.data()?['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.property.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.property.imageURL),
              SizedBox(height: 16),
              Text(
                widget.property.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 8),
              Text(
                widget.property.address,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text("Price: \$${widget.property.sellPrice}"),
              ),
              ListTile(
                leading: Icon(Icons.king_bed),
                title: Text("Bedrooms: ${widget.property.bedrooms}"),
              ),
              ListTile(
                leading: Icon(Icons.bathtub),
                title: Text("Bathrooms: ${widget.property.bathrooms}"),
              ),
              ListTile(
                leading: Icon(Icons.layers),
                title: Text("Floors: ${widget.property.floors}"),
              ),
              ListTile(
                leading: Icon(Icons.square_foot),
                title: Text("Area: ${widget.property.area} sqft"),
              ),
              ListTile(
                leading: Icon(widget.property.hasPool
                    ? Icons.pool
                    : Icons.do_not_disturb),
                title:
                    Text("Has Pool: ${widget.property.hasPool ? 'Yes' : 'No'}"),
              ),
              ListTile(
                leading: Icon(widget.property.hasPatio
                    ? Icons.deck
                    : Icons.do_not_disturb),
                title: Text(
                    "Has Patio: ${widget.property.hasPatio ? 'Yes' : 'No'}"),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StreetViewScreen(
                            latitude: widget.property.latitude,
                            longitude: widget.property.longitude,
                          ),
                        ),
                      );
                    },
                    child: const Text("View Area"),
                  ),
                  if (widget.property.sellerID != _auth.currentUser!.uid &&
                      sellerName != null)
                    ElevatedButton(
                      onPressed: () async {
                        Conversation? conversation =
                            await _dh.createConversation(
                          widget.property.sellerID,
                          sellerName!,
                        );
                        if (conversation != null) {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(conversationId: conversation.id),
                            ),
                          );
                        }
                      },
                      child: Text("Contact Seller: ${sellerName ?? "Loading"}"),
                    ),
                  if (widget.property.sellerID == _auth.currentUser!.uid)
                    ElevatedButton(
                      onPressed: () async {
                        final updatedProperty = await Navigator.push<Property>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddScreen(
                              editMode: true,
                              property: widget.property,
                            ),
                          ),
                        );

                        if (updatedProperty != null) {
                          setState(() {
                            widget.property = updatedProperty;
                          });
                        }
                      },
                      child: Text('Edit Property'),
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
