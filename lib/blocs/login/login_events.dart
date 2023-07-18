import 'package:equatable/equatable.dart';

abstract class LoginEvents extends Equatable{
  const LoginEvents();
}

class VisiblePassword extends LoginEvents{
  final bool password;
  VisiblePassword(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}


class SelectSpinnerDataEvent extends LoginEvents{
  final String selectedData;
  const SelectSpinnerDataEvent(this.selectedData);
  @override
  // TODO: implement props
  List<Object> get props => [selectedData];

}
class ViewSchoolCategoriesEvent extends LoginEvents{
  const ViewSchoolCategoriesEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];

}
class LoginSchool extends LoginEvents{
  final String contactEmail;
  final String password;
  LoginSchool(this.contactEmail, this.password);
  @override
  // TODO: implement props
  List<Object> get props => [contactEmail, password];
}

class LoginTeacher extends LoginEvents{
  final String contactEmail;
  final String password;
  LoginTeacher(this.contactEmail, this.password);
  @override
  // TODO: implement props
  List<Object> get props => [contactEmail, password];
}

class LoginStudent extends LoginEvents{
  final String contactEmail;
  final String password;
  LoginStudent(this.contactEmail, this.password);
  @override
  // TODO: implement props
  List<Object> get props => [contactEmail, password];
}

class InitializeAppEvent extends LoginEvents{
  final bool localDb;
  InitializeAppEvent(this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [localDb];
}