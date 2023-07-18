import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/pick_up_id/pick_up_id.dart';
import 'package:school_pal/requests/posts/pick_up_id_requests.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';

class PickUpIdBloc extends Bloc<PickUpIdEvents, PickUpIdStates>{
  final PickUpIdRepository pickUpIdRepository;
  PickUpIdBloc(this.pickUpIdRepository) : super(PickUpIdInitialState());

  @override
  Stream<PickUpIdStates> mapEventToState(PickUpIdEvents event) async* {
    // TODO: implement mapEventToState
    if(event is IdVisibilityEvent){
      yield IdVisibilityState(event.visibility);
    }else if(event is VerifyPickUpIdEvent){
      yield VerifyingPickUpId();
      try{
        final student=await pickUpIdRepository.verifyPickUpId(pickUpId: event.pickUpId);
        yield PickUpIdVerified(student);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield VerificationError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GeneratePickUpIdEvent){
      yield GeneratingPickUpId();
      try{
        final pickUpId=await pickUpIdRepository.generatePickUpId(studentId: event.studentId, password: event.password);
        yield PickUpIdGenerated(pickUpId);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield VerificationError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }

}