import 'package:equatable/equatable.dart';
import 'package:school_pal/models/app_versions.dart';
import 'package:school_pal/models/user.dart';

abstract class LoginStates extends Equatable{
  const LoginStates();
}

class LoginInitialState extends LoginStates{
  const LoginInitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}
class VisiblePasswordState extends LoginStates{
  final bool password;
  const VisiblePasswordState(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}

class SpinnerDataSelected extends LoginStates{
  final String selectedData;
  const SpinnerDataSelected(this.selectedData);
  @override
  // TODO: implement props
  List<Object> get props => [selectedData];
}

class UserLoading extends LoginStates{
  const UserLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends LoginStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SchoolCategoriesLoaded extends LoginStates{
  final List<List<String>> schools;
  const SchoolCategoriesLoaded(this.schools);
  @override
  // TODO: implement props
  List<Object> get props => [schools];
}

class UserLoaded extends LoginStates{
  final User user;
  const UserLoaded(this.user);
  @override
  // TODO: implement props
  List<Object> get props => [user];
}

class AppInitialized extends LoginStates{
  final AppVersions appVersions;
  const AppInitialized(this.appVersions);
  @override
  // TODO: implement props
  List<Object> get props => [appVersions];
}

class UserError extends LoginStates{
  final String message;
  const UserError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends LoginStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}
