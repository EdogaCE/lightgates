import 'package:equatable/equatable.dart';

abstract class AnimationState extends Equatable{
  const AnimationState();
}

class AnimationInitial extends AnimationState {
  const AnimationInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class AnimationStart extends AnimationState{
  final bool start;
  final int page;
  const AnimationStart(this.start, this.page);
  @override
  // TODO: implement props
  List<Object> get props => [start, page];
}


