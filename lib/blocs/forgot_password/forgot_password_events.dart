import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvents extends Equatable{
  const ForgotPasswordEvents();
}

class ForgotPasswordEvent extends ForgotPasswordEvents{
  final String email;
  const ForgotPasswordEvent(this.email);
  @override
  // TODO: implement props
  List<Object> get props => [email];

}

class VerifyOtpEvent extends ForgotPasswordEvents{
  final String otp;
  const VerifyOtpEvent(this.otp);
  @override
  // TODO: implement props
  List<Object> get props => [otp];

}

class ResetPasswordEvent extends ForgotPasswordEvents{
  final String password;
  final String confirmPassword;
  final String otp;
  const ResetPasswordEvent(this.password, this.confirmPassword, this.otp);
  @override
  // TODO: implement props
  List<Object> get props => [password, confirmPassword, otp];

}

class VisiblePassword extends ForgotPasswordEvents {
  final bool password;
  VisiblePassword(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}