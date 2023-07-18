import 'package:equatable/equatable.dart';
import 'package:school_pal/models/assessments.dart';
import 'dart:io';

abstract class AssessmentsStates extends Equatable{
  const AssessmentsStates();
}

class AssessmentsInitial extends AssessmentsStates{
  const AssessmentsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AssessmentsLoading extends AssessmentsStates{
  const AssessmentsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends AssessmentsStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AssessmentsLoaded extends AssessmentsStates{
  final List<Assessments> assessments;
  const AssessmentsLoaded(this.assessments);
  @override
  // TODO: implement props
  List<Object> get props => [assessments];
}

class AssessmentFileAdded extends AssessmentsStates{
  final String fileName;
  const AssessmentFileAdded(this.fileName);
  @override
  // TODO: implement props
  List<Object> get props => [fileName];
}

class AssessmentAdded extends AssessmentsStates{
  final String message;
  const AssessmentAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class AssessmentUpdated extends AssessmentsStates{
  final String message;
  const AssessmentUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SessionsLoaded extends AssessmentsStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends AssessmentsStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class TermsLoaded extends AssessmentsStates{
  final List<List<String>> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermSelected extends AssessmentsStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ClassesLoaded extends AssessmentsStates{
  final List<List<String>> classes;
  const ClassesLoaded(this.classes);
  @override
  // TODO: implement props
  List<Object> get props => [classes];
}

class ClassSelected extends AssessmentsStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class SubjectsLoaded extends AssessmentsStates{
  final List<List<String>> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  // TODO: implement props
  List<Object> get props => [subjects];
}

class SubjectSelected extends AssessmentsStates{
  final String subject;
  const SubjectSelected(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class TypeSelected extends AssessmentsStates{
  final String type;
  const TypeSelected(this.type);
  @override
  // TODO: implement props
  List<Object> get props => [type];

}

class SubmissionModeSelected extends AssessmentsStates{
  final String mode;
  const SubmissionModeSelected(this.mode);
  @override
  // TODO: implement props
  List<Object> get props => [mode];

}

class AddedDateChanged extends AssessmentsStates{
  final DateTime date;
  const AddedDateChanged(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];

}

class SubmissionDateChanged extends AssessmentsStates{
  final DateTime date;
  const SubmissionDateChanged(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];

}

class FilesSelected extends AssessmentsStates{
  final List<File> files;
  const FilesSelected(this.files);
  @override
  // TODO: implement props
  List<Object> get props => [files];

}

class FileRemoved extends AssessmentsStates{
  final File file;
  const FileRemoved(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class ExistingFileRemoved extends AssessmentsStates{
  final String file;
  const ExistingFileRemoved(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class ViewError extends AssessmentsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends AssessmentsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}