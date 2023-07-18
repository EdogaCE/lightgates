import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/forgot_password/forgot_password.dart';
import 'package:school_pal/requests/posts/forgot_password_requests.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvents, ForgotPasswordStates>{
  final ForgotPasswordRepository forgotPasswordRepository;
  ForgotPasswordBloc({this.forgotPasswordRepository}) : super(ForgotPasswordInitial());

  @override
  Stream<ForgotPasswordStates> mapEventToState(ForgotPasswordEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ForgotPasswordEvent){
      yield Processing();
      try{
        final message=await forgotPasswordRepository.forgotPassword(email: event.email);
        yield ForgotPasswordActivated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is VerifyOtpEvent){
      yield Processing();
      try{
        final message=await forgotPasswordRepository.verifyOpt(otp: event.otp);
        yield OtpVerified(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ResetPasswordEvent){
      yield Processing();
      try{
        final message=await forgotPasswordRepository.resetPassword(password: event.password, confirmPassword: event.confirmPassword, otp: event.otp);
        yield PasswordResetDone(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is VisiblePassword){
      yield VisiblePasswordState(event.password);
    }
  }

}