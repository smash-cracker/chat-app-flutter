import 'dart:typed_data';

import 'package:chat/auth/storage_methods.dart';
import 'package:chat/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class authMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signupuser({
    required String name,
    required String phone,
    required Uint8List file,
  }) async {
    String res = 'errror occured';
    try {
      if (name.isNotEmpty || phone.isNotEmpty) {
        String photourl = await StorageMethods()
            .uploadImageStorage('profilepics', file, false);

        var user = UserModel(
            name: name,
            phone: phone,
            dp: photourl,
            isOnline: true,
            groupIDs: []);

        await _firestore.collection('users').doc(phone).set(user.toMap());
        res = 'success';
      } else {}
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
      } else {}
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //login user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      final value = await FirebaseFirestore.instance
          .collection("events")
          .doc(postId)
          .get();

      likes = value.data()!["likes"];

      if (likes.contains(uid)) {
        await _firestore.collection('events').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('events').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addSubEventToList(String mainEventId, String subEventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _firestore
          .collection('participations')
          .doc(user.uid)
          .collection('conducted')
          .doc(mainEventId)
          .update({
        'subEventList': FieldValue.arrayUnion([subEventId]),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}
