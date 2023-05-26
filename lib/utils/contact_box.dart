// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class ContactBox extends StatefulWidget {
  final String name;
  final String number;
  final bool group;
  final bool selected;
  final int randomNumber;
  const ContactBox({
    super.key,
    required this.name,
    required this.number,
    this.group = false,
    this.selected = false,
    required this.randomNumber,
  });

  @override
  State<ContactBox> createState() => _ContactBoxState();
}

class _ContactBoxState extends State<ContactBox> {
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
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.number),
                  ],
                ),
              ],
            ),
            widget.group
                ? MSHCheckbox(
                    size: 30,
                    value: widget.selected,
                    colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                      checkedColor: Colors.pink[300],
                    ),
                    style: MSHCheckboxStyle.fillFade,
                    onChanged: (selected) {
                      // setState(() {
                      //   isChecked = selected;
                      // });
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
