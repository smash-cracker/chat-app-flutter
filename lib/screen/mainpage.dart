// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:boxicons/boxicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/auth/class/chat/chat_controller.dart';
import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/name.dart';
import 'package:chat/auth/stories/screens/story_bar.dart';
import 'package:chat/main.dart';
import 'package:chat/model/group.dart';
import 'package:chat/screen/group_mobile_chat_screen.dart';
import 'package:chat/screen/mobile_chat_screen.dart';
import 'package:chat/screen/select_contacts.dart';
import 'package:chat/utils/chat_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final scrollController = ScrollController();
  File? cachedFile;
  String? token = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  void permissionCheck() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value;
        saveToken(token!);
      });
    });
  }

  void saveToken(String token) async {
    await _firestore.collection('userTokens').doc(user.phoneNumber).set({
      'token': token,
    });
  }

  @override
  void initState() {
    super.initState();
    permissionCheck();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> exitGroupFrom(
      String docId, String phoneNumber, DateTime newMessagesFrom) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('groups');

    DocumentSnapshot snapshot = await collection.doc(docId).get();
    if (!snapshot.exists) {
      print('Document does not exist');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;

    List<dynamic> list = data['membersUid'];

    for (int i = 0; i < list.length; i++) {
      if (list[i]['phone'] == phoneNumber) {
        list.removeAt(i);
        break;
      }
    }

    await collection.doc(docId).update({'membersUid': list});
  }

  Future<void> updateMessagesFrom(
      String docId, String phoneNumber, DateTime newMessagesFrom) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('groups');

    DocumentSnapshot snapshot = await collection.doc(docId).get();
    if (!snapshot.exists) {
      print('Document does not exist');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;

    List<dynamic> list = data['membersUid'];

    for (int i = 0; i < list.length; i++) {
      if (list[i]['phone'] == phoneNumber) {
        list[i]['messagesFrom'] = newMessagesFrom;
        break;
      }
    }

    await collection.doc(docId).update({'membersUid': list});
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
    print('changed app lifecycle state');
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed');
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
            return Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Color(0xFFEB455F),
                  rightDotColor: Color(0xFF2B3467),
                  size: 30),
            );
          }

          if (snapshot.data!.data() == null) {
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
            return Scaffold(
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
                    SizedBox(
                      width: 50,
                      child: Image(image: AssetImage('assets/hello.gif')),
                    )
                  ],
                ),
                actions: [
                  PopupMenuButton(
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
              body: CustomScrollView(controller: scrollController, slivers: [
                SliverAppBar(
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF8E8EE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      width: double.maxFinite,
                      child: Text(''),
                    ),
                  ),
                  expandedHeight: height * 0.15,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8, bottom: 18),
                      child: SizedBox(
                        child: StatusBar(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8E8EE),
                    ),
                    child: StreamBuilder<List<Group>>(
                        stream: ref.watch(chatControllerProvider).chatGroups(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }

                          return ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var groupData = snapshot.data![index];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 6.0,
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: InkWell(
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
                                      child: Slidable(
                                        startActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              label: 'Exit group',
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(
                                                  10,
                                                ),
                                              ),
                                              onPressed: ((context) {
                                                exitGroupFrom(
                                                    groupData.groupId,
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .phoneNumber!,
                                                    DateTime.now());
                                              }),
                                              backgroundColor:
                                                  const Color(0xFFF8E8EE),
                                              icon: Boxicons.bx_door_open,
                                            ),
                                          ],
                                        ),
                                        endActionPane: ActionPane(
                                          motion: const StretchMotion(),
                                          children: [
                                            SlidableAction(
                                              label: 'clear group',
                                              onPressed: ((context) {
                                                updateMessagesFrom(
                                                    groupData.groupId,
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .phoneNumber!,
                                                    DateTime.now());
                                              }),
                                              backgroundColor:
                                                  const Color(0xFFF8E8EE),
                                              icon: Icons.delete,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 253, 244, 248),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4.0, top: 4),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                bottom: 4,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            groupData
                                                                .lastMessage,
                                                          )),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(DateFormat.Hm()
                                                          .format(groupData
                                                              .timeSent)),
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
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8E8EE),
                    ),
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

                        if (snapshots.data!.docs.length == 0) {
                          return Container(
                            height: height * 0.85,
                            decoration: BoxDecoration(
                              color: Color(0xFFfefefe),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(image: AssetImage('assets/emptyt.png')),
                                  Text('No personal found'),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshots.data!.docs.length,
                          controller: scrollController,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(snapshots.data!.docs[index]
                                        ['contactID'])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    var recieverData = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => MobileChatScreen(
                                              name: recieverData['name'],
                                              uid: recieverData['phone'],
                                              profilePic: recieverData['dp'],
                                              isGroupChat: false,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ChatBox(
                                        data: snapshots.data!.docs[index],
                                        chatContactData: recieverData,
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ]),
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
