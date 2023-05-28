// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBox extends StatefulWidget {
  ChatBox({
    super.key,
    required this.chatContactData,
    required this.data,
  });
  var chatContactData;
  var data;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 10,
        right: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 253, 244, 248),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(
          8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                widget.chatContactData['dp'],
              ),
              backgroundColor: Color.fromARGB(255, 253, 244, 248),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.04,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatContactData['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(widget.data['lastMessage'])),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('Hm').format(widget.data['timeSent'].toDate())),
                Icon(
                  Icons.done_all,
                  color: Colors.green[300],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
