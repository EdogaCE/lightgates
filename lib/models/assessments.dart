import 'package:equatable/equatable.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/terms.dart';

class Assessments extends Equatable {
  final String id;
  final String uniqueId;
  final String teacherId;
  final String type;
  final String title;
  final String content;
  final String file;
  final String submissionMode;
  final String noOfSubmission;
  final String date;
  final String instructions;
  final String term;
  final String termStatus;
  final String session;
  final String sessionMode;
  final String classDetail;
  final String subjectDetail;
  final String teacherDetail;
  final String fileUrl;
  final String sessionId;
  final String termId;
  final String classesId;
  final String subjectId;

  Assessments(
      {this.id,
        this.uniqueId,
        this.teacherId,
        this.type,
        this.title,
        this.content,
        this.file,
        this.submissionMode,
        this.noOfSubmission,
        this.date,
        this.instructions,
        this.term,
        this.termStatus,
        this.session,
        this.sessionMode,
        this.classDetail,
        this.subjectDetail,
        this.teacherDetail,
        this.fileUrl,
      this.sessionId,
      this.termId,
      this.classesId,
      this.subjectId});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    teacherId,
    type,
    title,
    content,
    file,
    submissionMode,
    noOfSubmission,
    date,
    instructions,
    term,
    termStatus,
    session,
    sessionMode,
    classDetail,
    subjectDetail,
    teacherDetail,
    fileUrl,
    sessionId,
    termId,
    classesId,
    subjectId
  ];
}
