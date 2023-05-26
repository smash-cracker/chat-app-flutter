// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:chat/auth/stories/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmStory extends ConsumerWidget {
  const ConfirmStory({
    super.key,
    required this.file,
  });
  final File file;

  void addStatus(WidgetRef ref, BuildContext context) {
    ref.read(statusControllerProvider).addStatus(file, context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[200],
        onPressed: () => addStatus(ref, context),
        child: Icon(
          Icons.done,
        ),
      ),
    );
  }
}
