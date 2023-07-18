import 'package:equatable/equatable.dart';
import 'package:school_pal/models/teachers.dart';

abstract class TeachersStates extends Equatable{
  const TeachersStates();
}

class TeachersInitial extends TeachersStates{
  const TeachersInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TeachersLoading extends TeachersStates{
  const TeachersLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TeachersProcessing extends TeachersStates{
  const TeachersProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TeachersLoaded extends TeachersStates{
  final List<Teachers> teachers;
  const TeachersLoaded(this.teachers);
  @override
  // TODO: implement props
  List<Object> get props => [teachers];
}

class FormTeacherAdded extends TeachersStates{
  final String message;
  const FormTeacherAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class FormTeacherRemoved extends TeachersStates{
  final String message;
  const FormTeacherRemoved(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class SessionsLoaded extends TeachersStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends TeachersStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class TermsLoaded extends TeachersStates{
  final List<List<String>> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermSelected extends TeachersStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ClassLoaded extends TeachersStates{
  final List<List<String>> clas;
  const ClassLoaded(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];
}

class ClassSelected extends TeachersStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class SubjectsLoaded extends TeachersStates{
  final List<List<String>> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  // TODO: implement props
  List<Object> get props => [subjects];
}

class SubjectSelected extends TeachersStates{
  final String subject;
  const SubjectSelected(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class TeacherClassSubjectAdded extends TeachersStates{
  final String message;
  const TeacherClassSubjectAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class TeacherClassSubjectUpdated extends TeachersStates{
  final String message;
  const TeacherClassSubjectUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class TeacherClassSubjectRemoved extends TeachersStates{
  final String message;
  const TeacherClassSubjectRemoved(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends TeachersStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends TeachersStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}