import 'package:equatable/equatable.dart';

abstract class ClassesEvents extends Equatable{
  const ClassesEvents();
}

class ViewClassesEvent extends ClassesEvents{
  final String apiToken;
  const ViewClassesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewClassCategoriesEvent extends ClassesEvents{
  final String apiToken;
  const ViewClassCategoriesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewClassLabelsEvent extends ClassesEvents{
  final String apiToken;
  const ViewClassLabelsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewClassLevelsEvent extends ClassesEvents{
  final String apiToken;
  const ViewClassLevelsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class AddClassEvent extends ClassesEvents{
  final String classLevelId;
  final String classCategoryId;
  final String classLabelId;
  const AddClassEvent(this.classLevelId, this.classCategoryId, this.classLabelId);
  @override
  // TODO: implement props
  List<Object> get props => [classLevelId, classCategoryId, classLabelId];

}

class UpdateClassEvent extends ClassesEvents{
  final String classId;
  final String classLevelId;
  final String classCategoryId;
  final String classLabelId;
  const UpdateClassEvent(this.classId, this.classLevelId, this.classCategoryId, this.classLabelId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, classLevelId, classCategoryId, classLabelId];

}

class DeleteClassEvent extends ClassesEvents{
  final String classId;
  const DeleteClassEvent(this.classId);
  @override
  // TODO: implement props
  List<Object> get props => [classId];

}

class AddClassCategoryEvent extends ClassesEvents{
  final String category;
  const AddClassCategoryEvent(this.category);
  @override
  // TODO: implement props
  List<Object> get props => [category];

}

class UpdateClassCategoryEvent extends ClassesEvents{
  final String id;
  final String category;
  const UpdateClassCategoryEvent(this.id, this.category);
  @override
  // TODO: implement props
  List<Object> get props => [id, category];

}

class DeleteClassCategoryEvent extends ClassesEvents{
  final String id;
  const DeleteClassCategoryEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}

class AddClassLabelEvent extends ClassesEvents{
  final String label;
  const AddClassLabelEvent(this.label);
  @override
  // TODO: implement props
  List<Object> get props => [label];

}

class UpdateClassLabelEvent extends ClassesEvents{
  final String id;
  final String label;
  const UpdateClassLabelEvent(this.id, this.label);
  @override
  // TODO: implement props
  List<Object> get props => [id, label];

}

class DeleteClassLabelEvent extends ClassesEvents{
  final String id;
  const DeleteClassLabelEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}

class AddClassLevelEvent extends ClassesEvents{
  final String level;
  const AddClassLevelEvent(this.level);
  @override
  // TODO: implement props
  List<Object> get props => [level];

}

class UpdateClassLevelEvent extends ClassesEvents{
  final String id;
  final String level;
  const UpdateClassLevelEvent(this.id, this.level);
  @override
  // TODO: implement props
  List<Object> get props => [id, level];

}

class DeleteClassLevelEvent extends ClassesEvents{
  final String id;
  const DeleteClassLevelEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}
