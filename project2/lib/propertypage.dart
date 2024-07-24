import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';
import 'package:project2/database_helper.dart';
import 'package:project2/models/property.dart';

class PropertyPage extends StatefulWidget {
  late final Property property;
  
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
    _fetchSellerName();
  }

  Future<void> _fetchSellerName() async {
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
            Image.network(widget.property.imageURL!),
            Row(children: [
              Text("Price: \$${widget.property.sellPrice}"),
              GestureDetector(
                  onTap: () {
                    if (widget.property.sellerID != _auth.currentUser!.uid) {
                      _dh.startConversation(widget.property.sellerID);
                    }
                  },
                  child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text("Seller: ${sellerName ?? "Loading"}")))
            ])
          ],
        ),
      ),
    );
  }
}
