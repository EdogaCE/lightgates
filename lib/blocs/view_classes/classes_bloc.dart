import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/view_classes/classes.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_category_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_label_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_level_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class ClassesBloc extends Bloc<ClassesEvents, ClassesStates>{
  final viewRepository;
  final AddEditClassRepository addEditClassRepository;
  final AddEditClassCategoryRepository addEditClassCategoryRepository;
  final AddEditClassLabelRepository addEditClassLabelRepository;
  final AddEditClassLevelRepository addEditClassLevelRepository;
  ClassesBloc({this.viewRepository, this.addEditClassRepository, this.addEditClassCategoryRepository, this.addEditClassLabelRepository, this.addEditClassLevelRepository}) : super(ClassesInitial());


  @override
  Stream<ClassesStates> mapEventToState(ClassesEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewClassesEvent){
      yield Loading();
      try{
        final classes=await viewRepository.fetchClasses(event.apiToken);
        yield ClassesLoaded(classes);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewClassCategoriesEvent){
      yield Loading();
      try{
        final classCategories=await viewRepository.fetchClassCategories(event.apiToken);
        yield ClassCategoriesLoaded(classCategories);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewClassLabelsEvent){
      yield Loading();
      try{
        final classLabels=await viewRepository.fetchClassLabels(event.apiToken);
        yield ClassLabelsLoaded(classLabels);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewClassLevelsEvent){
      yield Loading();
      try{
        final classLevels=await viewRepository.fetchClassLevels(event.apiToken);
        yield ClassLevelsLoaded(classLevels);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddClassEvent){
      yield Processing();
      try{
        final message=await addEditClassRepository.addClass(classCategoryId: event.classCategoryId, classLabelId: event.classLabelId, classLevelId: event.classLevelId);
        yield ClassAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateClassEvent){
      yield Processing();
      try{
        final message=await addEditClassRepository.editClass(classId: event.classId,classCategoryId: event.classCategoryId, classLabelId: event.classLabelId, classLevelId: event.classLevelId);
        yield ClassUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteClassEvent){
      yield Processing();
      try{
        final message=await addEditClassRepository.deleteClass(classId: event.classId);
        yield ClassDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddClassCategoryEvent){
      yield Processing();
      try{
        final message=await addEditClassCategoryRepository.addClassCategory(category: event.category);
        yield ClassCategoryAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateClassCategoryEvent){
      yield Processing();
      try{
        final message=await addEditClassCategoryRepository.editClassCategory(id: event.id,category: event.category);
        yield ClassCategoryUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteClassCategoryEvent){
      yield Processing();
      try{
        final message=await addEditClassCategoryRepository.deleteClassCategory(id: event.id);
        yield ClassCategoryDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddClassLabelEvent){
      yield Processing();
      try{
        final message=await addEditClassLabelRepository.addClassLabel(label: event.label);
        yield ClassLabelAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateClassLabelEvent){
      yield Processing();
      try{
        final message=await addEditClassLabelRepository.editClassLabel(id: event.id, label: event.label);
        yield ClassLabelUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteClassLabelEvent){
      yield Processing();
      try{
        final message=await addEditClassLabelRepository.deleteClassLabel(id: event.id);
        yield ClassLabelDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddClassLevelEvent){
      yield Processing();
      try{
        final message=await addEditClassLevelRepository.addClassLevel(level: event.level);
        yield ClassLevelAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateClassLevelEvent){
      yield Processing();
      try{
        final message=await addEditClassLevelRepository.editClassLevel(id: event.id, level: event.level);
        yield ClassLevelUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteClassLevelEvent){
      yield Processing();
      try{
        final message=await addEditClassLevelRepository.deleteClassLevel(id: event.id);
        yield ClassLevelDeleted(message);
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