import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  final DataSourceType dataSourceType;
  const VideoPlayerView({super.key, required this.url, required this.dataSourceType});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    switch (widget.dataSourceType) {
      case DataSourceType.network:
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        break;
      case DataSourceType.asset:
         _videoPlayerController = VideoPlayerController.asset(widget.url);    
        break;
      case DataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;
      case DataSourceType.contentUri:
        // Handle case when device is iOS since this is only supported on android
        _videoPlayerController = VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(widget.dataSourceType.name.toUpperCase(),
       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const Divider(),
      AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController),
      ),
      ],
    );
  }
}