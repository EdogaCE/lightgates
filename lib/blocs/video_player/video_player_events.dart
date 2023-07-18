import 'package:equatable/equatable.dart';

abstract class  VideoPlayerEvents extends Equatable{
  const  VideoPlayerEvents();
}

class PlayVideoEvent extends VideoPlayerEvents{
  final bool play;
  const PlayVideoEvent(this.play);
  @override
  // TODO: implement props
  List<Object> get props => [play];
}

class InitializeVideoEvent extends VideoPlayerEvents{
  final bool initialize;
  const InitializeVideoEvent(this.initialize);
  @override
  // TODO: implement props
  List<Object> get props => [initialize];
}

class ChangeProgressEvent extends VideoPlayerEvents{
  final double progress;
  const ChangeProgressEvent(this.progress);
  @override
  // TODO: implement props
  List<Object> get props => [progress];
}

class ChangeControllerVisibilityEvent extends VideoPlayerEvents{
  final bool visibility;
  const ChangeControllerVisibilityEvent(this.visibility);
  @override
  // TODO: implement props
  List<Object> get props => [visibility];
}