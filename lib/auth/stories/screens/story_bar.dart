// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:chat/auth/stories/controller.dart';
import 'package:chat/auth/stories/screens/upload_confirm.dart';
import 'package:chat/model/status_model.dart';
import 'package:chat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'status_screen.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Status>>(
        future: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == (snapshot.data!.length)) {
                return GestureDetector(
                  onTap: () async {
                    print('click');
                    if (index == (snapshot.data!.length)) {
                      File? pickedImage = await pickImageFromGallery(context);
                      if (pickedImage != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ConfirmStory(
                                  file: pickedImage,
                                )));
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage('assets/G0.jpeg'),
                              radius: 30,
                              backgroundColor:
                                  Color.fromARGB(255, 253, 244, 248),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              'Add story',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                final statusData = snapshot.data![index];
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => StatusScreen(
                              status: statusData,
                            )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1,
                                    color: Color.fromARGB(255, 253, 244, 248),
                                    spreadRadius: 3,
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(statusData.profilePic),
                                radius: 30,
                                backgroundColor:
                                    Color.fromARGB(255, 253, 244, 248),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              statusData.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        });
  }
}
