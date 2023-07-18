import 'package:equatable/equatable.dart';

abstract class VideoPlayerStates extends Equatable{
  const VideoPlayerStates();
}

class VideoPlayerInitial extends VideoPlayerStates{
  const VideoPlayerInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class VideoPlaying extends VideoPlayerStates{
  final bool playing;
  const VideoPlaying(this.playing);
  @override
  // TODO: implement props
  List<Object> get props => [playing];
}

class VideoInitialized extends VideoPlayerStates{
  final bool initialized;
  const VideoInitialized(this.initialized);
  @override
  // TODO: implement props
  List<Object> get props => [initialized];
}

class ProgressChanged extends VideoPlayerStates{
  final double progress;
  const ProgressChanged(this.progress);
  @override
  // TODO: implement props
  List<Object> get props => [progress];
}

class ControllerVisibilityChanged extends VideoPlayerStates{
  final bool visibility;
  const ControllerVisibilityChanged(this.visibility);
  @override
  // TODO: implement props
  List<Object> get props => [visibility];
}
