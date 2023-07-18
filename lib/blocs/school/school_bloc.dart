import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/school/school.dart';
import 'package:school_pal/requests/get/view_school_grades_request.dart';
import 'package:school_pal/requests/posts/add_edit_grade_request.dart';
import 'package:school_pal/requests/posts/add_edit_session_request.dart';
import 'package:school_pal/requests/posts/add_edit_term_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_school_session_requests.dart';
import 'package:school_pal/requests/get/view_school_term_requests.dart';
import 'package:school_pal/res/strings.dart';

class SchoolBloc extends Bloc<SchoolEvents, SchoolStates>{
  final ViewSchoolSessionRepository viewSchoolSessionRepository;
  final ViewSchoolTermRepository viewSchoolTermRepository;
  final ViewSchoolGradesRepository viewSchoolGradesRepository;
  final AddEditGradeRepository addEditGradeRepository;
  final AddEditSessionRepository addEditSessionRepository;
  final AddEditTermRepository addEditTermRepository;
  SchoolBloc({this.viewSchoolSessionRepository, this.viewSchoolTermRepository, this.viewSchoolGradesRepository, this.addEditGradeRepository, this.addEditSessionRepository, this.addEditTermRepository}) : super(SchoolInitial());


  @override
  Stream<SchoolStates> mapEventToState(SchoolEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewSessionsEvent){
      yield Loading();
      try{
        final session=await viewSchoolSessionRepository.fetchSchoolSession(event.apiToken);
        yield SessionsLoaded(session);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ActivateSessionEvent){
      yield Processing('Activating Session...');
      try{
        final session=await viewSchoolSessionRepository.activateSchoolSession(event.id);
        yield SessionActivated(session);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewTermsEvent){
      yield Loading();
      try{
        final term=await viewSchoolTermRepository.fetchSchoolTerm(event.apiToken);
        yield TermsLoaded(term);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ActivateTermEvent){
      yield Processing('Activating Term...');
      try{
        final term=await addEditTermRepository.activateTerm(termId: event.termId, sessionId: event.sessionId, startDate: event.startDate, endDate: event.endDate);
        yield TermActivated(term);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ActivateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddTermEvent){
      yield Processing('Processing...');
      try{
        final terms=await addEditTermRepository.addTerm(term: event.term);
        yield TermAdded(terms);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateTermEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditTermRepository.editTerm(id: event.id,term: event.term);
        yield TermUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewGradesEvent){
      yield Loading();
      try{
        final grades=await viewSchoolGradesRepository.fetchSchoolGrade(event.apiToken);
        yield GradesLoaded(grades);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddGradeEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditGradeRepository.addGrade(grade: event.grade, remark: event.remark, endLimit: event.endLimit, startLimit: event.startLimit);
        yield GradeAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateGradeEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditGradeRepository.updateGrade(gradeId: event.gradeId,grade: event.grade, remark: event.remark, endLimit: event.endLimit, startLimit: event.startLimit);
        yield GradeUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteGradeEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditGradeRepository.deleteGrade(gradeId: event.gradeId);
        yield GradeDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is RestoreGradeEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditGradeRepository.restoreGrade(gradeId: event.gradeId);
        yield GradeRestored(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddSessionEvent){
      yield Processing('Processing...');
      try{
        final sessions=await addEditSessionRepository.addSession(admissionNumberPrefix: event.admissionNumberPrefix, sessionDate: event.sessionDate, sessionStartDate: event.sessionStartDate, sessionEndDate: event.sessionEndDate);
        yield SessionAdded(sessions);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateSessionEvent){
      yield Processing('Processing...');
      try{
        final message=await addEditSessionRepository.editSession(admissionNumberPrefix: event.admissionNumberPrefix, sessionDate: event.sessionDate, sessionStartDate: event.sessionStartDate, sessionEndDate: event.sessionEndDate, id: event.id);
        yield SessionUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ReorderTermEvent){
      yield TermReordered(event.oldIndex, event.newIndex);
    }else if(event is RearrangeTermEvent){
      yield Processing('Processing...');
      try{
        final terms=await addEditTermRepository.rearrangeTerm(termId: event.termId);
        yield TermsLoaded(terms);
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