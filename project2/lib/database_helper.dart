import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _properties = FirebaseFirestore.instance.collection('properties');
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  final CollectionReference _conversations = FirebaseFirestore.instance.collection('convos');
  final CollectionReference _messages = FirebaseFirestore.instance.collection('messages');

  Future<bool> addUser(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection("users").doc(userId).set(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}