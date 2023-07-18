import 'package:equatable/equatable.dart';
import 'package:school_pal/models/students.dart';

abstract class StudentsStates extends Equatable{
  const StudentsStates();
}

class StudentsInitial extends StudentsStates{
  const StudentsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class StudentsLoading extends StudentsStates{
  const StudentsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class StudentsProcessing extends StudentsStates{
  const StudentsProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class StudentsLoaded extends StudentsStates{
  final List<Students> students;
  const StudentsLoaded(this.students);
  @override
  // TODO: implement props
  List<Object> get props => [students];
}

class StudentDeleted extends StudentsStates{
  final String message;
  const StudentDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends StudentsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends StudentsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}