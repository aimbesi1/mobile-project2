import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project2/models/property.dart';

class PropertyTile extends StatelessWidget {

  late final Property _property;
  
  PropertyTile(DocumentSnapshot<Map<String, dynamic>> pSnapshot, {super.key}) {
    _property = Property.fromJson(pSnapshot.id, pSnapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.network(
              _property.imageURL!,
              width: 100,
              height: 100
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Text(_property.name)
          )
        ]
      )
    );
  }
}
