// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class MembersBox extends StatefulWidget {
  final String name;
  final String number;
  final bool group;
  final int randomNumber;
  final bool admin;
  const MembersBox({
    super.key,
    required this.name,
    required this.number,
    this.group = false,
    required this.randomNumber,
    this.admin = false,
  });

  @override
  State<MembersBox> createState() => _Membersate();
}

class _Membersate extends State<MembersBox> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.05),
      child: Container(
        padding: EdgeInsets.only(
          top: 4,
        ),
        child: Row(
          mainAxisAlignment: widget.group
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.pink[300],
                  child: CircleAvatar(
                    radius: 27,
                    backgroundImage: AssetImage(
                      'assets/G${widget.randomNumber}.png',
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.04,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        widget.admin
                            ? Chip(
                                backgroundColor: Colors.green[300],
                                label: Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    Text(widget.number),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
