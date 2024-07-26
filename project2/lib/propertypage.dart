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
      widget.property = Property.fromJson(propertyData.id, propertyData.data()!);
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
      body: Center(
        child: Column(
          children: [
            Image.network(
              widget.property.imageURL),
            Row(children: [
              Text("Price: \$${widget.property.sellPrice}"),
              GestureDetector(
                  onTap: () async {
                    if (widget.property.sellerID != _auth.currentUser!.uid &&
                        sellerName != null) {
                      Conversation? conversation = await _dh.createConversation(
                          widget.property.sellerID, sellerName!);
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
                    }
                  },
                  child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text("Seller: ${sellerName ?? "Loading"}")))
            ]),

          ButtonBar(
            children: [
              widget.property.sellerID == _auth.currentUser!.uid ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddScreen(editMode: true, property: widget.property))
                        );
                    },
                    child: const Text("Edit Property")
                  )
                 : const Placeholder(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StreetViewScreen(latitude: widget.property.latitude, longitude: widget.property.longitude)
                          ),
                        );
                },
                child: const Text("View Area")
              )
            ]
          )
          ],
        ),
      ),
    );
  }
}
