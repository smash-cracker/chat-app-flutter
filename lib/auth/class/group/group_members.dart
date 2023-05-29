// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:chat/auth/class/group/group_controller.dart';
import 'package:chat/utils/contact_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GroupMembers extends ConsumerStatefulWidget {
  var contactList;
  final String groupName;

  final File image;
  GroupMembers(
      {super.key,
      required this.contactList,
      required this.groupName,
      required this.image});

  @override
  ConsumerState<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends ConsumerState<GroupMembers> {
  String searchName = '';
  List<Contact> selectedContacts = [];
  int counter = 1;
  int resMod = 1;
  bool isloading = false;

  int generateRandomNumber() {
    resMod = counter % 6;
    if (resMod == 0) {
      resMod = 7;
    }
    counter += 1;
    return resMod;
  }

  Future<String> CreateGroup() async {
    String res = "error";
    setState(() {
      isloading = true;
    });
    ref.read(groupControllerProvider).createGroup(
          context,
          widget.groupName,
          widget.image,
          selectedContacts,
        );

    setState(() {
      isloading = false;
    });
    res = "success";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
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
                          width: 150,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                                radius: 47,
                                backgroundImage: FileImage(widget.image)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.03,
                        left: width * 0.43,
                        child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage(
                                'assets/G1.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.04,
                        left: width * 0.07,
                        child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage(
                                'assets/G2.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.03,
                        left: width * 0.6,
                        child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage(
                                'assets/G3.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.13,
                        left: width * 0.007,
                        child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage(
                                'assets/G4.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.13,
                        left: width * 0.43,
                        child: Container(
                          width: 150,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink[300],
                            child: CircleAvatar(
                              radius: 19,
                              backgroundImage: AssetImage(
                                'assets/G5.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: width * 0.7,
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      print(value);
                      print('value');
                      setState(() {
                        searchName = value.toLowerCase();
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: height * 0.8,
                    child: ListView.builder(
                      itemCount: widget.contactList.length,
                      itemBuilder: (context, index) {
                        int randomNumber = generateRandomNumber();

                        final contact = widget.contactList[index];
                        String selectedContactStringNumber =
                            contact.phones[0].number.replaceAll(' ', '');
                        if (!selectedContactStringNumber.startsWith('+91')) {
                          selectedContactStringNumber =
                              '+91$selectedContactStringNumber';
                        }
                        if (contact.displayName
                            .toLowerCase()
                            .contains(searchName)) {
                          print('huh');
                          return InkWell(
                            onTap: () {
                              if (selectedContacts.contains(contact)) {
                                setState(() {
                                  selectedContacts.remove(contact);
                                });
                              } else {
                                setState(() {
                                  selectedContacts.add(contact);
                                });
                              }
                            },
                            child: ContactBox(
                              name: contact.displayName,
                              number: selectedContactStringNumber,
                              group: true,
                              selected: selectedContacts.contains(contact),
                              randomNumber: randomNumber,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    )),
                // ...groupedContactWidgets,
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 8.0, horizontal: MediaQuery.of(context).size.width * 0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.pink[300],
              boxShadow: [
                // BoxShadow(
                //   color: Color.fromARGB(255, 185, 184, 184),
                //   spreadRadius: 0,
                //   blurRadius: 4,
                // )
              ]),
          child: GestureDetector(
            onTap: () async {
              String x = await CreateGroup();
              if (x == "success") {
                Navigator.of(context).popUntil((route) => route.isFirst);
                final snackBar = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'Yay',
                    message: 'Group created.',

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.success,
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              } else {
                final snackBar = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'uh oh',
                    message: 'fill details correctly.',

                    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                    contentType: ContentType.failure,
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: isloading
                      ? LoadingAnimationWidget.flickr(
                          leftDotColor: Color(0xFFEB455F),
                          rightDotColor: Color(0xFF2B3467),
                          size: 30)
                      : Text(
                          'Create group',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
