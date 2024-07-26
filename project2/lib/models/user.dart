import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? username;
  final Timestamp? date;
  final List<String>? conversations;
  final List<String>? properties;

  UserModel(
      {required this.id,
      required this.username,
      required this.date,
      required this.conversations,
      required this.properties,
      });

  factory UserModel.fromJson(String id, Map<String, dynamic> data) {
    return UserModel(
        id: id,
        username: data["username"],
        date: data["date"],
        conversations: data["conversations"] ?? [],
        properties: data["properties"] ?? []
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "username": username,
      "date": date,
      "conversations": conversations,
      "properties": properties,
    };
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      id: snapshot.id,
      username: data?['username'],
      date: data?['date'],

      conversations:
          data?['conversations'] is Iterable ? List.from(data?['conversations']) : null,
      properties:
          data?['properties'] is Iterable ? List.from(data?['properties']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (username != null) "username": username,
      if (date != null) "date": date,
      if (conversations != null) "conversations": conversations,
      if (properties != null) "properties": properties,
    };
  }
}