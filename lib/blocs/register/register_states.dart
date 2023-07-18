import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class RegisterStates extends Equatable{
  const RegisterStates();
}

class InitialState extends RegisterStates{
  const InitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class StepChanged extends RegisterStates {
  final int index;
  StepChanged(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];
}

class PasswordVisibilityChanged extends RegisterStates{
  final bool password;
  final bool confirmPassword;
  PasswordVisibilityChanged(this.password, this.confirmPassword);
  @override
  // TODO: implement props
  List<Object> get props => [password, confirmPassword];
}

class RegisteringUser extends RegisterStates{
  const RegisteringUser();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends RegisterStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UserRegistered extends RegisterStates{
  final String message;
  const UserRegistered(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class VerificationEmailResent extends RegisterStates{
  final String message;
  const VerificationEmailResent(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class VerificationVideoUploaded extends RegisterStates{
  final String message;
  const VerificationVideoUploaded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class VideoFileSelected extends RegisterStates{
  final File videoFile;
  const VideoFileSelected(this.videoFile);
  @override
  // TODO: implement props
  List<Object> get props => [videoFile];
}

class VideoFileEdited extends RegisterStates{
  final File videoFile;
  const VideoFileEdited(this.videoFile);
  @override
  // TODO: implement props
  List<Object> get props => [videoFile];
}

class FirstTimeLoginUpdated extends RegisterStates{
  final String message;
  const FirstTimeLoginUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FirstTimeSetupPageUpdated extends RegisterStates{
  final String message;
  const FirstTimeSetupPageUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class RegisterError extends RegisterStates{
  final String message;
  const RegisterError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends RegisterStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}