import 'package:equatable/equatable.dart';
abstract class ResultsEvents extends Equatable{
  const ResultsEvents();
}
class GetSessionsEvent extends ResultsEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends ResultsEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetTermEvent extends ResultsEvents{
  final String apiToken;
  const GetTermEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectTermEvent extends ResultsEvents{
  final String term;
  const SelectTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class GetClassEvent extends ResultsEvents{
  final String apiToken;
  const GetClassEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class GetTeacherClassEvent extends ResultsEvents{
  final String apiToken;
  final String teacherId;
  const GetTeacherClassEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class GetFormTeacherClassEvent extends ResultsEvents{
  final String apiToken;
  final String teacherId;
  const GetFormTeacherClassEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class SelectClassEvent extends ResultsEvents{
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class ViewClassResultsEvent extends ResultsEvents{
  final String sessionId;
  final String termId;
  final String classId;
  final String type;
  const ViewClassResultsEvent(this.sessionId, this.termId, this.classId, this.type);
  @override
  // TODO: implement props
  List<Object> get props => [sessionId, termId, classId, type];

}

class ViewStudentResultEvent extends ResultsEvents{
  final String studentId;
  final String classId;
  final String termId;
  final String sessionId;
  final String type;
  const ViewStudentResultEvent(this.studentId, this.classId, this.termId, this.sessionId, this.type);
  @override
  // TODO: implement props
  List<Object> get props => [studentId, classId, termId, sessionId, type];

}

class ViewStudentCumulativeResultEvent extends ResultsEvents{
  final String studentId;
  final String classId;
  final String sessionId;
  final String type;
  const ViewStudentCumulativeResultEvent(this.studentId, this.classId, this.sessionId, this.type);
  @override
  // TODO: implement props
  List<Object> get props => [studentId, classId, sessionId, type];

}

class ViewSubjectResultsEvent extends ResultsEvents{
  final String resultId;
  final String subjectId;
  final String sessionId;
  final String termId;
  final String classId;
  final String type;
  const ViewSubjectResultsEvent(this.resultId, this.subjectId, this.sessionId, this.termId, this.classId, this.type);
  @override
  // TODO: implement props
  List<Object> get props => [resultId, subjectId, sessionId, termId, classId, type];

}

class ApproveResultsEvent extends ResultsEvents{
  final String resultId;
  final String sessionId;
  final String termId;
  final String classId;
  final String subjectId;
  final String teacherId;
  final List<String> resultHeaders;
  final Map results;
  final List<String> studentsUniqueIds;
  final List<String> studentResult;
  const ApproveResultsEvent(this.resultId, this.sessionId, this.termId, this.classId, this.subjectId, this.teacherId, this.resultHeaders, this.results, this.studentsUniqueIds, this.studentResult);
  @override
  // TODO: implement props
  List<Object> get props => [resultId, sessionId, termId, classId, subjectId, teacherId, resultHeaders, results, studentsUniqueIds, studentResult];

}

class DeclineResultsEvent extends ResultsEvents{
  final String resultId;
  final String senderId;
  final String sender;
  final String comment;
  const DeclineResultsEvent(this.resultId, this.senderId, this.sender, this.comment);
  @override
  // TODO: implement props
  List<Object> get props => [resultId, senderId, sender, comment];

}

class ViewStudentsAttendanceInterfaceEvent extends ResultsEvents{
  final String teacherId;
  final String classId;
  final String termId;
  final String sessionId;
  const ViewStudentsAttendanceInterfaceEvent(this.teacherId, this.classId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [teacherId, classId, termId, sessionId];

}

class ViewStudentsBehaviouralSkillsInterfaceEvent extends ResultsEvents{
  final String teacherId;
  final String classId;
  final String termId;
  final String sessionId;
  const ViewStudentsBehaviouralSkillsInterfaceEvent(this.teacherId, this.classId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [teacherId, classId, termId, sessionId];

}

class AddStudentsAttendanceEvent extends ResultsEvents{
  final String classId;
  final String termId;
  final String sessionId;
  final List<String> attendanceHeader;
  final List<String> studentsAttendances;
  const AddStudentsAttendanceEvent(this.classId, this.termId, this.sessionId, this.attendanceHeader, this.studentsAttendances);
  @override
  // TODO: implement props
  List<Object> get props => [classId, termId, sessionId, attendanceHeader, studentsAttendances];

}

class AddStudentsBehaviouralSkillsEvent extends ResultsEvents{
  final String classId;
  final String termId;
  final String sessionId;
  final List<String> behaviouralSkillsHeader;
  final List<String> studentsBehaviouralSkills;
  const AddStudentsBehaviouralSkillsEvent(this.classId, this.termId, this.sessionId, this.behaviouralSkillsHeader, this.studentsBehaviouralSkills);
  @override
  // TODO: implement props
  List<Object> get props => [classId, termId, sessionId, behaviouralSkillsHeader, studentsBehaviouralSkills];

}

class ViewTeacherCommentsEvent extends ResultsEvents{
  final String classId;
  final String termId;
  final String sessionId;
  const ViewTeacherCommentsEvent(this.classId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, termId, sessionId];

}

class ViewPrincipalCommentsEvent extends ResultsEvents{
  final String termId;
  final String sessionId;
  const ViewPrincipalCommentsEvent(this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [termId, sessionId];

}

class AddTeacherCommentsEvent extends ResultsEvents{
  final String classId;
  final String termId;
  final String sessionId;
  final String remark;
  final String startLimit;
  final String endLimit;
  const AddTeacherCommentsEvent(this.classId, this.termId, this.sessionId, this.remark, this.startLimit, this.endLimit);
  @override
  // TODO: implement props
  List<Object> get props => [classId, termId, sessionId, remark, startLimit, endLimit];

}

class AddPrincipalCommentsEvent extends ResultsEvents{
  final String termId;
  final String sessionId;
  final String remark;
  final String startLimit;
  final String endLimit;
  const AddPrincipalCommentsEvent(this.termId, this.sessionId, this.remark, this.startLimit, this.endLimit);
  @override
  // TODO: implement props
  List<Object> get props => [termId, sessionId, remark, startLimit, endLimit];

}

class UpdateTeacherCommentsEvent extends ResultsEvents{
  final String commentId;
  final String classId;
  final String termId;
  final String sessionId;
  final String remark;
  final String startLimit;
  final String endLimit;
  const UpdateTeacherCommentsEvent(this.commentId, this.classId, this.termId, this.sessionId, this.remark, this.startLimit, this.endLimit);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, classId, termId, sessionId, remark, startLimit, endLimit];

}

class UpdatePrincipalCommentsEvent extends ResultsEvents{
  final String commentId;
  final String termId;
  final String sessionId;
  final String remark;
  final String startLimit;
  final String endLimit;
  const UpdatePrincipalCommentsEvent(this.commentId, this.termId, this.sessionId, this.remark, this.startLimit, this.endLimit);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, termId, sessionId, remark, startLimit, endLimit];

}

class DeleteTeacherCommentsEvent extends ResultsEvents{
  final String commentId;
  final String classId;
  final String termId;
  final String sessionId;
  const DeleteTeacherCommentsEvent(this.commentId, this.classId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, classId, termId, sessionId];

}

class DeletePrincipalCommentsEvent extends ResultsEvents{
  final String commentId;
  final String termId;
  final String sessionId;
  const DeletePrincipalCommentsEvent(this.commentId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, termId, sessionId];

}

class RestoreTeacherCommentsEvent extends ResultsEvents{
  final String commentId;
  final String classId;
  final String termId;
  final String sessionId;
  const RestoreTeacherCommentsEvent(this.commentId, this.classId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, classId, termId, sessionId];

}

class RestorePrincipalCommentsEvent extends ResultsEvents{
  final String commentId;
  final String termId;
  final String sessionId;
  const RestorePrincipalCommentsEvent(this.commentId, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, termId, sessionId];

}