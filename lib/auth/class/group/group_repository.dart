import 'dart:io';

import 'package:chat/common/repository/common_firebase_storage_repository.dart';
import 'package:chat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:chat/model/group.dart' as model;

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) async {
    Contact? currentUserContact =
        await FlutterContacts.getContact(auth.currentUser!.phoneNumber!);
    String currentUserDisplayName = currentUserContact?.displayName ?? '';

    try {
      List<Map<String, dynamic>> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where(
              'phone',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(
            {
              'phone': userCollection.docs[0].data()['phone'],
              'name': selectedContact[i].displayName,
            },
          );
        }
      }
      uids.add(
        {
          'phone': auth.currentUser!.phoneNumber!,
          'name': currentUserDisplayName,
        },
      );
      var groupId = const Uuid().v1();

      String profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'group/$groupId',
            profilePic,
          );
      model.Group group = model.Group(
        senderId: auth.currentUser!.phoneNumber!,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [...uids],
        timeSent: DateTime.now(),
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void addMembersGroup(BuildContext context, String groupId,
      List<Contact> selectedContact) async {
    Contact? currentUserContact =
        await FlutterContacts.getContact(auth.currentUser!.phoneNumber!);
    String currentUserDisplayName = currentUserContact?.displayName ?? '';

    try {
      List<Map<String, dynamic>> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where(
              'phone',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(
            {
              'phone': userCollection.docs[0].data()['phone'],
              'name': selectedContact[i].displayName,
            },
          );
        }
      }

      for (var x in uids) {
        await firestore.collection('groups').doc(groupId).update({
          'membersUid': FieldValue.arrayUnion(
            [x],
          ),
        });
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
