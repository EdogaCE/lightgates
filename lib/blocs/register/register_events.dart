import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class RegisterEvents extends Equatable{
  const RegisterEvents();
}

class ChangeStepEvent extends RegisterEvents{
  final int index;
  ChangeStepEvent(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];

}

class VisiblePasswordEvent extends RegisterEvents{
  final bool password;
  final bool confirmPassword;
  VisiblePasswordEvent(this.password, this.confirmPassword);
  @override
  // TODO: implement props
  List<Object> get props => [password, confirmPassword];
}

class RegisterUser extends RegisterEvents{
  final String name;
  final String slogan;
  final String contactEmail;
  final String username;
  final String password;
  final String confirmPassword;
  final String contactPhoneNumber;
  final String address;
  final String town;
  final String lga;
  final String city;
  final String nationality;
  RegisterUser(this.name, this.slogan, this.contactEmail, this.username, this.password, this.confirmPassword, this.contactPhoneNumber, this.address, this.town, this.lga, this.city, this.nationality);
  @override
  // TODO: implement props
  List<Object> get props => [name, slogan, contactEmail, username, password, confirmPassword, contactPhoneNumber, address, town, lga, city, nationality];
}

class ResendVerificationEmailEvent extends RegisterEvents{
  final String email;
  ResendVerificationEmailEvent(this.email);
  @override
  // TODO: implement props
  List<Object> get props => [email];
}

class UploadVerificationVideoEvent extends RegisterEvents{
  final String apiToken;
  final String fileField;
  UploadVerificationVideoEvent(this.apiToken, this.fileField);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, fileField];
}

class SelectVideoFileEvent extends RegisterEvents{
  final File videoFile;
  SelectVideoFileEvent(this.videoFile);
  @override
  // TODO: implement props
  List<Object> get props => [videoFile];
}

class EditVideoFileEvent extends RegisterEvents{
  final File videoFile;
  EditVideoFileEvent(this.videoFile);
  @override
  // TODO: implement props
  List<Object> get props => [videoFile];
}

class UpdateFirstTimeLoginEvent extends RegisterEvents{
  UpdateFirstTimeLoginEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UpdateFirstTimeSetupPageEvent extends RegisterEvents{
  final String page;
  UpdateFirstTimeSetupPageEvent({this.page});
  @override
  // TODO: implement props
  List<Object> get props => [page];
}
