import 'package:chat/auth/class/chat/chat_controller.dart';
import 'package:chat/common/providers/message_reply_provider.dart';
import 'package:chat/model/message.dart';
import 'package:chat/utils/enum/message_enum.dart';
import 'package:chat/utils/info.dart';
import 'package:chat/utils/loader.dart';
import 'package:chat/utils/my_message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'sender_message_card.dart';

class ChatListForGroup extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  final Timestamp messageFrom;
  ChatListForGroup({
    required this.recieverUserId,
    required this.isGroupChat,
    required this.messageFrom,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatListForGroupState();
}

class _ChatListForGroupState extends ConsumerState<ChatListForGroup> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.state).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.recieverUserId)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });

          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              if (!messageData.isSeen &&
                  messageData.recieverID ==
                      FirebaseAuth.instance.currentUser!.phoneNumber) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                      context,
                      widget.recieverUserId,
                      messageData.messageID,
                    );
              }
              print(messageData.text);
              print(messageData.timeSent);
              print(widget.messageFrom.toDate());
              print(messageData.timeSent.isAfter(widget.messageFrom.toDate()));
              if (messageData.timeSent.isAfter(widget.messageFrom.toDate())) {
                if (messageData.senderID ==
                    FirebaseAuth.instance.currentUser!.phoneNumber) {
                  return MyMessageCard(
                    fromGroup: true,
                    message: messageData.text,
                    date: DateFormat('Hm').format(messageData.timeSent),
                    type: messageData.type,
                    repliedText: messageData.repliedMessage,
                    username: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onLeftSwipe: () => onMessageSwipe(
                      messageData.text,
                      true,
                      messageData.type,
                    ),
                    isSeen: messageData.isSeen,
                  );
                }
                return SenderMessageCard(
                  fromGroup: true,
                  message: messageData.text,
                  date: DateFormat('Hm').format(messageData.timeSent),
                  type: messageData.type,
                  senderName: messageData.senderName,
                  username: messageData.repliedTo,
                  repliedMessageType: messageData.repliedMessageType,
                  onRightSwipe: () => onMessageSwipe(
                    messageData.text,
                    false,
                    messageData.type,
                  ),
                  repliedText: messageData.repliedMessage,
                );
              } else {
                return Container();
              }
            },
          );
        });
  }
}
