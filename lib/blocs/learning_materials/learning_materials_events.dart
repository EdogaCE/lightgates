import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class LearningMaterialsEvents extends Equatable{
  const LearningMaterialsEvents();
}

class ViewLearningMaterialsEvent extends LearningMaterialsEvents{
  final String apiToken;
  const ViewLearningMaterialsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class GetTeacherClassesEvent extends LearningMaterialsEvents{
  final String apiToken;
  final String teacherId;
  const GetTeacherClassesEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class GetClassesEvent extends LearningMaterialsEvents{
  final String apiToken;
  const GetClassesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectClassEvent extends LearningMaterialsEvents{
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class GetTeacherSubjectsEvent extends LearningMaterialsEvents{
  final String apiToken;
  final String teacherId;
  const GetTeacherSubjectsEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class GetSubjectsEvent extends LearningMaterialsEvents{
  final String apiToken;
  const GetSubjectsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSubjectEvent extends LearningMaterialsEvents{
  final String subject;
  const SelectSubjectEvent(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class AddLearningMaterialEvent extends LearningMaterialsEvents{
  final String classId;
  final List<String> fileName;
  final String description;
  final List<String> video;
  final String title;
  final String teacherId;
  final String subjectId;
  const AddLearningMaterialEvent(this.classId, this.fileName, this.description, this.video, this.title, this.teacherId, this.subjectId);
  @override
  // TODO: implement props
  List<Object> get props => [classId, fileName, description, video, title, teacherId, subjectId];

}

class UpdateLearningMaterialEvent extends LearningMaterialsEvents{
  final String materialId;
  final String classId;
  final List<String> fileName;
  final String description;
  final List<String> video;
  final String title;
  final String teacherId;
  final String subjectId;
  final List<String> filesToDelete;
  const UpdateLearningMaterialEvent(this.materialId, this.classId, this.fileName, this.description, this.video, this.title, this.teacherId, this.subjectId, this.filesToDelete);
  @override
  // TODO: implement props
  List<Object> get props => [materialId, classId, fileName, description, video, title, teacherId, subjectId, filesToDelete];

}

class AddLearningMaterialFileEvent extends LearningMaterialsEvents{
  final String materialId;
  final String fileField;
  final String fileType;
  const AddLearningMaterialFileEvent(this.materialId, this.fileField, this.fileType);
  @override
  // TODO: implement props
  List<Object> get props => [materialId, fileField, fileType];

}

class AddLinkToListEvent extends LearningMaterialsEvents{
  final String link;
  const AddLinkToListEvent(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class RemoveLinkToListEvent extends LearningMaterialsEvents{
  final String link;
  const RemoveLinkToListEvent(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class SelectFilesEvent extends LearningMaterialsEvents{
  final List<File> files;
  const SelectFilesEvent(this.files);
  @override
  // TODO: implement props
  List<Object> get props => [files];

}

class RemoveFileEvent extends LearningMaterialsEvents{
  final File file;
  const RemoveFileEvent(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class RemoveExitingFileEvent extends LearningMaterialsEvents{
  final String file;
  const RemoveExitingFileEvent(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}