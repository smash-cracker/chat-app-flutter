// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chat/auth/video/call_controller.dart';
import 'package:chat/model/call.dart';
import 'package:chat/screen/call_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  const CallPickupScreen({super.key, required this.scaffold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {
            print("called");
            return Scaffold(
              body: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('incoming call'),
                  SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(call.callerPic),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(call.callerName),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => CallScreen(
                                      channelId: call.callId,
                                      call: call,
                                      isGroupChat: false,
                                    )),
                          );
                        },
                        icon: Icon(Icons.call),
                        color: Colors.green,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.call_end),
                        color: Colors.red,
                      )
                    ],
                  ),
                ],
              )),
            );
          }
        }
        return scaffold;
      },
    );
  }
}
