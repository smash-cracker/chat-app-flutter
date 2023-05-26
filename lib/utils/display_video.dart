// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:cached_video_player/cached_video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  VideoPlayerItem({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  // late CachedVideoPlayerController cachedVideoPlayerController;

  bool isPlay = false;

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // cachedVideoPlayerController =
    //     CachedVideoPlayerController.network(widget.videoUrl)
    //       ..initialize().then((value) {
    //         cachedVideoPlayerController.setVolume(1);
    //         setState(() {});
    //       });

    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      autoInitialize: true,
      aspectRatio: 1,
      videoPlayerController: _videoPlayerController,
      customControls: CupertinoControls(
        backgroundColor: Colors.transparent,
        iconColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // cachedVideoPlayerController.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController),
    );
    // Stack(
    //   children: [
    //     VideoPlayerItem(
    //       videoUrl: widget.videoUrl,
    //     )
    //     // CachedVideoPlayer(cachedVideoPlayerController),
    //     // Align(
    //     //   alignment: Alignment.center,
    //     //   child: IconButton(
    //     //     onPressed: () {
    //     //       if (isPlay) {
    //     //         cachedVideoPlayerController.pause();
    //     //       } else {
    //     //         cachedVideoPlayerController.play();
    //     //       }
    //     //     },
    //     //     icon: Icon(
    //     //       isPlay ? Icons.pause_circle : Icons.play_circle,
    //     //     ),
    //     //   ),
    //     // ),
    //   ],
    // );
  }
}
