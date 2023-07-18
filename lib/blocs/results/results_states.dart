import 'package:equatable/equatable.dart';
import 'package:school_pal/models/class_results.dart';
import 'package:school_pal/models/result_comments.dart';
import 'package:school_pal/models/student_result.dart';
import 'package:school_pal/models/subject_results.dart';

abstract class ResultsStates extends Equatable{
  const ResultsStates();
}

class ResultsInitial extends ResultsStates{
  const ResultsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends ResultsStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends ResultsStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SessionsLoaded extends ResultsStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends ResultsStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class TermsLoaded extends ResultsStates{
  final List<List<String>> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermSelected extends ResultsStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ClassLoaded extends ResultsStates{
  final List<List<String>> clas;
  const ClassLoaded(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];
}

class ClassSelected extends ResultsStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class ClassResultLoaded extends ResultsStates{
  final List<ClassResults> classResults;
  const ClassResultLoaded(this.classResults);
  @override
  // TODO: implement props
  List<Object> get props => [classResults];

}

class SubjectResultLoaded extends ResultsStates{
  final SubjectResult subjectResults;
  const SubjectResultLoaded(this.subjectResults);
  @override
  // TODO: implement props
  List<Object> get props => [subjectResults];

}

class ResultApproved extends ResultsStates{
  final String message;
  const ResultApproved(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ResultDeclined extends ResultsStates{
  final String message;
  const ResultDeclined(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class StudentResultLoaded extends ResultsStates{
  final StudentResult studentResult;
  const StudentResultLoaded(this.studentResult);
  @override
  // TODO: implement props
  List<Object> get props => [studentResult];

}

class StudentsAttendanceInterfaceLoaded extends ResultsStates{
  final List<List<String>> attendanceInterface;
  const StudentsAttendanceInterfaceLoaded(this.attendanceInterface);
  @override
  // TODO: implement props
  List<Object> get props => [attendanceInterface];

}

class StudentsBehaviouralSkillsInterfaceLoaded extends ResultsStates{
  final List<List<String>> behaviouralSkillsInterface;
  const StudentsBehaviouralSkillsInterfaceLoaded(this.behaviouralSkillsInterface);
  @override
  // TODO: implement props
  List<Object> get props => [behaviouralSkillsInterface];

}

class StudentsBehaviouralSkillsAdded extends ResultsStates{
  final String message;
  const StudentsBehaviouralSkillsAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class StudentsAttendanceAdded extends ResultsStates{
  final String message;
  const StudentsAttendanceAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ResultCommentsLoaded extends ResultsStates{
  final List<ResultComments> resultComments;
  const ResultCommentsLoaded(this.resultComments);
  @override
  // TODO: implement props
  List<Object> get props => [resultComments];

}

class ResultCommentsAdded extends ResultsStates{
  final String message;
  const ResultCommentsAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ResultCommentsUpdated extends ResultsStates{
  final String message;
  const ResultCommentsUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ResultCommentsDeleted extends ResultsStates{
  final String message;
  const ResultCommentsDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ResultCommentsRestored extends ResultsStates{
  final String message;
  const ResultCommentsRestored(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends ResultsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends ResultsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}