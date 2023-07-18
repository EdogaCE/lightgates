import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/video_player/video_player.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvents, VideoPlayerStates>{
  VideoPlayerBloc() : super(VideoPlayerInitial());


  @override
  Stream<VideoPlayerStates> mapEventToState(VideoPlayerEvents event) async*{
    // TODO: implement mapEventToState
    if(event is PlayVideoEvent){
      yield VideoPlaying(event.play);
    }else  if(event is InitializeVideoEvent){
      yield VideoInitialized(event.initialize);
    }else  if(event is ChangeProgressEvent){
      yield ProgressChanged(event.progress);
    }else  if(event is ChangeControllerVisibilityEvent){
      yield ControllerVisibilityChanged(event.visibility);
    }
  }
}