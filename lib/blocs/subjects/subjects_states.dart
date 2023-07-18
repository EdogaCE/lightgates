import 'package:equatable/equatable.dart';
import 'package:school_pal/models/subjects.dart';

abstract class SubjectsStates extends Equatable{
  const SubjectsStates();
}

class SubjectsInitial extends SubjectsStates{
  const SubjectsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SubjectsLoading extends SubjectsStates{
  const SubjectsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SubjectsProcessing extends SubjectsStates{
  const SubjectsProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SubjectsLoaded extends SubjectsStates{
  final List<Subjects> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  // TODO: implement props
  List<Object> get props => [subjects];
}

class SubjectAdded extends SubjectsStates{
  final String message;
  const SubjectAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SubjectEdited extends SubjectsStates{
  final String message;
  const SubjectEdited(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SubjectDeleted extends SubjectsStates{
  final String message;
  const SubjectDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends SubjectsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends SubjectsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}