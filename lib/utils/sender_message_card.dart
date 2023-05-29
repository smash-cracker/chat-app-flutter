// ignore_for_file: prefer_const_constructors
import 'package:chat/utils/display_file.dart';
import 'package:chat/utils/enum/message_enum.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.onRightSwipe,
    required this.repliedText,
    required this.username,
    required this.senderName,
    required this.repliedMessageType,
  }) : super(key: key);
  final String message;
  final String date;
  final String senderName;
  final MessageEnum type;

  final VoidCallback onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  @override
  Widget build(BuildContext context) {
    bool isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Column(
            children: [
              Card(
                elevation: 0.2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  children: [
                    Text(senderName),
                    Stack(
                      children: [
                        Padding(
                          padding: type == MessageEnum.text
                              ? const EdgeInsets.only(
                                  left: 10,
                                  right: 30,
                                  top: 15,
                                  bottom: 20,
                                )
                              : const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              if (isReplying) ...[
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 35,
                                      color: Colors.green,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 224, 129, 161),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: DisplayTextImageGif(
                                        message: repliedText,
                                        type: repliedMessageType,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                )
                              ],
                              DisplayTextImageGif(
                                message: message,
                                type: type,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 10,
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
