// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/auth/class/controller.dart';
import 'package:chat/auth/class/group/group_description.dart';
import 'package:chat/auth/class/group/user_account_description.dart';
import 'package:chat/auth/video/call_controller.dart';
import 'package:chat/model/user_model.dart';
import 'package:chat/screen/bottom_send.dart';
import 'package:chat/screen/call_pickup_screen.dart';
import 'package:chat/utils/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/colors.dart';

class MobileChatScreen extends ConsumerWidget {
  File? cachedFile;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          false,
        );
  }

  // Delete the document with the provided ID
  void deleteDocument(String documentId, BuildContext context) async {
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection('chats')
        .doc(documentId)
        .delete()
        .then((_) {
      Navigator.of(context).pop();
      print('Document deleted successfully');
    }).catchError((error) {
      print('Failed to delete document: $error');
    });
  }

  final String name;
  final String uid;
  final String profilePic;
  final bool isGroupChat;
  final List<Map<String, dynamic>> members;
  MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.isGroupChat,
    this.members = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.black,
              ),
            ),
          ),
          title: isGroupChat
              ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      ConcentricPageRoute(
                        builder: (_) => GroupDescription(
                          contactList: members,
                          groupName: name,
                          image: profilePic,
                          groupId: uid,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.zero,
                        child: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            profilePic,
                            cacheManager: DefaultCacheManager(),
                          ),
                          radius: 20,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.4,
                            child: Text(
                              name.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink[100],
                            radius: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                name.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '',
                                style: TextStyle(color: Colors.green[300]),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          ConcentricPageRoute(
                            builder: (_) => UserAccountDescription(
                              contactList: [],
                              groupName: name,
                              image: profilePic,
                              groupId: uid,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(profilePic),
                            radius: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                name.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                snapshot.data!.isOnline ? 'online' : 'offline',
                                style: TextStyle(color: Colors.green[300]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
          centerTitle: true,
          toolbarHeight: 60,
          actions: [
            IconButton(
              onPressed: () {
                makeCall(ref, context);
              },
              icon: const Icon(
                CupertinoIcons.video_camera,
                color: Colors.black,
              ),
            ),
            PopupMenuButton(
              // color: Colors.black,
              shadowColor: Colors.white,
              icon: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Clear chat'),
                  onTap: () {
                    // signOut(context);
                    deleteDocument(uid, context);
                  },
                ),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/chat_bg.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ChatList(
                  recieverUserId: uid,
                  isGroupChat: isGroupChat,
                ),
              ),
              BottomSendField(
                recieverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
