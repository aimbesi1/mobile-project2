import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String>? userIDs; // IDs of users in conversation
  final String? lastMessage;
  final Timestamp timestamp;

  Conversation(
      {required this.id,
      required this.userIDs,
      this.lastMessage,
      required this.timestamp});

  factory Conversation.fromJson(String id, Map<String, dynamic> data) {
    List<String> users = [];
    for (var user in data["users"]) {
      users.add(user as String);
    }
    return Conversation(
      id: id,
      userIDs: users,
      lastMessage: data["lastMessage"],
      timestamp: data["timestamp"],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "users": userIDs,
      "lastMessage": lastMessage,
      "timestamp": timestamp,
    };
  }

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Conversation(
      id: snapshot.id,
      lastMessage: data?['lastMessage'],
      timestamp: data?['timestamp'],

      userIDs:
          data?['userIDs'] is Iterable ? List.from(data?['userIDs']) : null,
    );
  }
}