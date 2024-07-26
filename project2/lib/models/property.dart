import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id; // Unique property ID
  final String name;
  final String sellerID; // ID of the seller
  final int sellPrice;
  final String address; 
  final double longitude;
  final double latitude;
  final Timestamp timestamp;
  final int bedrooms;
  final int bathrooms;
  final int floors;
  final int area;
  final bool hasPool;
  final bool hasPatio;
  final String imageURL;

  Property(
      {required this.id,
      required this.name,
      required this.sellerID,
      required this.sellPrice,
      required this.address,
      required this.longitude,
      required this.latitude,
      required this.timestamp,
      required this.bedrooms,
      required this.bathrooms,
      required this.floors,
      required this.area,
      required this.hasPool,
      required this.hasPatio,
      required this.imageURL
      });

  factory Property.fromJson(String id, Map<String, dynamic> data) {
    return Property(
        id: id,
        name: data["name"], 
        sellerID: data["sellerID"],
        sellPrice: data["sellPrice"],
        address: data["address"],
        longitude: data["longitude"],
        latitude: data["latitude"],
        timestamp: data["timestamp"],
        bedrooms: data["bedrooms"],
        bathrooms: data["bathrooms"],
        floors: data["floors"],
        area: data["area"],
        hasPool: data["hasPool"],
        hasPatio: data["hasPatio"],
        imageURL: data["imageURL"] ?? ""
        );
  }

  Map<String, dynamic> toJSON() {
    return {
      "sellerID": sellerID,
      "name": name,
      "sellPrice": sellPrice,
      "address": address,
      "longitude": longitude,
      "latitude": latitude,
      "timestamp": timestamp,
      "bedrooms": bedrooms,
      "bathrooms": bathrooms,
      "floors": floors,
      "area": area,
      "hasPool": hasPool,
      "hasPatio": hasPatio,
      "imageURL": imageURL
    };
  }

  factory Property.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Property(
      id: snapshot.id,
      name: data?["name"],
      sellerID: data?["sellerID"],
      sellPrice: data?["sellPrice"],
      address: data?["address"],
      longitude: data?["longitude"],
      latitude: data?["latitude"],
      timestamp: data?["timestamp"],
      bedrooms: data?["bedrooms"],
      bathrooms: data?["bathrooms"],
      floors: data?["floors"],
      area: data?["area"],
      hasPool: data?["hasPool"],
      hasPatio: data?["hasPatio"],
      imageURL: data?["imageURL"] ?? ""
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "sellerID": sellerID,
      "sellPrice": sellPrice,
      "address": address,
      "longitude": longitude,
      "latitude": latitude,
      "timestamp": timestamp,
      "bedrooms": bedrooms,
      "bathrooms": bathrooms,
      "floors": floors,
      "area": area,
      "hasPool": hasPool,
      "hasPatio": hasPatio,
      "imageURL": imageURL
    };
  }
}