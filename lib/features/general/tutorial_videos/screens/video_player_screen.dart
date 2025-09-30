import 'package:waslny/core/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(
      {required this.videoUrl, required this.title, super.key});
  final String videoUrl;
  final String title;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  Future<void> _playVideo() async {
    if (widget.videoUrl.isNotEmpty) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      _controller.play();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _playVideo().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          backgroundColor: AppColors.grey,
          playedColor: AppColors.primary,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          backgroundColor: AppColors.grey,
          playedColor: AppColors.primary,
        ),
      );
    });
  }

  Widget _buildVideo() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  Widget _buildLoading() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColors.primary,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: _controller.value.isInitialized
                ? _buildVideo()
                : _buildLoading()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
