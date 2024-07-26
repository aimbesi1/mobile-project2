import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/database_helper.dart';
import 'package:project2/models/property.dart';
import 'package:project2/propertypage.dart';
import 'package:project2/street_api.dart';

class AddScreen extends StatefulWidget {
  final bool editMode;
  final Property? property;

  const AddScreen({super.key, this.editMode = false, this.property});

  @override
  AddScreenState createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  File? _image;
  Image? _propertyImage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  final _areaController = TextEditingController();
  bool _hasPool = false;
  bool _hasPatio = false;
  double? _lng;
  double? _lat;
  bool _validCoords = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _dh = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.property != null) {
      setDefaults();
    }
  }

  void setDefaults() async {
    _nameController.text = widget.property!.name;
    _addressController.text = widget.property!.address;
    _sellPriceController.text = widget.property!.sellPrice.toString();
    _bedroomsController.text = widget.property!.bedrooms.toString();
    _bathroomsController.text = widget.property!.bathrooms.toString();
    _floorsController.text = widget.property!.floors.toString();
    _areaController.text = widget.property!.area.toString();
    _hasPool = widget.property!.hasPool;
    _hasPatio = widget.property!.hasPatio;
    await getCoordinates(widget.property!.address);
    setState(() {});
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
    } on NoResultFoundException catch (_, e) {
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

  Widget showImage() {
    if (_image != null) {
      return Image.file(_image!, width: 500, height: 500);
    } else if (widget.property != null) {
      return Image.network(widget.property!.imageURL, width: 500, height: 500);
    }

    return const Text('No image selected.');
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
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: showImage(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _image = File(image.path);
                    });
                  }
                },
                child: const Text('Select image'),
              ),
              TextFormField(
                controller: _nameController,
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
                  labelText: "Name",
                ),
              ),
              // GooglePlacesAutoCompleteTextFormField(
              //       textEditingController: _addressController,
              //       googleAPIKey: googleMapsKey,
              //       debounceTime: 400, // defaults to 600 ms
              //       countries: ["us"], // optional, by default the list is empty (no restrictions)
              //       isLatLngRequired: true, // if you require the coordinates from the place details
              //       getPlaceDetailWithLatLng: (prediction) {
              //         // this method will return latlng with place detail
              //         debugPrint("Coordinates: (${prediction.lat},${prediction.lng})");
              //       }, // this callback is called when isLatLngRequired is true
              //       itmClick: (prediction) {
              //       _addressController.text = prediction.description ?? _addressController.text;
              //         // _addressController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description.length));
              //       },
              //       decoration: const InputDecoration(
              //         border: UnderlineInputBorder(),
              //         labelText: "Address",
              //       ),
              //   ),
              TextFormField(
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.isEmpty || !_validCoords) {
                    return 'Please enter an address';
                  }

                  return null;
                },
                onChanged: (value) async {
                  await getCoordinates(_addressController.text);
                  setState(() {});
                  if (_validCoords) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address is good')),
                    );
                  }
                },
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: "Address",
                    fillColor: _validCoords ? Colors.green : Colors.red),
              ),
              TextFormField(
                controller: _sellPriceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Sell Price",
                ),
              ),
              TextFormField(
                controller: _bedroomsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of bedrooms';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Bedrooms",
                ),
              ),
              TextFormField(
                controller: _bathroomsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of bathrooms';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Bathrooms",
                ),
              ),
              TextFormField(
                controller: _floorsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of floors';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Floors",
                ),
              ),
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the area';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Area",
                ),
              ),
              SwitchListTile(
                title: const Text("Has Pool"),
                value: _hasPool,
                onChanged: (bool value) {
                  setState(() {
                    _hasPool = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Has Patio"),
                value: _hasPatio,
                onChanged: (bool value) {
                  setState(() {
                    _hasPatio = value;
                  });
                },
              ),
              // Add more fields for the rest of the data
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ButtonBar(
                  children: [
                    // Sign up
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            (_image != null || widget.property != null)
                            // || _lng != null || _lat != null)) {
                            &&
                            _validCoords) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );

                          try {
                            String imageURL = _image != null
                                ? await _dh.addImage(_image!)
                                : widget.property!.imageURL;

                            Property p = Property(
                                id: widget.property?.id ?? "",
                                name: _nameController.text,
                                sellerID: _auth.currentUser!.uid,
                                sellPrice: int.parse(_sellPriceController.text),
                                address: _addressController.text,
                                longitude: _lng!,
                                latitude: _lat!,
                                timestamp: Timestamp.now(),
                                bedrooms: int.parse(_bedroomsController.text),
                                bathrooms: int.parse(_bathroomsController.text),
                                floors: int.parse(_floorsController.text),
                                area: int.parse(_areaController.text),
                                hasPool: _hasPool,
                                hasPatio: _hasPatio,
                                imageURL: imageURL);

                            if (widget.editMode == false) {
                              await _dh.addNewProperty(p);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Added property successfully')));
                              Navigator.of(context).pop();
                            } else {
                              await _dh.updateProperty(p.id, p);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Updated property successfully')));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PropertyPage(p)),
                              );
                            }

                            // if (!Navigator.of(context).canPop()) {
                            // if (!context.mounted) return;

                            // }
                          } catch (e) {
                            print("Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: Text(
                          widget.editMode ? 'Update Property' : 'Add Property'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
