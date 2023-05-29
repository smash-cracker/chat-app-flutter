import 'dart:io';

import 'package:chat/common/providers/message_reply_provider.dart';
import 'package:chat/common/repository/common_firebase_storage_repository.dart';
import 'package:chat/model/chat_contact.dart';
import 'package:chat/model/group.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user_model.dart';
import 'package:chat/utils/enum/message_enum.dart';
import 'package:chat/utils/info.dart';
import 'package:chat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  Stream<List<ChatContact>> getChatContacts() {
    print('running');
    ChatContact chatContact;
    List<ChatContact> contacts = [];

    UserModel user;
    return firestore
        .collection('users')
        .doc(auth.currentUser!.phoneNumber)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      for (var document in event.docs) {
        chatContact = ChatContact.fromMap(document.data());

        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactID)
            .get();
        user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.dp,
            contactID: chatContact.contactID,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserID) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.phoneNumber)
        .collection('chats')
        .doc(recieverUserID)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var doc in event.docs) {
        messages.add(Message.fromMap(doc.data()));
      }
      return messages;
    });
  }

  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        print("document.data()");
        print(document.data());
        var group = Group.fromMap(document.data());
        print("group");
        print(group);
        for (var x in group.membersUid) {
          if (x['phone'] == auth.currentUser!.phoneNumber) {
            groups.add(group);
          }
        }
        print("groups");
        print(groups);
      }
      return groups;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groudId) {
    return firestore
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      print("messages");
      print(messages);
      return messages;
    });
  }

  void _saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserID,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(recieverUserID).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.dp,
        contactID: senderUserData.phone,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(recieverUserID)
          .collection('chats')
          .doc(auth.currentUser!.phoneNumber)
          .set(recieverChatContact.toMap());

      // sender user id
      var senderChatContact = ChatContact(
        name: recieverUserData!.name,
        profilePic: recieverUserData.dp,
        contactID: recieverUserData.phone,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('users')
          .doc(auth.currentUser!.phoneNumber)
          .collection('chats')
          .doc(recieverUserID)
          .set(senderChatContact.toMap());
    }
  }
  // reciever user id

  void _saveMessageToMessageSubCollection({
    required String recieverUserID,
    required String text,
    required DateTime timeSent,
    required String messageID,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderID: auth.currentUser!.phoneNumber!,
      recieverID: recieverUserID,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageID: messageID,
      isSeen: false,
      senderName: senderUsername,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(recieverUserID)
          .collection('chats')
          .doc(messageID)
          .set(message.toMap());
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.phoneNumber)
          .collection('chats')
          .doc(recieverUserID)
          .collection('messages')
          .doc(messageID)
          .set(message.toMap());

      await firestore
          .collection('users')
          .doc(recieverUserID)
          .collection('chats')
          .doc(auth.currentUser!.phoneNumber)
          .collection('messages')
          .doc(messageID)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      final timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      final messageID = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubCollection(
        recieverUserID: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageID: messageID,
        recieverUserName: recieverUserData?.name,
        username: senderUser.name,
        messageReply: messageReply,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserID,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.phone}/$recieverUserID/$messageId',
            file,
          );
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserID).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 photo';
          break;
        case MessageEnum.video:
          contactMsg = '📹 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎙️ Audio';
          break;
        case MessageEnum.gif:
          contactMsg = '👾 Gif';
          break;
        default:
          contactMsg = '👾 Gif';
      }

      _saveDataToContactsSubCollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserID,
        isGroupChat,
      );

      _saveMessageToMessageSubCollection(
        recieverUserID: recieverUserID,
        text: imageUrl,
        timeSent: timeSent,
        messageID: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (r) {
      print(r.toString());
    }
  }

  void sendGifMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      final timeSent = DateTime.now();
      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      final messageID = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        '👾 GIF',
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubCollection(
        recieverUserID: recieverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageID: messageID,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.phoneNumber)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.phoneNumber)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
