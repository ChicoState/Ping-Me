import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class helpers {
  Future<String> getUsername(String uid) async {
    String username = '';
    final DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('userEmails')
        .doc(uid)
        .get();

    username = data.get('username');
    return username;
  }
}
