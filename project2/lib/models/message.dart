import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Unique message ID
  final String fromID; // ID of the sender
  final String conversationID; // ID of the conversation it belongs to
  final String content;
  final Timestamp timestamp;
  final int type;

  Message(
      {required this.id,
      required this.content,
      required this.timestamp,
      required this.fromID,
      required this.conversationID,
      required this.type,
      });

  factory Message.fromJson(String id, Map<String, dynamic> data) {
    return Message(
        id: id,
        fromID: data["fromID"],
        // toID: data["toID"],
        conversationID: data["conversationID"],
        content: data["content"],
        timestamp: data["timestamp"],
        type: data["type"],
        );
  }

  Map<String, dynamic> toJSON() {
    return {
      "fromID": fromID,
      "type": type,
      "conversationID": conversationID,
      "content": content,
      "timestamp": timestamp,
    };
  }
}