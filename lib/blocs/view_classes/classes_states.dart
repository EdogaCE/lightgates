import 'package:equatable/equatable.dart';
import 'package:school_pal/models/class_categories.dart';
import 'package:school_pal/models/class_labels.dart';
import 'package:school_pal/models/class_levels.dart';
import 'package:school_pal/models/classes.dart';

abstract class ClassesStates extends Equatable{
  const ClassesStates();
}

class ClassesInitial extends ClassesStates{
  const ClassesInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends ClassesStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends ClassesStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ClassesLoaded extends ClassesStates{
  final List<Classes> classes;
  const ClassesLoaded(this.classes);
  @override
  // TODO: implement props
  List<Object> get props => [classes];
}

class ClassCategoriesLoaded extends ClassesStates{
  final List<ClassCategory> classCategory;
  const ClassCategoriesLoaded(this.classCategory);
  @override
  // TODO: implement props
  List<Object> get props => [classCategory];
}

class ClassLabelsLoaded extends ClassesStates{
  final List<ClassLabels> classLabels;
  const ClassLabelsLoaded(this.classLabels);
  @override
  // TODO: implement props
  List<Object> get props => [classLabels];
}

class ClassLevelsLoaded extends ClassesStates{
  final List<ClassLevels> classLevels;
  const ClassLevelsLoaded(this.classLevels);
  @override
  // TODO: implement props
  List<Object> get props => [classLevels];
}

class ClassAdded extends ClassesStates{
  final String message;
  const ClassAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassUpdated extends ClassesStates{
  final String message;
  const ClassUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassDeleted extends ClassesStates{
  final String message;
  const ClassDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassCategoryAdded extends ClassesStates{
  final String message;
  const ClassCategoryAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassCategoryUpdated extends ClassesStates{
  final String message;
  const ClassCategoryUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassCategoryDeleted extends ClassesStates{
  final String message;
  const ClassCategoryDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLabelAdded extends ClassesStates{
  final String message;
  const ClassLabelAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLabelUpdated extends ClassesStates{
  final String message;
  const ClassLabelUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLabelDeleted extends ClassesStates{
  final String message;
  const ClassLabelDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLevelAdded extends ClassesStates{
  final String message;
  const ClassLevelAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLevelUpdated extends ClassesStates{
  final String message;
  const ClassLevelUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ClassLevelDeleted extends ClassesStates{
  final String message;
  const ClassLevelDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends ClassesStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends ClassesStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}