import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:school_pal/models/learning_materials.dart';

abstract class LearningMaterialsStates extends Equatable{
  const LearningMaterialsStates();
}

class LearningMaterialsInitial extends LearningMaterialsStates{
  const LearningMaterialsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LearningMaterialsLoading extends LearningMaterialsStates{
  const LearningMaterialsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends LearningMaterialsStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LearningMaterialsLoaded extends LearningMaterialsStates{
  final List<LearningMaterials> learningMaterials;
  const LearningMaterialsLoaded(this.learningMaterials);
  @override
  // TODO: implement props
  List<Object> get props => [learningMaterials];
}

class TermSelected extends LearningMaterialsStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ClassesLoaded extends LearningMaterialsStates{
  final List<List<String>> classes;
  const ClassesLoaded(this.classes);
  @override
  // TODO: implement props
  List<Object> get props => [classes];
}

class ClassSelected extends LearningMaterialsStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class SubjectsLoaded extends LearningMaterialsStates{
  final List<List<String>> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  // TODO: implement props
  List<Object> get props => [subjects];
}

class SubjectSelected extends LearningMaterialsStates{
  final String subject;
  const SubjectSelected(this.subject);
  @override
  // TODO: implement props
  List<Object> get props => [subject];

}

class LearningMaterialFileAdded extends LearningMaterialsStates{
  final String fileName;
  const LearningMaterialFileAdded(this.fileName);
  @override
  // TODO: implement props
  List<Object> get props => [fileName];
}

class LearningMaterialAdded extends LearningMaterialsStates{
  final String message;
  const LearningMaterialAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class LearningMaterialUpdated extends LearningMaterialsStates{
  final String message;
  const LearningMaterialUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class LinkAddedToList extends LearningMaterialsStates{
  final String link;
  const LinkAddedToList(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class LinkRemovedFromList extends LearningMaterialsStates{
  final String link;
  const LinkRemovedFromList(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class FilesSelected extends LearningMaterialsStates{
  final List<File> files;
  const FilesSelected(this.files);
  @override
  // TODO: implement props
  List<Object> get props => [files];

}

class FileRemoved extends LearningMaterialsStates{
  final File file;
  const FileRemoved(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class ExitingFileRemoved extends LearningMaterialsStates{
  final String file;
  const ExitingFileRemoved(this.file);
  @override
  // TODO: implement props
  List<Object> get props => [file];

}

class ViewError extends LearningMaterialsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends LearningMaterialsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}