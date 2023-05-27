import 'dart:io';

import 'package:chat/common/repository/common_firebase_storage_repository.dart';
import 'package:chat/model/status_model.dart';
import 'package:chat/model/user_model.dart';
import 'package:chat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.phoneNumber!;
      String imageurl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            '/status/$statusId$uid',
            statusImage,
          );
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      List<String> uidWhoCanSee = [];

      for (int i = 0; i < contacts.length; i++) {
        print("checking ${contacts[i].phones[0].number}");
        var userDataFirebase = await firestore
            .collection('users')
            .where(
              'phone',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.phone);
        }
        print("whocansee");
        print(uidWhoCanSee);
      }

      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where(
            'uid',
            isEqualTo: auth.currentUser!.phoneNumber,
          )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageurl);
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageurl];
      }

      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      Contact contact = Contact(
        id: "2335",
        displayName: 'Denny jr',
        thumbnail: null,
        photo: null,
        isStarred: false,
        name: Name(first: 'Denny', last: 'jr'),
        phones: [
          Phone(
            '+918714257796',
            normalizedNumber: '+918714257796',
            label: PhoneLabel.mobile,
          ),
        ],
        // Add other properties as needed
        emails: [],
        addresses: [],
        organizations: [],
        websites: [],
        socialMedias: [],
        events: [],
        notes: [],
        accounts: [],
        groups: [],
      );
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      contacts.add(contact);
      contact = Contact(
        id: "2335",
        displayName: 'Avani',
        thumbnail: null,
        photo: null,
        isStarred: false,
        name: Name(first: 'Avani', last: ''),
        phones: [
          Phone(
            '+918590872528',
            normalizedNumber: '+918590872528',
            label: PhoneLabel.mobile,
          ),
        ],
        // Add other properties as needed
        emails: [],
        addresses: [],
        organizations: [],
        websites: [],
        socialMedias: [],
        events: [],
        notes: [],
        accounts: [],
        groups: [],
      );
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      contacts.add(contact);
      contact = Contact(
        id: "2335",
        displayName: 'Denny',
        thumbnail: null,
        photo: null,
        isStarred: false,
        name: Name(first: 'Denny', last: ''),
        phones: [
          Phone(
            '+917012719561',
            normalizedNumber: '+917012719561',
            label: PhoneLabel.mobile,
          ),
        ],
        // Add other properties as needed
        emails: [],
        addresses: [],
        organizations: [],
        websites: [],
        socialMedias: [],
        events: [],
        notes: [],
        accounts: [],
        groups: [],
      );
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      contacts.add(contact);
      contact = Contact(
        id: "2335",
        displayName: 'Sarath',
        thumbnail: null,
        photo: null,
        isStarred: false,
        name: Name(first: 'Sarath', last: ''),
        phones: [
          Phone(
            '+917356562246',
            normalizedNumber: '+91917356562246',
            label: PhoneLabel.mobile,
          ),
        ],
        // Add other properties as needed
        emails: [],
        addresses: [],
        organizations: [],
        websites: [],
        socialMedias: [],
        events: [],
        notes: [],
        accounts: [],
        groups: [],
      );
      // if (await FlutterContacts.requestPermission()) {
      //   contacts = await FlutterContacts.getContacts(withProperties: true);
      // }
      contacts.add(contact);
      for (int i = 0; i < contacts.length; i++) {
        print(contacts[i].phones[0].number);
        var statusesSnapshot = await firestore
            .collection('status')
            .where(
              'phoneNumber',
              isEqualTo: contacts[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          print(tempStatus.whoCanSee);
          if (tempStatus.whoCanSee.contains(auth.currentUser!.phoneNumber)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return statusData;
  }
}
