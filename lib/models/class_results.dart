import 'package:equatable/equatable.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';

class ClassResults extends Equatable {
  final String id;
  final String uniqueId;
  final Classes classes;
  final Sessions sessions;
  final Terms terms;
  final Subjects subjects;
  final Teachers teachers;
  final String confirmationStatus;
  final String fileName;
  final String reasonForDecline;


  ClassResults(
      {this.id,
        this.uniqueId,
        this.classes,
        this.sessions,
        this.terms,
        this.subjects,
        this.teachers,
      this.confirmationStatus,
      this.fileName,
      this.reasonForDecline});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    classes,
    sessions,
    terms,
    subjects,
    teachers,
    confirmationStatus,
    fileName,
    reasonForDecline
  ];
}
