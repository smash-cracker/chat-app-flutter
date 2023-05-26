// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:cached_video_player/cached_video_player.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItemReply extends StatefulWidget {
  VideoPlayerItemReply({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayerItemReply> createState() => _VideoPlayerItemReplyState();
}

class _VideoPlayerItemReplyState extends State<VideoPlayerItemReply> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          CachedVideoPreviewWidget(
            path: widget.videoUrl,
            type: SourceType.remote,
            httpHeaders: const <String, String>{},
            remoteImageBuilder: (BuildContext context, url) =>
                Image.network(url),
          )
        ],
      ),
    );
  }
}
