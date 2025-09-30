///!
import 'package:waslny/core/exports.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  YoutubeVideoPlayer(
      {required this.videoLinkId, required this.title, super.key});
  String videoLinkId;
  String title;

  // The single YouTube video link

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          widget.videoLinkId)!, // Extract the video ID from the provided link
      flags: YoutubePlayerFlags(
        autoPlay: false,
        forceHD: true,
        hideControls: false,
        controlsVisibleAtStart: false,
        enableCaption: false,
        isLive: false,
        hideThumbnail: true,
//.
      ),
    )..addListener(_onPlayerStateChange);
  } //

  void _onPlayerStateChange() {
    if (_isPlayerReady && mounted) {
      setState(() {
        print('sssssssssssssssssssssssss ');
        // Handle any state changes if needed
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            onReady: () {
              _isPlayerReady = true;
            },
          ),
          builder: (context, player) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                player,
                // const SizedBox(height: 10),
                // IconButton(
                //     icon: const Icon(Icons.high_quality_rounded),
                //     onPressed: _showQualityOptions),
              ],
            );
          },
        ),
      ),
    );
  }
}
