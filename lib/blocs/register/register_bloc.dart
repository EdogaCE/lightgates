import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/register/register.dart';
import 'package:school_pal/requests/get/verify_registration_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/posts/register_request.dart';
import 'package:school_pal/res/strings.dart';

class RegisterBloc extends Bloc<RegisterEvents, RegisterStates>{
  final RegisterRepository registerRepository;
  final VerifyRegistrationRepository verifyRegistrationRepository;
   RegisterBloc({this.registerRepository, this.verifyRegistrationRepository}) : super(InitialState());

  @override
  Stream<RegisterStates> mapEventToState(RegisterEvents event) async* {
    // TODO: implement mapEventToState
    if(event is ChangeStepEvent){
      yield StepChanged(event.index);
    }else if(event is VisiblePasswordEvent){
      yield PasswordVisibilityChanged(event.password, event.confirmPassword);
    }else if(event is RegisterUser){
      yield RegisteringUser();
      try{
        final message=await registerRepository.registerUser(name: event.name, slogan: event.slogan, email: event.contactEmail, username: event.username, password: event.password, confirmPassword: event.confirmPassword, contactPhoneNumber: event.contactPhoneNumber, address: event.address, town: event.town, lga: event.lga, city: event.city, nationality: event.nationality);
        yield UserRegistered(message);
      } on NetworkError{
        print("Networl error");
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield RegisterError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ResendVerificationEmailEvent){
      yield Processing();
      try{
        final message=await verifyRegistrationRepository.resendVerificationEmail(email: event.email);
        yield VerificationEmailResent(message);
      } on NetworkError{
        print("Networl error");
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield RegisterError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadVerificationVideoEvent){
      yield Processing();
      try{
        final successMessage=await registerRepository.uploadVerificationVideo(apiToken: event.apiToken, fileField: event.fileField);
        yield VerificationVideoUploaded(successMessage);
      } on NetworkError{
        print("Network error");
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield RegisterError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectVideoFileEvent){
      yield VideoFileSelected(event.videoFile);
    }else if(event is EditVideoFileEvent){
      yield VideoFileEdited(event.videoFile);
    }else if(event is UpdateFirstTimeLoginEvent){
      yield Processing();
      try{
        final message=await verifyRegistrationRepository.updateFirstTimeLogin();
        yield FirstTimeLoginUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield RegisterError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateFirstTimeSetupPageEvent){
      yield Processing();
      try{
        final message=await verifyRegistrationRepository.updateFirstTimeSetupPage(page: event.page);
        yield FirstTimeSetupPageUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield RegisterError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}