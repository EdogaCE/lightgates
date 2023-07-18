import 'package:equatable/equatable.dart';

abstract class ForgotPasswordStates extends Equatable{
  const ForgotPasswordStates();
}

class ForgotPasswordInitial extends ForgotPasswordStates{
  const ForgotPasswordInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends ForgotPasswordStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ForgotPasswordActivated extends ForgotPasswordStates{
  final Map<String, String> message;
  const ForgotPasswordActivated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class OtpVerified extends ForgotPasswordStates{
  final Map<String, String> message;
  const OtpVerified(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class PasswordResetDone extends ForgotPasswordStates{
  final Map<String, String> message;
  const PasswordResetDone(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class VisiblePasswordState extends ForgotPasswordStates{
  final bool password;
  const VisiblePasswordState(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}

class ViewError extends ForgotPasswordStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends ForgotPasswordStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}