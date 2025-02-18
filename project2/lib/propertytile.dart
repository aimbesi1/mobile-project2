import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project2/models/property.dart';
import 'package:project2/propertypage.dart';

class PropertyTile extends StatelessWidget {

  late final Property _property;
  
  PropertyTile(DocumentSnapshot<Map<String, dynamic>> pSnapshot, {super.key}) {
    _property = Property.fromJson(pSnapshot.id, pSnapshot.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => PropertyPage(_property))
        );
      },
      child: Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.network(
              _property.imageURL!,
              width: 500,
              height: 500,
            ),
          ),
          Container(
            // color: Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.all(8),
            child: Text(_property.name)
          ),
        ],
      ),
      ),
    );
  }
}
