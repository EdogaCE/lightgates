import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/animations/animations.dart';

class AnimationBloc extends Bloc<AnimationsEvent, AnimationState>{
  AnimationBloc() : super(AnimationInitial());

  @override
  Stream<AnimationState> mapEventToState(AnimationsEvent event) async*{
    // TODO: implement mapEventToState
    if(event is StartHomeAnimation){
          yield AnimationStart(event.start, event.page);

    }
  }

}