// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:chat/auth/stories/screens/upload_confirm.dart';
import 'package:chat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              if (index == 0) {
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
        },
      ),
    );
  }
}
