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
  final Property? property;

  const AddScreen({super.key, this.editMode = false, this.property});

  @override
  AddScreenState createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  final _areaController = TextEditingController();

  bool _hasPool = false;
  bool _hasPatio = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _dh = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.property != null) {
      _titleController.text = widget.property!.name;
      _priceController.text = widget.property!.sellPrice.toString();
      _addressController.text = widget.property!.address;
      _bedroomsController.text = widget.property!.bedrooms.toString();
      _bathroomsController.text = widget.property!.bathrooms.toString();
      _floorsController.text = widget.property!.floors.toString();
      _areaController.text = widget.property!.area.toString();
      _hasPool = widget.property!.hasPool;
      _hasPatio = widget.property!.hasPatio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editMode ? "Edit Property" : "Add Property"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _image == null
                    ? const Text('No image selected.')
                    : Image.file(_image!),
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
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bedroomsController,
                decoration: const InputDecoration(labelText: "Bedrooms"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of bedrooms';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bathroomsController,
                decoration: const InputDecoration(labelText: "Bathrooms"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of bathrooms';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _floorsController,
                decoration: const InputDecoration(labelText: "Floors"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of floors';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: "Area (sq ft)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter area';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text('Has Pool'),
                value: _hasPool,
                onChanged: (bool? value) {
                  setState(() {
                    _hasPool = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Has Patio'),
                value: _hasPatio,
                onChanged: (bool? value) {
                  setState(() {
                    _hasPatio = value!;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        String imageURL = _image != null ? await _dh.addImage(_image!) : (widget.property?.imageURL ?? '');

                        List<Location> coords = await locationFromAddress(_addressController.text);
                        final longitude = coords[0].longitude;
                        final latitude = coords[0].latitude;

                        User? currentUser = _auth.currentUser;
                        if (currentUser == null) {
                          throw Exception("User not logged in");
                        }

                        Property propertyData = Property(
                          id: widget.editMode ? widget.property?.id ?? "" : "",
                          name: _titleController.text,
                          sellerID: currentUser.uid,
                          sellPrice: int.parse(_priceController.text),
                          address: _addressController.text,
                          longitude: longitude,
                          latitude: latitude,
                          timestamp: Timestamp.now(),
                          bedrooms: int.parse(_bedroomsController.text),
                          bathrooms: int.parse(_bathroomsController.text),
                          floors: int.parse(_floorsController.text),
                          area: int.parse(_areaController.text),
                          hasPool: _hasPool,
                          hasPatio: _hasPatio,
                          imageURL: imageURL
                        );

                        if (widget.editMode) {
                          await _dh.updateProperty(propertyData);
                        } else {
                          await _dh.addNewProperty(propertyData);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(widget.editMode ? 'Property updated successfully' : 'Property added successfully')),
                        );

                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(widget.editMode ? 'Update Property' : 'Add Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
