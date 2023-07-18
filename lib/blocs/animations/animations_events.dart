import 'package:equatable/equatable.dart';

abstract class AnimationsEvent extends Equatable{
  const AnimationsEvent();
}

class StartHomeAnimation extends AnimationsEvent{
  final bool start;
  final int page;
  const StartHomeAnimation(this.start, this.page);
  @override
  // TODO: implement props
  List<Object> get props => [start, page];

}