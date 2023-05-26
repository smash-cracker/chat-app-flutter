import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/utils/display_video.dart';
import 'package:chat/utils/display_video_reply.dart';
import 'package:chat/utils/enum/message_enum.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplayTextImageGifReply extends StatefulWidget {
  final String message;
  final String username;
  final MessageEnum type;
  const DisplayTextImageGifReply(
      {super.key,
      required this.message,
      required this.type,
      required this.username});

  @override
  State<DisplayTextImageGifReply> createState() =>
      _DisplayTextImageGifReplyState();
}

class _DisplayTextImageGifReplyState extends State<DisplayTextImageGifReply> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isPlaying = false;
    Duration _duration = Duration();
    Duration _position = Duration();
    final AudioPlayer audioPlayer = AudioPlayer();

    // @override
    // void initState() {
    //   super.initState();
    //   audioPlayer.onDurationChanged.listen((Duration duration) {
    //     setState(() => _duration = duration);
    //   });
    //   audioPlayer.onPositionChanged.listen((Duration position) {
    //     setState(() => _position = position);
    //   });
    //   audioPlayer.onPlayerStateChanged.listen((state) {
    //     if (state == PlayerState.completed) {
    //       setState(() {
    //         _position = Duration();
    //         isPlaying = false;
    //       });
    //     }
    //   });
    // }

    return widget.type == MessageEnum.text
        ? Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : widget.type == MessageEnum.video
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.username),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.video_camera),
                            Text('video'),
                          ],
                        ),
                      ],
                    ),
                    VideoPlayerItemReply(
                      videoUrl: widget.message,
                    ),
                  ],
                ),
              )
            : widget.type == MessageEnum.audio
                ? StatefulBuilder(builder: (context, setState) {
                    return Container(
                      width: width * 0.58,
                      padding: EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 50,
                            ),
                            onPressed: () async {
                              if (isPlaying) {
                                await audioPlayer.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                audioPlayer.onDurationChanged
                                    .listen((Duration duration) {
                                  setState(() => _duration = duration);
                                });
                                audioPlayer.onPositionChanged
                                    .listen((Duration position) {
                                  setState(() => _position = position);
                                });
                                audioPlayer.onPlayerStateChanged
                                    .listen((state) {
                                  if (state == PlayerState.completed) {
                                    setState(() {
                                      _position = Duration();
                                      isPlaying = false;
                                    });
                                  }
                                });

                                await audioPlayer
                                    .play(UrlSource(widget.message));
                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.27,
                            child: ProgressBar(
                              progress: _position,
                              buffered: _duration,
                              total: _duration,
                              progressBarColor: Colors.red,
                              baseBarColor: Colors.white.withOpacity(0.24),
                              onSeek: (Duration duration) {
                                audioPlayer.seek(duration);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                : widget.type == MessageEnum.gif
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: widget.message,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () {
                            final imageProvider =
                                Image.network(widget.message).image;
                            showImageViewer(context, imageProvider,
                                onViewerDismissed: () {},
                                backgroundColor: Colors.white,
                                closeButtonColor:
                                    Color.fromARGB(255, 233, 134, 167));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.username),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(CupertinoIcons.video_camera),
                                      Text('photo'),
                                    ],
                                  ),
                                ],
                              ),
                              CachedNetworkImage(
                                imageUrl: widget.message,
                              ),
                            ],
                          ),
                        ),
                      );
  }
}
