import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/results/results.dart';
import 'package:school_pal/blocs/results/results_events.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/get/view_results_requests.dart';
import 'package:school_pal/requests/posts/result_requests.dart';
import 'package:school_pal/res/strings.dart';

class ResultsBloc extends Bloc<ResultsEvents, ResultsStates>{
  final ViewResultsRepository viewResultsRepository;
  final ResultRepository resultRepository;
  ResultsBloc({this.viewResultsRepository, this.resultRepository}) : super(ResultsInitial());

  @override
  Stream<ResultsStates> mapEventToState(ResultsEvents event) async*{
    // TODO: implement mapEventToState
  if(event is GetSessionsEvent){
      yield Loading();
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
    }else  if(event is GetTermEvent){
    yield Loading();
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
  }else  if(event is GetClassEvent){
    yield Loading();
    try{
      final classes=await getClassesSpinnerValue(event.apiToken);
      yield ClassLoaded(classes);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is GetTeacherClassEvent){
    yield Loading();
    try{
      final classes=await getTeacherClassesSpinnerValue(event.apiToken, event.teacherId);
      yield ClassLoaded(classes);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is GetFormTeacherClassEvent){
    yield Loading();
    try{
      final classes=await getFormTeacherClassesSpinnerValue(event.apiToken, event.teacherId);
      yield ClassLoaded(classes);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else if(event is SelectClassEvent){
    yield ClassSelected(event.clas);
  }else  if(event is ViewClassResultsEvent){
    yield Processing();
    try{
      final classResult=await viewResultsRepository.fetchClassResults(event.sessionId, event.termId, event.classId, event.type);
      yield ClassResultLoaded(classResult);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewSubjectResultsEvent){
    yield Processing();
    try{
      final subjectResult=await viewResultsRepository.fetchSubjectResult(event.resultId, event.subjectId, event.sessionId, event.termId, event.classId, event.type);
      yield SubjectResultLoaded(subjectResult);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ApproveResultsEvent){
    yield Loading();
    try{
      final message=await resultRepository.approveResult(termId: event.termId, sessionId: event.sessionId, classId: event.classId, resultHeaders: event.resultHeaders, resultId: event.resultId, results: event.results, subjectId: event.subjectId, teacherId: event.teacherId, studentUniqueIds: event.studentsUniqueIds, studentsResults: event.studentResult);
      yield ResultApproved(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is DeclineResultsEvent){
    yield Loading();
    try{
      final message=await resultRepository.declineResult(resultId: event.resultId, comment: event.comment, sender: event.sender, senderId: event.senderId);
      yield ResultDeclined(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewStudentResultEvent){
    yield Processing();
    try{
      final result=await viewResultsRepository.fetchStudentResults(studentId: event.studentId, classId: event.classId, termId: event.termId, sessionId: event.sessionId, type: event.type);
      yield StudentResultLoaded(result);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewStudentCumulativeResultEvent){
    yield Processing();
    try{
      final result=await viewResultsRepository.fetchStudentCumulativeResults(studentId: event.studentId, classId: event.classId,  sessionId: event.sessionId, type: event.type);
      yield StudentResultLoaded(result);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewStudentsAttendanceInterfaceEvent){
    yield Processing();
    try{
      final attendance=await viewResultsRepository.fetchStudentsAttendanceInterface(teacherId: event.teacherId, classId: event.classId, termId: event.termId, sessionId: event.sessionId);
      yield StudentsAttendanceInterfaceLoaded(attendance);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewStudentsBehaviouralSkillsInterfaceEvent){
    yield Processing();
    try{
      final behaviouralSkills=await viewResultsRepository.fetchStudentsBehaviouralSkillsInterface(teacherId: event.teacherId, classId: event.classId, termId: event.termId, sessionId: event.sessionId);
      yield StudentsBehaviouralSkillsInterfaceLoaded(behaviouralSkills);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
      }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
    }else  if(event is AddStudentsAttendanceEvent){
    yield Processing();
    try{
      final message=await resultRepository.addStudentsAttendance(classId: event.classId, termId: event.termId, sessionId: event.sessionId, attendanceHeader: event.attendanceHeader, studentsAttendances: event.studentsAttendances);
      yield StudentsAttendanceAdded(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is AddStudentsBehaviouralSkillsEvent){
    yield Processing();
    try{
      final message=await resultRepository.addBehaviouralSkills(classId: event.classId, termId: event.termId, sessionId: event.sessionId, behaviouralSkillsHeader: event.behaviouralSkillsHeader, studentsBehaviouralSkills: event.studentsBehaviouralSkills);
      yield StudentsBehaviouralSkillsAdded(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewTeacherCommentsEvent){
    yield Loading();
    try{
      final comments=await viewResultsRepository.fetchTeacherComments(termId: event.termId, sessionId: event.sessionId, classId: event.classId);
      yield ResultCommentsLoaded(comments);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is ViewPrincipalCommentsEvent){
    yield Loading();
    try{
      final comments=await viewResultsRepository.fetchPrincipalComments(termId: event.termId, sessionId: event.sessionId);
      yield ResultCommentsLoaded(comments);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is AddPrincipalCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.addPrincipalComments(termId: event.termId, sessionId: event.sessionId, remark: event.remark, startLimit: event.startLimit, endLimit: event.endLimit);
      yield ResultCommentsAdded(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is AddTeacherCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.addTeacherComments(classId: event.classId, termId: event.termId, sessionId: event.sessionId, remark: event.remark, startLimit: event.startLimit, endLimit: event.endLimit);
      yield ResultCommentsAdded(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is UpdatePrincipalCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.updatePrincipalComments(commentId: event.commentId, termId: event.termId, sessionId: event.sessionId, remark: event.remark, startLimit: event.startLimit, endLimit: event.endLimit);
      yield ResultCommentsUpdated(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is UpdateTeacherCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.updateTeacherComments(commentId: event.commentId, classId: event.classId, termId: event.termId, sessionId: event.sessionId, remark: event.remark, startLimit: event.startLimit, endLimit: event.endLimit);
      yield ResultCommentsUpdated(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is DeletePrincipalCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.deletePrincipalComments(commentId: event.commentId, termId: event.termId, sessionId: event.sessionId);
      yield ResultCommentsDeleted(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is DeleteTeacherCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.deleteTeacherComments(commentId: event.commentId, classId: event.classId, termId: event.termId, sessionId: event.sessionId);
      yield ResultCommentsDeleted(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is RestorePrincipalCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.restorePrincipalComments(commentId: event.commentId, termId: event.termId, sessionId: event.sessionId);
      yield ResultCommentsRestored(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }else  if(event is RestoreTeacherCommentsEvent){
    yield Processing();
    try{
      final message=await resultRepository.restoreTeacherComments(commentId: event.commentId, classId: event.classId, termId: event.termId, sessionId: event.sessionId);
      yield ResultCommentsRestored(message);
    } on NetworkError{
      yield NetworkErr(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      yield ViewError(e.toString());
    }on SystemError{
      yield NetworkErr(MyStrings.systemErrorMessage);
    }
  }

  }
}