// ignore_for_file: prefer_const_constructors

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
    return Scaffold(
      body: FutureBuilder<List<Status>>(
          future: ref.read(statusControllerProvider).getStatus(context),
          builder: (context, snapshot) {
            print("snapshot.data");
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            }
            print("snapshot.data!.length");
            print(snapshot.data!.length);
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == (snapshot.data!.length)) {
                  return GestureDetector(
                    onTap: () async {
                      if (index == (snapshot.data!.length + 1)) {
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
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/G0.jpeg'),
                        radius: 30,
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
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(statusData.profilePic),
                        radius: 30,
                      ),
                    ),
                  );
                }
              },
            );
          }),
    );
  }
}
