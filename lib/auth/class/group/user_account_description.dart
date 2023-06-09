// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:chat/auth/class/group/add_group_members.dart';
import 'package:chat/auth/class/group/group_controller.dart';
import 'package:chat/utils/contact_box.dart';
import 'package:chat/utils/members_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAccountDescription extends ConsumerStatefulWidget {
  List<Map<String, dynamic>> contactList;
  final String groupName;
  final String image;
  final String groupId;
  UserAccountDescription({
    super.key,
    required this.groupId,
    required this.contactList,
    required this.groupName,
    required this.image,
  });

  @override
  ConsumerState<UserAccountDescription> createState() =>
      _UserAccountDescription();
}

class _UserAccountDescription extends ConsumerState<UserAccountDescription> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchName = '';
  List<Contact> selectedContacts = [];
  int counter = 1;
  int resMod = 1;

  int generateRandomNumber() {
    resMod = counter % 6;
    if (resMod == 0) {
      resMod = 7;
    }
    counter += 1;
    return resMod;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        extendBody: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(top: 8.0),
                //   child: Text(
                //     'New Message',
                //     style: TextStyle(
                //       fontSize: width * 0.06,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: height * 0.2,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.pink[100],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: height * 0.04,
                        left: width * 0.25,
                        child: Container(
                          // color: Colors.red,
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: 150,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.pink[300],
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 47,
                                  backgroundImage: NetworkImage(widget.image),
                                ),
                                Text(
                                  widget.groupName,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Container(
                  height: height * 0.08,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.pink[100],
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // TextSpan(
                        //   text:
                        //       ' ${widget.contactList.length.toString()} members',
                        //   style: TextStyle(
                        //     color: Colors.black,
                        //   ),
                        // ),
                      ]),
                    ),
                  ),
                ),

                // SizedBox(
                //     height: height * 0.8,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         SizedBox(
                //           height: 15,
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               'Members',
                //               style: TextStyle(
                //                 fontWeight: FontWeight.w700,
                //               ),
                //             ),
                //             IconButton(
                //                 onPressed: () {
                //                   Navigator.of(context).push(MaterialPageRoute(
                //                       builder: (_) => AddGroupMembers(
                //                             groupId: widget.groupId,
                //                             groupName: widget.groupName,
                //                             image: widget.image,
                //                           )));
                //                 },
                //                 icon: Icon(
                //                   CupertinoIcons.person_crop_circle_badge_plus,
                //                 ))
                //           ],
                //         ),
                //         SizedBox(
                //           height: 15,
                //         ),
                //         Expanded(
                //           child: ListView.builder(
                //             itemCount: widget.contactList.length,
                //             itemBuilder: (context, index) {
                //               int randomNumber = generateRandomNumber();

                //               // final contact = widget.contactList[index];
                //               // String selectedContactStringNumber =
                //               //     contact.phones[0].number.replaceAll(' ', '');
                //               // if (!selectedContactStringNumber.startsWith('+91')) {
                //               //   selectedContactStringNumber =
                //               //       '+91$selectedContactStringNumber';
                //               // }
                //               if (true) {
                //                 return InkWell(
                //                   onLongPress: () async {
                //                     String phoneNumber =
                //                         widget.contactList[index]['phone'];
                //                     String groupId = widget.groupId;
                //                     print(phoneNumber);
                //                     await _firestore
                //                         .collection('groups')
                //                         .doc(groupId)
                //                         .update({
                //                       'membersUid': FieldValue.arrayRemove([
                //                         {
                //                           'name': widget.contactList[index]
                //                               ['name'],
                //                           'phone': phoneNumber,
                //                         },
                //                       ]),
                //                     }).then((_) {
                //                       return ScaffoldMessenger.of(context)
                //                           .showSnackBar(
                //                         SnackBar(
                //                           content: Text('Member removed'),
                //                         ),
                //                       );
                //                     }).catchError((error) {
                //                       print(error.toString());
                //                     });
                //                   },
                //                   child: MembersBox(
                //                     name: widget.contactList[index]['name'],
                //                     number: widget.contactList[index]['phone'],
                //                     group: true,
                //                     randomNumber: randomNumber,
                //                   ),
                //                 );
                //               }
                //             },
                //           ),
                //         ),
                //       ],
                //     )),
                // ...groupedContactWidgets,
              ],
            ),
          ),
        ),
        // bottomNavigationBar: Padding(
        //   padding: EdgeInsets.symmetric(
        //       vertical: 8.0, horizontal: MediaQuery.of(context).size.width * 0.1),
        //   child: Container(
        //     margin: const EdgeInsets.only(bottom: 10.0),
        //     padding: const EdgeInsets.all(8.0),
        //     decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(30),
        //         color: Colors.pink[300],
        //         boxShadow: [
        //           // BoxShadow(
        //           //   color: Color.fromARGB(255, 185, 184, 184),
        //           //   spreadRadius: 0,
        //           //   blurRadius: 4,
        //           // )
        //         ]),
        //     child:
        //         GestureDetector(onTap:
        //         CreateGroup, child: Text('Create group')),
        //   ),
        // ),
      ),
    );
  }
}
