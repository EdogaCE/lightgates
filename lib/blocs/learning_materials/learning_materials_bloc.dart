import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/learning_materials/learning_materials.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_learning_materials_request.dart';
import 'package:school_pal/requests/posts/add_edit_learning_material_request.dart';
import 'package:school_pal/res/strings.dart';

class LearningMaterialsBloc extends Bloc<LearningMaterialsEvents, LearningMaterialsStates>{
  final ViewLearningMaterialsRepository viewLearningMaterialsRepository;
  final LearningMaterialRepository learningMaterialRepository;
  LearningMaterialsBloc({this.viewLearningMaterialsRepository, this.learningMaterialRepository}) : super(LearningMaterialsInitial());

  @override
  Stream<LearningMaterialsStates> mapEventToState(LearningMaterialsEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewLearningMaterialsEvent){
      yield LearningMaterialsLoading();
      try{
        final learningMaterials=await viewLearningMaterialsRepository.fetchLearningMaterials(event.apiToken);
        yield LearningMaterialsLoaded(learningMaterials);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetTeacherClassesEvent){
      yield LearningMaterialsLoading();
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
      yield LearningMaterialsLoading();
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
      yield LearningMaterialsLoading();
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
      yield LearningMaterialsLoading();
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
    }else if(event is AddLearningMaterialFileEvent){
      yield Processing();
      try{
        final fileName=await learningMaterialRepository.addLearningMaterialFile(materialId: event.materialId, fileType: event.fileType, fileField: event.fileField);
        yield LearningMaterialFileAdded(fileName);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddLearningMaterialEvent){
      yield Processing();
      try{
        final message=await learningMaterialRepository.addLearningMaterial(title: event.title, classId: event.classId, subjectId: event.subjectId, teacherId: event.teacherId, fileName: event.fileName, description: event.description, video: event.video);
        yield LearningMaterialAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateLearningMaterialEvent){
      yield Processing();
      try{
        final message=await learningMaterialRepository.updateLearningMaterial(materialId: event.materialId, title: event.title, classId: event.classId, subjectId: event.subjectId, teacherId: event.teacherId, fileName: event.fileName, description: event.description, video: event.video, filesToDelete: event.filesToDelete);
        yield LearningMaterialUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddLinkToListEvent){
      yield LinkAddedToList(event.link);
    }else if(event is RemoveLinkToListEvent){
      yield LinkRemovedFromList(event.link);
    }else if(event is SelectFilesEvent){
      yield FilesSelected(event.files);
    }else if(event is RemoveFileEvent){
      yield FileRemoved(event.file);
    }else if(event is RemoveExitingFileEvent){
      yield ExitingFileRemoved(event.file);
    }
  }

}