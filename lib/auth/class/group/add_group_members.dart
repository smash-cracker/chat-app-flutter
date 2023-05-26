// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:chat/auth/class/group/group_controller.dart';
import 'package:chat/auth/select_contacts/controller/select_contacts_controller.dart';
import 'package:chat/utils/contact_box.dart';
import 'package:chat/utils/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddGroupMembers extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String image;
  AddGroupMembers(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.image});

  @override
  ConsumerState<AddGroupMembers> createState() => _AddGroupMembersState();
}

class _AddGroupMembersState extends ConsumerState<AddGroupMembers> {
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

  void AddMembers() {
    print(selectedContacts);
    ref.read(groupControllerProvider).AddGroupMembers(
          context,
          widget.groupId,
          selectedContacts,
        );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        title: SizedBox(
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
      ),
      body: ref.read(getContactsProvider).when(
            data: (contactsList) {
              setState(() {});
              return SafeArea(
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
                                        backgroundImage:
                                            NetworkImage(widget.image)),
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
                          height: 20,
                        ),
                        SizedBox(
                            height: height * 0.8,
                            child: ListView.builder(
                              itemCount: contactsList.length,
                              itemBuilder: (context, index) {
                                int randomNumber = generateRandomNumber();

                                final contact = contactsList[index];
                                String selectedContactStringNumber = contact
                                    .phones[0].number
                                    .replaceAll(' ', '');
                                if (!selectedContactStringNumber
                                    .startsWith('+91')) {
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
                                      selected:
                                          selectedContacts.contains(contact),
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
              );
            },
            error: (err, trace) {
              print(err.toString());
            },
            loading: () => Loader(),
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
          child: GestureDetector(onTap: AddMembers, child: Text('Add members')),
        ),
      ),
    );
  }
}
