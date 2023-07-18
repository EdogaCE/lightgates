import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_teachers_request.dart';
import 'package:school_pal/res/strings.dart';

class TeachersBloc extends Bloc<TeachersEvents, TeachersStates>{
  final ViewTeachersRepository viewTeachersRepository;
  final UpdateProfileRepository updateProfileRepository;
  TeachersBloc({this.viewTeachersRepository, this.updateProfileRepository}) : super(TeachersInitial());


  @override
  Stream<TeachersStates> mapEventToState(TeachersEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewTeachersEvent){
      yield TeachersLoading();
      try{
        final teachers=await viewTeachersRepository.fetchTeachers(apiToken: event.apiToken, localDb: event.localDb);
        yield TeachersLoaded(teachers);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddFormTeacherEvent){
      yield TeachersProcessing();
      try{
        final message=await updateProfileRepository.addFormTeacher(classId: event.classId, sessionId: event.sessionId, termId: event.termId, teacherId: event.teacherId);
        yield FormTeacherAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is RemoveFormTeacherEvent){
      yield TeachersProcessing();
      try{
        final message=await updateProfileRepository.removeFormTeacher(classId: event.classId, assignedId: event.assignedId, teacherId: event.teacherId);
        yield FormTeacherRemoved(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetSessionsEvent){
      yield TeachersLoading();
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
      yield TeachersLoading();
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
      yield TeachersLoading();
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
    }else if(event is SelectClassEvent){
      yield ClassSelected(event.clas);
    }else if(event is GetSubjectsEvent){
      yield TeachersLoading();
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
    }else if(event is AddTeacherClassSubjectEvent){
      yield TeachersProcessing();
      try{
        final message=await updateProfileRepository.addTeacherClassSubject(teacherId: event.teacherId, subjectId: event.subjectId, classId: event.classId, sessionId: event.sessionId, termId: event.termId);
        yield TeacherClassSubjectAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateTeacherClassSubjectEvent){
      yield TeachersProcessing();
      try{
        final message=await updateProfileRepository.updateTeacherClassSubject(assignmentId: event.assignmentId, teacherId: event.teacherId, subjectId: event.subjectId, classId: event.classId);
        yield TeacherClassSubjectUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteTeacherClassSubjectEvent){
      yield TeachersProcessing();
      try{
        final message=await updateProfileRepository.deleteTeacherClassSubject(assignmentId: event.assignmentId);
        yield TeacherClassSubjectRemoved(message);
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