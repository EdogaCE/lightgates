import 'package:equatable/equatable.dart';
import 'package:school_pal/models/grade.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/terms.dart';

abstract class SchoolStates extends Equatable{
  const SchoolStates();
}

class SchoolInitial extends SchoolStates{
  const SchoolInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends SchoolStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends SchoolStates{
  final String message;
  const Processing(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SessionsLoaded extends SchoolStates{
  final List<Sessions> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionActivated extends SchoolStates{
  final List<Sessions> sessions;
  const SessionActivated(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class TermsLoaded extends SchoolStates{
  final List<Terms> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermActivated extends SchoolStates{
  final List<Terms> terms;
  const TermActivated(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class GradesLoaded extends SchoolStates{
  final List<Grade> grades;
  const GradesLoaded(this.grades);
  @override
  // TODO: implement props
  List<Object> get props => [grades];
}

class GradeAdded extends SchoolStates{
  final String message;
  const GradeAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class GradeUpdated extends SchoolStates{
  final String message;
  const GradeUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class GradeDeleted extends SchoolStates{
  final String message;
  const GradeDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class GradeRestored extends SchoolStates{
  final String message;
  const GradeRestored(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SessionAdded extends SchoolStates{
  final List<Sessions> sessions;
  const SessionAdded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionUpdated extends SchoolStates{
  final String message;
  const SessionUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class TermAdded extends SchoolStates{
  final List<Terms> terms;
  const TermAdded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermUpdated extends SchoolStates{
  final String message;
  const TermUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class TermReordered extends SchoolStates {
  final int oldIndex;
  final int newIndex;
  const TermReordered(this.oldIndex, this.newIndex);
  @override
  // TODO: implement props
  List<Object> get props => [oldIndex, newIndex];
}

class ActivateError extends SchoolStates{
  final String message;
  const ActivateError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends SchoolStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends SchoolStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}