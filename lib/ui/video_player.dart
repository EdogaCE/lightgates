import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/video_player/video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoPlayers extends StatelessWidget {
  final String videoUrl;
  final File videoFile;
  final String heroTag;
  VideoPlayers({this.videoUrl, this.videoFile, this.heroTag});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPlayerBloc(),
      child: VideoPlayersPage(videoUrl, videoFile, heroTag),
    );
  }
}

// ignore: must_be_immutable
class VideoPlayersPage extends StatelessWidget {
  final String videoUrl;
  final File videoFile;
  final String heroTag;
  VideoPlayersPage(this.videoUrl, this.videoFile, this.heroTag);

  VideoPlayerBloc _videoPlayerBloc;
  VideoPlayerController _videoPlayerController;
  bool videoInitialized=false;
  bool controllerVisibility=true;
  double progress=0;

  _initController(){
    if(videoUrl.isEmpty){
      _videoPlayerController = VideoPlayerController.file(videoFile)..addListener(() {
        try{
          if(_videoPlayerController.value.position.inSeconds!=progress)
            _videoPlayerBloc.add(ChangeProgressEvent(_videoPlayerController.value.position.inSeconds.floorToDouble()));
        }catch (e){}
      })..initialize().then((_) {
        _videoPlayerController.play();
        _videoPlayerBloc.add(InitializeVideoEvent(true));
      });
    }else{
      _videoPlayerController = VideoPlayerController.network(videoUrl)..addListener(() {
        try{
          if(_videoPlayerController.value.position.inSeconds!=progress)
            _videoPlayerBloc.add(ChangeProgressEvent(_videoPlayerController.value.position.inSeconds.floorToDouble()));
        }catch (e){}
      })..initialize().then((_) {
          _videoPlayerController.play();
          _videoPlayerBloc.add(InitializeVideoEvent(true));
        });
    }

    Timer.periodic(Duration(seconds: 5), (timer) {
      try{
        if(controllerVisibility){
          _videoPlayerBloc.add(ChangeControllerVisibilityEvent(!controllerVisibility));
        }
      }catch(e){}
    });

  }

  @override
  Widget build(BuildContext context) {
    _videoPlayerBloc = BlocProvider.of<VideoPlayerBloc>(context);
    _initController();
    return WillPopScope(
      onWillPop: () =>_popNavigator(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(""),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body:Container(
            height: double.infinity,
            width: double.infinity,
            child: BlocListener<VideoPlayerBloc, VideoPlayerStates>(
              listener: (context, state) {
                //Todo: note listener returns void
                if (state is VideoPlaying) {

                }else if (state is VideoInitialized) {
                  videoInitialized=state.initialized;
                  print(_videoPlayerController.value.duration);
                }else  if (state is ProgressChanged) {
                  progress=state.progress;
                  if(state.progress==(_videoPlayerController.value.duration.inSeconds)){
                    progress=0;
                    Navigator.pop(context);
                  }
                  print('Progress: ${state.progress}');
                }else if (state is ControllerVisibilityChanged){
                  controllerVisibility=state.visibility;
                }
              },
              child: BlocBuilder<VideoPlayerBloc, VideoPlayerStates>(
                builder: (context, state) {
                  //Todo: note builder returns widget
                  return Stack(
                    children: [
                      Center(
                        child: Container(
                          width: videoInitialized?_videoPlayerController.value.size.width:0,
                          height: videoInitialized?_videoPlayerController.value.size.height:0,
                          child: Hero(
                            tag: heroTag,
                            child: GestureDetector(
                              child: VideoPlayer(_videoPlayerController),
                              onTap: (){
                                _videoPlayerBloc.add(ChangeControllerVisibilityEvent(!controllerVisibility));
                              },
                            ),
                          ),
                        ),
                      ),
                      controllerVisibility?Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black45,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                    backgroundColor: Colors.white54,
                                    value: ((progress*100)/_videoPlayerController.value.duration.inSeconds)/100.floorToDouble(),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _videoPlayerController.value.duration.inSeconds.toString(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(icon: Icon(_videoPlayerController.value.isPlaying
                                          ?Icons.pause_circle_filled
                                          :Icons.play_circle_filled,
                                          size: 50,
                                          color: Colors.white),
                                          onPressed:() async{
                                            _videoPlayerController.value.isPlaying
                                                ? _videoPlayerController.pause()
                                                : _videoPlayerController.play();
                                            _videoPlayerBloc.add(PlayVideoEvent(!_videoPlayerController.value.isPlaying));
                                          }),
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            progress.floor().toString(),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ):Container(),
                    ],
                  );
                },
              ),
            )
          )
      ),
    );
  }

  Future<bool> _popNavigator() async {
   if(_videoPlayerController.value.isPlaying){
     _videoPlayerController.pause();
   }
    return Future.value(!_videoPlayerController.value.isPlaying);
  }
}
