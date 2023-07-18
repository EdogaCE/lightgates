import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/subjects/subjects.dart';
import 'package:school_pal/requests/posts/add_edit_delete_subject_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_subjects_request.dart';
import 'package:school_pal/res/strings.dart';

class SubjectsBloc extends Bloc<SubjectsEvents, SubjectsStates>{
  final ViewSubjectsRepository viewSubjectsRepository;
  final AddEditSubjectRepository addEditSubjectRepository;
  SubjectsBloc({this.viewSubjectsRepository, this.addEditSubjectRepository}) : super(SubjectsInitial());

  @override
  Stream<SubjectsStates> mapEventToState(SubjectsEvents event) async*{
    // TODO: implement mapEventToState
    yield SubjectsLoading();
    if(event is ViewSubjectsEvent){
      try{
        final subjects=await viewSubjectsRepository.fetchSubjects(event.apiToken);
        yield SubjectsLoaded(subjects);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddSubjectEvent){
      yield SubjectsProcessing();
      try{
        final message=await addEditSubjectRepository.addSubject(title: event.title);
        yield SubjectAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is EditSubjectEvent){
      yield SubjectsProcessing();
      try{
        final message=await addEditSubjectRepository.editSubject(id: event.id, title: event.title);
        yield SubjectEdited(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteSubjectEvent){
      yield SubjectsProcessing();
      try{
        final message=await viewSubjectsRepository.deleteSubject(event.id);
        yield SubjectDeleted(message);
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