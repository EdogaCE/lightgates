import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AssessmentsEvents extends Equatable{
  const AssessmentsEvents();
}

class ViewAssessmentsEvent extends AssessmentsEvents{
  final String apiToken;
  const ViewAssessmentsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class AddAssessmentEvent extends AssessmentsEvents{
  final String termId;
  final String sessionId;
  final String classId;
  final String subjectId;
  final String teacherId;
  final String title;
  final String type;
  final String submissionMode;
  final String instructions;
  final List<String> files;
  final String content;
  final String submissionDate;
  const AddAssessmentEvent(this.termId, this.sessionId, this.classId, this.subjectId, this.teacherId, this.title, this.type, this.submissionMode, this.instructions, this.files, this.content, this.submissionDate);
  @override
  // TODO: implement props
  List<Object> get props => [termId, sessionId, classId, subjectId, teacherId, title, type, submissionMode, instructions, files, content, submissionDate];

}

class UpdateAssessmentEvent extends AssessmentsEvents{
  final String assessmentId;
  final String termId;
  final String sessionId;
  final String classId;
  final String subjectId;
  final String teacherId;
  final String title;
  final String type;
  final String submissionMode;
  final String instructions;
  final List<String> files;
  final String content;
  final String submissionDate;
  final List<String> filesToDelete;
  const UpdateAssessmentEvent(this.assessmentId, this.termId, this.sessionId, this.classId, this.subjectId, this.teacherId, this.title, this.type, this.submissionMode, this.instructions, this.files, this.content, this.submissionDate, this.filesToDelete);
  @override
  // TODO: implement props
  List<Object> get props => [assessmentId, termId, sessionId, classId, subjectId, teacherId, title, type, submissionMode, instructions, files, content, submissionDate, filesToDelete];

}
class AddAssessmentFilesEvent extends AssessmentsEvents{
  final String assessmentId;
  final String fileField;
  final String fileType;
  const AddAssessmentFilesEvent(this.assessmentId, this.fileField, this.fileType);
  @override
  // TODO: implement props
  List<Object> get props => [assessmentId, fileField, fileType];

}

class GetSessionsEvent extends AssessmentsEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends AssessmentsEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetTermsEvent extends AssessmentsEvents{
  final String apiToken;
  const GetTermsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectTermEvent extends AssessmentsEvents{
  final String term;
  const SelectTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class GetTeacherClassesEvent extends AssessmentsEvents{
  final String apiToken;
  final String teacherId;
  const GetTeacherClassesEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class GetClassesEvent extends AssessmentsEvents{
  final String apiToken;
  const GetClassesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectClassEvent extends AssessmentsEvents{
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class GetTeacherSubjectsEvent extends AssessmentsEvents{
  final String apiToken;
  final String teacherId;
  const GetTeacherSubjectsEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class GetSubjectsEvent extends AssessmentsEvents{
  final String apiToken;
  const GetSubjectsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSubjectEvent extends AssessmentsEvents{
  final String subject;
  const SelectSubjectEvent(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class SelectTypeEvent extends AssessmentsEvents{
  final String type;
  const SelectTypeEvent(this.type);
  @override
  // TODO: implement props
  List<Object> get props => [type];

}

class SelectSubmissionModeEvent extends AssessmentsEvents{
  final String mode;
  const SelectSubmissionModeEvent(this.mode);
  @override
  // TODO: implement props
  List<Object> get props => [mode];

}

class ChangeAddedDateEvent extends AssessmentsEvents{
  final DateTime date;
  const ChangeAddedDateEvent(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];

}

class ChangeSubmissionDateEvent extends AssessmentsEvents{
  final DateTime date;
  const ChangeSubmissionDateEvent(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];

}

class SelectFilesEvent extends AssessmentsEvents{
  final List<File> files;
  const SelectFilesEvent(this.files);
  @override
  // TODO: implement props
  List<Object> get props => [files];

}

class RemoveFileEvent extends AssessmentsEvents{
  final File file;
  const RemoveFileEvent(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class RemoveExitingFileEvent extends AssessmentsEvents{
  final String file;
  const RemoveExitingFileEvent(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}