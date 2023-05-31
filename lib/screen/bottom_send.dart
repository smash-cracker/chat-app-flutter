// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:chat/auth/class/chat/chat_controller.dart';
import 'package:chat/auth/class/chat/chat_repo.dart';
import 'package:chat/common/providers/message_reply_provider.dart';
import 'package:chat/utils/enum/message_enum.dart';
import 'package:chat/utils/message_reply_preview.dart';
import 'package:chat/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class BottomSendField extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  final bool online;
  const BottomSendField({
    super.key,
    required this.recieverUserId,
    required this.isGroupChat,
    this.online = false,
  });

  @override
  ConsumerState<BottomSendField> createState() => _BottomSendFieldState();
}

class _BottomSendFieldState extends ConsumerState<BottomSendField> {
  TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;
  bool sendButton = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  Future<bool> pushNotificationsGroupDevice({
    required String title,
    required String body,
    required List<String> IDs,
  }) async {
    print('hiccccccccccccccccccccccccccccc');
    var IDS = jsonEncode(IDs);
    String dataNotifications = '{'
        '"operation": "create",'
        '"notification_key_name": "chat-app-37644",'
        '"registration_ids":$IDS,'
        '"notification" : {'
        '"title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAcdvzQX8:APA91bEm7OGq51Syap2cvOr0hdW07ofrEKfjfELVIKEnBaq_7ZJrCJ7AvAVni7VhGMN3RbJGJu2kT1hYbFy1oCxhVGoboxC73fkMpT7tRmSbrJOiSDclyMBe6--f78QL8ExgR8GtESiT',
        'project_id': '489021456767'
      },
      body: dataNotifications,
    );

    print("xxxxxxx" + dataNotifications);

    print(response.body.toString());

    return true;
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    _soundRecorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (sendButton) {
      print("sending");
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.recieverUserId,
            widget.isGroupChat,
          );
      print('ddddddddddddddddddddddddddddd');
      pushNotificationsGroupDevice(
        title: 'Chat',
        body: _messageController.text,
        IDs: [
          'f4OdhHozTEusncH-z-dTFD:APA91bFFhyro-Q-Z5CMTIuXmYp_YpAuUzTpX6otiudg9BrYnL8xTntoCcgIL4GnbMRItoNR4VB-Dl3srKIi-J1JnAqZiKwmMxP_JpPBz3fpaFU6amlH07igR2AjP8R3D0WcfVgZyCijy'
        ],
      );
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  Future stopRecord() async {
    await _soundRecorder!.stopRecorder();
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.recieverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGif() async {
    final gif = await pickGIF(context);
    print(gif);
    if (gif != null) {
      ref.read(chatControllerProvider).sendGifMessage(
            context,
            gif.url,
            widget.recieverUserId,
            widget.isGroupChat,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFFF8E8EE), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Column(
            children: [
              isShowMessageReply
                  ? const MessageReplyPreview()
                  : const SizedBox(),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                width: 420,
                child: TextField(
                  focusNode: focusNode,
                  autofocus: false,
                  controller: _messageController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        sendButton = true;
                      });
                    } else {
                      setState(() {
                        sendButton = false;
                      });
                    }
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    suffixIcon: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF8E8EE),
                          borderRadius: BorderRadius.circular(20)),
                      width: 200,
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink[100],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isRecording) {
                                      sendTextMessage();
                                    } else {
                                      FocusScope.of(context).unfocus();
                                      stopRecord();
                                      setState(() {
                                        isRecording = false;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    sendButton
                                        ? Icons.send
                                        : isRecording
                                            ? Icons.close
                                            : Icons.mic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          isRecording
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink[100],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          sendTextMessage();
                                        },
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          !isRecording
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink[100],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: selectGif,
                                        child: Icon(
                                          Icons.gif,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          !isRecording
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink[100],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: selectImage,
                                        child: Icon(
                                          Icons.camera,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          !isRecording
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink[100],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: selectVideo,
                                        child: Icon(
                                          Icons.video_call,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          isRecording
                              ? StreamBuilder<RecordingDisposition>(
                                  stream: _soundRecorder!.onProgress,
                                  builder: (context, snapshot) {
                                    final duration = snapshot.hasData
                                        ? snapshot.data!.duration
                                        : Duration.zero;

                                    String formattime(int n) =>
                                        n.toString().padLeft(2);
                                    final min = formattime(
                                            duration.inMinutes.remainder(60))
                                        .padLeft(2);
                                    final sec = formattime(
                                            duration.inSeconds.remainder(60))
                                        .padLeft(2);
                                    return Text('${min}:${sec}');
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    hintText: 'Type message...',
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
