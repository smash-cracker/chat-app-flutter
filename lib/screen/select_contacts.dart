// ignore_for_file: prefer_const_constructors

import 'package:chat/auth/class/group/group_name.dart';
import 'package:chat/auth/select_contacts/controller/select_contacts_controller.dart';
import 'package:chat/utils/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/contact_box.dart';

class SelectContact extends ConsumerStatefulWidget {
  SelectContact({super.key});

  @override
  ConsumerState<SelectContact> createState() => _SelectContactState();
}

class _SelectContactState extends ConsumerState<SelectContact> {
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

  String searchName = '';

  void selectContact(WidgetRef ref, Contact contact, BuildContext context) {
    ref.read(selectContactControllerProvider).selectContact(contact, context);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      searchName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
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
            data: (contactList) {
              setState(() {});
              // Map<String, List<Contact>> groupedContacts = {};
              // contactList.forEach((contact) {
              //   String firstLetter =
              //       contact.displayName.substring(0, 1).toUpperCase();
              //   if (!groupedContacts.containsKey(firstLetter)) {
              //     groupedContacts[firstLetter] = [contact];
              //   } else {
              //     groupedContacts[firstLetter]!.add(contact);
              //   }
              // });
              // List<Widget> groupedContactWidgets = [];

              // groupedContacts.forEach((letter, contacts) {
              //   groupedContactWidgets.addAll([
              //     SizedBox(height: 20),
              //     SizedBox(
              //       height: height * 0.05,
              //       child: Padding(
              //         padding: const EdgeInsets.only(left: 10.0),
              //         child: Text(letter),
              //       ),
              //     ),
              //   ]);
              //   groupedContactWidgets.addAll(
              //     contacts
              //         .map((contact) => ContactBox(name: contact.displayName)),
              //   );
              // });
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'New Message',
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => GroupName(
                                    contactList: contactList,
                                  )));
                        },
                        child: Container(
                          height: height * 0.08,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.pink[300],
                          ),
                          child: Center(child: Text('Create new group chat')),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          height: height * 0.8,
                          child: ListView.builder(
                            itemCount: contactList.length,
                            itemBuilder: (context, index) {
                              int randomNumber = generateRandomNumber();

                              final contact = contactList[index];
                              if (contact.phones.isNotEmpty) {
                                String selectedContactStringNumber = contact
                                    .phones[0].number
                                    .replaceAll(' ', '');
                                if (!selectedContactStringNumber
                                    .startsWith('+91')) {
                                  selectedContactStringNumber =
                                      '+91$selectedContactStringNumber';
                                }

                                if (searchName == '' ||
                                    contact.displayName
                                        .toLowerCase()
                                        .contains(searchName)) {
                                  return InkWell(
                                    onTap: () {
                                      selectContact(ref, contact, context);
                                    },
                                    child: ContactBox(
                                      name: contact.displayName,
                                      number: selectedContactStringNumber,
                                      randomNumber: randomNumber,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          )),
                      // ...groupedContactWidgets,
                    ],
                  ),
                ),
              );
            },
            error: (err, trace) {
              print(err.toString());
            },
            loading: () => Loader(),
          ),
    );
  }
}
