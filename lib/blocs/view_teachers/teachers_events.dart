import 'package:equatable/equatable.dart';

abstract class TeachersEvents extends Equatable{
  const TeachersEvents();
}

class ViewTeachersEvent extends TeachersEvents{
  final String apiToken;
  final bool localDb;
  const ViewTeachersEvent({this.apiToken, this.localDb});
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, localDb];

}

class AddFormTeacherEvent extends TeachersEvents {
  final String classId;
  final String sessionId;
  final String termId;
  final String teacherId;
  const AddFormTeacherEvent(this.classId, this.sessionId, this.termId, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, sessionId, termId, teacherId];
}

class RemoveFormTeacherEvent extends TeachersEvents {
  final String classId;
  final String assignedId;
  final String teacherId;
  const RemoveFormTeacherEvent(this.classId, this.assignedId, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, assignedId, teacherId];
}

class GetSessionsEvent extends TeachersEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends TeachersEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetTermEvent extends TeachersEvents{
  final String apiToken;
  const GetTermEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectTermEvent extends TeachersEvents{
  final String term;
  const SelectTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class GetClassEvent extends TeachersEvents{
  final String apiToken;
  const GetClassEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectClassEvent extends TeachersEvents{
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class GetSubjectsEvent extends TeachersEvents{
  final String apiToken;
  const GetSubjectsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSubjectEvent extends TeachersEvents{
  final String subject;
  const SelectSubjectEvent(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class AddTeacherClassSubjectEvent extends TeachersEvents {
  final String classId;
  final String subjectId;
  final String sessionId;
  final String termId;
  final String teacherId;
  const AddTeacherClassSubjectEvent(this.classId, this.subjectId, this.sessionId, this.termId, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, subjectId, sessionId, termId, teacherId];
}

class UpdateTeacherClassSubjectEvent extends TeachersEvents {
  final String assignmentId;
  final String classId;
  final String subjectId;
  final String teacherId;
  const UpdateTeacherClassSubjectEvent(this.assignmentId, this.classId, this.subjectId, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [assignmentId, classId, subjectId, teacherId];
}

class DeleteTeacherClassSubjectEvent extends TeachersEvents {
  final String assignmentId;
  const DeleteTeacherClassSubjectEvent(this.assignmentId);
  @override
  // TODO: implement props
  List<Object> get props => [assignmentId];
}