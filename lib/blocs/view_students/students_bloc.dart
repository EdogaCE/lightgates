import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/view_students/students.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_students_request.dart';
import 'package:school_pal/res/strings.dart';

class StudentsBloc extends Bloc<StudentsEvents, StudentsStates>{
  final ViewStudentsRepository viewStudentsRepository;
  final UpdateProfileRepository updateProfileRepository;
  StudentsBloc({this.viewStudentsRepository, this.updateProfileRepository}) : super(StudentsInitial());


  @override
  Stream<StudentsStates> mapEventToState(StudentsEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewStudentsEvent){
      yield StudentsLoading();
      try{
        final students=await viewStudentsRepository.fetchStudents(apiToken: event.apiToken, localDb: event.localDb);
        yield StudentsLoaded(students);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteStudentEvent){
      yield StudentsProcessing();
      try{
        final message=await updateProfileRepository.deleteStudentProfile(studentId: event.studentId);
        yield StudentDeleted(message);
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