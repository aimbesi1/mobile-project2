import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/database_helper.dart';
import 'package:project2/models/property.dart';

class AddScreen extends StatefulWidget {
  final bool editMode;

  const AddScreen({super.key, this.editMode = false});

  @override
  AddScreenState createState() {
    return AddScreenState();
  }
}

class AddScreenState extends State<AddScreen> {
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseHelper _dh = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: widget.editMode
              ? const Text("Edit Property")
              : const Text("Add Property")),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: Center(
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(_image!),
              ),
            ),
            ElevatedButton(
               onPressed: () async {
                   final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                           if (image != null) {
                             setState(() {
                              _image = File(image.path);
                            });
                           }
                         },
                   child: const Text('Select image'),
            ),
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                // } else if (!(value.contains(
                //     RegExp(r'^[a-z0-9]+@[a-z]+.([a-z]+.)*(com|edu|org)$')))) {
                //   return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Title",
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ButtonBar(children: [
                // Sign up
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _image != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );

                      try {
                        String imageURL = await _dh.addImage(_image!);

                        List<Location> coords = await locationFromAddress("Gronausestraat 710, Enschede"); // Example from https://pub.dev/packages/geocoding
                        final longitude = coords[0].longitude;
                        final latitude = coords[0].latitude;
                        
                        await _dh.addNewProperty(Property(
                              id: "",
                              name: _titleController.text,
                              sellerID: _auth.currentUser!.uid,
                              sellPrice: 0,
                              address: "Gronausestraat 710, Enschede",
                              longitude: longitude,
                              latitude: latitude,
                              timestamp: Timestamp.now(),
                              bedrooms: 2,
                              bathrooms: 2,
                              floors: 2,
                              area: 2,
                              hasPool: true,
                              hasPatio: true,
                              imageURL: imageURL
                            ));

                        
                        
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Added property successfully')));
                            

                        // if (!Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                        // }
                      } catch (e) {
                        debugPrint("Found an error");
                        debugPrint(e.toString());
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
