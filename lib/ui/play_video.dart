import 'package:flutter/material.dart';
import 'package:school_pal/res/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class PlayVideo extends StatelessWidget {
  final String videoUrl;
  final String heroTag;
  PlayVideo({this.videoUrl, this.heroTag});
  YoutubePlayerController _controller;
  @override
  Widget build(BuildContext context) {
     _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl),
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body:Container(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Hero(
              tag: heroTag,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: MyColors.primaryColor,
                  onReady: (){
                    _controller.play();
                  },
                ),
              ),
            ),
          ),
        )
    );
  }
}
