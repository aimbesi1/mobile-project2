import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project2/models/conversation.dart';
import 'package:project2/models/message.dart';
import 'package:project2/models/property.dart';
import 'package:project2/models/user.dart';

class DatabaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _properties =
      FirebaseFirestore.instance.collection('properties');
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _conversations =
      FirebaseFirestore.instance.collection('convos');
  final CollectionReference _messages =
      FirebaseFirestore.instance.collection('messages');

  final storageRef = FirebaseStorage.instance.ref();


  Future<bool> addNewProperty(Property p) async {
    try {

      // Add property to 'properties' collection, then add ID of the property document 
      // to the 'properties' array of the doc in 'users' belonging to the current user

      DocumentReference pRef = await _properties.add(p.toJSON());
    
      DocumentSnapshot user = await _users.doc(_auth.currentUser!.uid).get();

      List<String> properties = user['properties'] as List<String>;
      properties.add(pRef.id);

      await _users.doc(_auth.currentUser!.uid).update({
        "properties": properties
      });


      return true;
    }
    catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // static Map<String, UserModel> userMap = {};
  // static Map<String, Conversation> convoMap = {};
  // static Map<String, Message> messageMap = {};

  // DatabaseHelper() {
  //   _db.collection("users").snapshots().listen(_usersUpdated);
  //   _db.collection("conversations").snapshots().listen(_convosUpdated);
  //   _db.collection("messages").snapshots().listen(_messagesUpdated);
  // }

  // Map<String, UserModel> _usersUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
  //   try {
  //     for (var doc in snapshot.docs) {
  //       UserModel user = UserModel.fromJson(doc.id, doc.data());
  //       userMap[user.id] = user;
  //     }
  //     return userMap;
  //   } catch (e) {
  //     print(e.toString());
  //     return {};
  //   }
  // }

  // Map<String, Conversation> _convosUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
  //   try {
  //     for (var doc in snapshot.docs) {
  //       Conversation c = Conversation.fromJson(doc.id, doc.data());
  //       convoMap[c.id] = c;
  //     }
  //     return convoMap;
  //   } catch (e) {
  //     print(e.toString());
  //     return {};
  //   }
  // }

  // Map<String, Message> _messagesUpdated(QuerySnapshot<Map<String, dynamic>> snapshot) {
  //   try {
  //     for (var doc in snapshot.docs) {
  //       Message m = Message.fromJson(doc.id, doc.data());
  //       messageMap[m.id] = m;
  //     }
  //     return messageMap;
  //   } catch (e) {
  //     print(e.toString());
  //     return {};
  //   }
  // }

  Future<String> addImage(File image) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    var uploadTask = storageRef.child('images/$imageName.jpg')
      .putFile(image);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();

    return downloadUrl.toString();
  }



  Future<Conversation> startConversation(String otherID) async {
    final existingConvo = (await _conversations
      .where("userIDs", arrayContains: _auth.currentUser!.uid)
      .where("userIDs", arrayContains: otherID)
      .limit(1)
      .get())
      .docs;
    
    if (existingConvo.isEmpty) {
      final ref = await _conversations.add(Conversation(
        id: "",
        userIDs: [_auth.currentUser!.uid, otherID],
        lastMessage: "",
        timestamp: Timestamp.now()
      ).toJSON());

      final docSnap = await ref.get();

      final data = docSnap.data() as Map<String, dynamic>;

      final convoObj = {
        "id": docSnap.id,
        "userIDs": data["userIDs"]!,
        "lastMessage": data["lastMessage"],
        "timestamp": data["timestamp"]
      };

      return Conversation.fromJson(convoObj['id'], convoObj);
    }
    else {
      return Conversation.fromJson(existingConvo.first.id, existingConvo.first.data() as Map<String, dynamic>);
    }
  }
}
