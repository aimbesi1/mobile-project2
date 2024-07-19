import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final Timestamp date;
  final Map<String, dynamic> conversations;
  final Map<String, dynamic> properties;
  String? imageURL;

  User(
      {required this.id,
      required this.username,
      required this.date,
      required this.conversations,
      required this.properties,
      this.imageURL});

  factory User.fromJson(String id, Map<String, dynamic> data) {
    return User(
        id: id,
        username: data["username"],
        date: data["date"],
        conversations: data["conversations"] ?? {},
        properties: data["properties"] ?? {},
        imageURL: data["imageURL"] ?? "");
  }

  Map<String, dynamic> toJSON() {
    return {
      "username": username,
      "date": date,
      "conversations": conversations,
      "properties": properties,
      "imageURL": imageURL
    };
  }
}