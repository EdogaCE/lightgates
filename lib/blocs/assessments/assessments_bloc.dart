import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/assessments/assessments.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/get/view_assessments_request.dart';
import 'package:school_pal/requests/posts/add_edit_assessment_request.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';

class AssessmentsBloc extends Bloc<AssessmentsEvents, AssessmentsStates>{
  final ViewAssessmentsRepository viewAssessmentsRepository;
  final AssessmentRepository assessmentRepository;
  AssessmentsBloc({this.viewAssessmentsRepository, this.assessmentRepository})
      : super(AssessmentsInitial());

  @override
  Stream<AssessmentsStates> mapEventToState(AssessmentsEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewAssessmentsEvent){
      yield AssessmentsLoading();
      try{
        final assessments=await viewAssessmentsRepository.fetchAssessments(event.apiToken);
        yield AssessmentsLoaded(assessments);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      } on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddAssessmentEvent){
      yield Processing();
      try{
        final message=await assessmentRepository.addAssessment(teacherId: event.teacherId, subjectId: event.subjectId, classId: event.classId, sessionId: event.sessionId, termId: event.termId, type: event.type, content: event.content, title: event.title, instructions: event.instructions, files: event.files, submissionDate: event.submissionDate, submissionMode: event.submissionMode);
        yield AssessmentAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateAssessmentEvent){
      yield Processing();
      try{
        final message=await assessmentRepository.updateAssessment(assessmentId: event.assessmentId,teacherId: event.teacherId, subjectId: event.subjectId, classId: event.classId, sessionId: event.sessionId, termId: event.termId, type: event.type, content: event.content, title: event.title, instructions: event.instructions, files: event.files, submissionDate: event.submissionDate, submissionMode: event.submissionMode, filesToDelete: event.filesToDelete);
        yield AssessmentUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddAssessmentFilesEvent){
      yield Processing();
      try{
        final message=await assessmentRepository.addAssessmentFile(assessmentId: event.assessmentId,fileField: event.fileField, fileType: event.fileType);
        yield AssessmentFileAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetSessionsEvent){
      yield AssessmentsLoading();
      try{
        final sessions=await getSessionSpinnerValue(event.apiToken);
        yield SessionsLoaded(sessions);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectSessionEvent){
      yield SessionSelected(event.session);
    }else if(event is GetTermsEvent){
      yield AssessmentsLoading();
      try{
        final terms=await getTermSpinnerValue(event.apiToken);
        yield TermsLoaded(terms);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectTermEvent){
      yield TermSelected(event.term);
    }else if(event is GetTeacherClassesEvent){
      yield AssessmentsLoading();
      try{
        final classes=await getTeacherClassesSpinnerValue(event.apiToken, event.teacherId);
        yield ClassesLoaded(classes);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetClassesEvent){
      yield AssessmentsLoading();
      try{
        final classes=await getClassesSpinnerValue(event.apiToken);
        yield ClassesLoaded(classes);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectClassEvent){
      yield ClassSelected(event.clas);
    }else if(event is GetTeacherSubjectsEvent){
      yield AssessmentsLoading();
      try{
        final subjects=await getTeacherSubjectsSpinnerValue(event.apiToken, event.teacherId);
        yield SubjectsLoaded(subjects);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetSubjectsEvent){
      yield AssessmentsLoading();
      try{
        final subjects=await getSubjectsSpinnerValue(event.apiToken);
        yield SubjectsLoaded(subjects);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectSubjectEvent){
      yield SubjectSelected(event.subject);
    }else if(event is SelectTypeEvent){
      yield TypeSelected(event.type);
    }else if(event is SelectSubmissionModeEvent){
      yield SubmissionModeSelected(event.mode);
    }else if(event is ChangeSubmissionDateEvent){
      yield SubmissionDateChanged(event.date);
    }else if(event is SelectFilesEvent){
      yield FilesSelected(event.files);
    }else if(event is RemoveFileEvent){
      yield FileRemoved(event.file);
    }else if(event is RemoveExitingFileEvent){
      yield ExistingFileRemoved(event.file);
    }
  }


}