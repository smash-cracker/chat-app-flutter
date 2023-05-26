import 'package:chat/model/user_model.dart';
import 'package:chat/screen/mobile_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

final selectContactRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;
  SelectContactRepository({required this.firestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      print(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact contact, BuildContext context) async {
    try {
      final userCollection = await firestore.collection('users').get();
      bool exists = false;
      for (var doc in userCollection.docs) {
        var userData = UserModel.fromMap(doc.data());
        String selectedContactStringNumber =
            contact.phones[0].number.replaceAll(' ', '');
        if (!selectedContactStringNumber.startsWith('+91')) {
          selectedContactStringNumber = '+91$selectedContactStringNumber';
        }
        if (userData.phone == selectedContactStringNumber) {
          exists = true;
          // Navigator.push(
          //     context,
          //     PageTransition(
          //         child: MobileChatScreen(
          //           name: userData.name,
          //           uid: userData.phone,
          //         ),
          //         type: PageTransitionType.leftToRight));
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MobileChatScreen(
                    profilePic: userData.dp,
                    name: userData.name,
                    uid: userData.phone,
                    isGroupChat: false,
                  )));
        }
        if (!exists) {
          print("user doesn't exist");
        }
      }
    } catch (e) {
      print("user doesnot have an account");
    }
  }
}
