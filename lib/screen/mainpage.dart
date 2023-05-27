// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/auth/class/chat/chat_controller.dart';
import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/name.dart';
import 'package:chat/auth/stories/screens/story_bar.dart';
import 'package:chat/main.dart';
import 'package:chat/model/chat_contact.dart';
import 'package:chat/model/group.dart';
import 'package:chat/screen/call_pickup_screen.dart';
import 'package:chat/screen/group_mobile_chat_screen.dart';
import 'package:chat/screen/mobile_chat_screen.dart';
import 'package:chat/screen/select_contacts.dart';
import 'package:chat/utils/chat_box.dart';
import 'package:chat/utils/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? cachedFile;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyApp()));
    } catch (error) {
      print('Sign-out failed: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final currentHour = currentTime.hour;

    String greeting;

    if (currentHour >= 0 && currentHour < 12) {
      greeting = 'Good morning,';
    } else if (currentHour >= 12 && currentHour < 17) {
      greeting = 'Good afternoon,';
    } else {
      greeting = 'Good evening,';
    }
    final height = MediaQuery.of(context).size.height;
    if (auth.currentUser != null) {
      final phoneNumber = auth.currentUser!.phoneNumber;
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: LoadingAnimationWidget.flickr(
                    leftDotColor: Color(0xFFEB455F),
                    rightDotColor: Color(0xFF2B3467),
                    size: 30),
              ),
            );
          }
          print(snapshot.data!.data());
          print("snapshot.data");
          if (snapshot.data!.data() == null) {
            // Navigator.popUntil(context, (route) => route.isFirst);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Name(
                            phone:
                                FirebaseAuth.instance.currentUser!.phoneNumber!,
                          )));
            });
          }

          if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return CallPickupScreen(
              scaffold: Scaffold(
                backgroundColor: Color(0xFFf7f1f7),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Color(0xFFf7f1f7),
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          data['dp'],
                          cacheManager: DefaultCacheManager(),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${data["name"]}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    PopupMenuButton(
                      // color: Colors.black,
                      shadowColor: Colors.white,
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text('Log Out'),
                          onTap: () {
                            signOut(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: height * 0.15,
                          child: StatusBar(),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFfefefe),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: StreamBuilder<List<Group>>(
                            stream:
                                ref.watch(chatControllerProvider).chatGroups(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var groupData = snapshot.data![index];

                                  print("groupData");
                                  print(groupData.membersUid);
                                  print("groupData");

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  GroupMobileChatScreen(
                                                name: groupData.name,
                                                members: groupData.membersUid,
                                                uid: groupData.groupId,
                                                profilePic: groupData.groupPic,
                                                isGroupChat: true,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    groupData.groupPic,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      groupData.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        child: Text(
                                                          groupData.lastMessage,
                                                        )),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(DateFormat.Hm().format(
                                                        groupData.timeSent)),
                                                    Text(''),
                                                    // Icon(
                                                    //   Icons.done_all,
                                                    //   color: Colors.green[300],
                                                    // ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // InkWell(
                                      //   onTap: () {
                                      //     print('pressed');
                                      //     Navigator.of(context).push(
                                      //       MaterialPageRoute(
                                      //         builder: (_) => MobileChatScreen(
                                      //           name: groupData.name,
                                      //           uid: groupData.groupId,
                                      //           profilePic: groupData.groupPic,
                                      //           isGroupChat: true,
                                      //         ),
                                      //       ),
                                      //     );
                                      //   },
                                      //   child: Padding(
                                      //     padding:
                                      //         const EdgeInsets.only(bottom: 8.0),
                                      //     child: ListTile(
                                      //       title: Text(
                                      //         groupData.name,
                                      //         style: const TextStyle(
                                      //           fontSize: 18,
                                      //         ),
                                      //       ),
                                      //       subtitle: Padding(
                                      //         padding:
                                      //             const EdgeInsets.only(top: 6.0),
                                      //         child: Text(
                                      //           groupData.lastMessage,
                                      //           style:
                                      //               const TextStyle(fontSize: 15),
                                      //         ),
                                      //       ),
                                      //       leading: CircleAvatar(
                                      //         backgroundImage:
                                      //             CachedNetworkImageProvider(
                                      //           groupData.groupPic,
                                      //         ),
                                      //         radius: 30,
                                      //       ),
                                      //       trailing: Text(
                                      //         DateFormat.Hm()
                                      //             .format(groupData.timeSent),
                                      //         style: const TextStyle(
                                      //           color: Colors.grey,
                                      //           fontSize: 13,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // const Divider(
                                      //     color: dividerColor, indent: 85),
                                    ],
                                  );
                                },
                              );
                            }),
                      ),
                      Container(
                        color: Color(0xFFfefefe),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(auth.currentUser!.phoneNumber)
                              .collection('chats')
                              .orderBy('timeSent', descending: true)
                              .snapshots(),
                          builder: (context, snapshots) {
                            if (snapshots.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.flickr(
                                    leftDotColor: Color(0xFFEB455F),
                                    rightDotColor: Color(0xFF2B3467),
                                    size: 30),
                              );
                            }
                            return SizedBox(
                              height: 500,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: snapshots.data!.docs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        print(snapshots.data!.docs.length);
                                        return SizedBox(
                                          child:
                                              FutureBuilder<DocumentSnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(snapshots.data!.docs[index]
                                                    ['contactID'])
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                var recieverData =
                                                    snapshot.data!.data()
                                                        as Map<String, dynamic>;
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            MobileChatScreen(
                                                          name: recieverData[
                                                              'name'],
                                                          uid: recieverData[
                                                              'phone'],
                                                          profilePic:
                                                              recieverData[
                                                                  'dp'],
                                                          isGroupChat: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: ChatBox(
                                                    data: snapshots
                                                        .data!.docs[index],
                                                    chatContactData:
                                                        recieverData,
                                                  ),
                                                );
                                              }
                                              return Container();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.pink[300],
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SelectContact(),
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.conversation_bubble,
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Color(0xFFEB455F),
                  rightDotColor: Color(0xFF2B3467),
                  size: 30),
            );
          }
        },
      );
    } else {
      return Container();
    }
  }
}
