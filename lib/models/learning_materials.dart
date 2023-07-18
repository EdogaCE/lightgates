import 'package:equatable/equatable.dart';

class LearningMaterials extends Equatable {
  final String id;
  final String uniqueId;
  final String teacherId;
  final String title;
  final String description;
  final String file;
  final String video;
  final String date;
  final String classDetail;
  final String subjectDetail;
  final String teacherDetail;
  final String fileUrl;
  final String classesId;
  final String subjectId;

  LearningMaterials(
      {this.id,
        this.uniqueId,
        this.teacherId,
        this.title,
        this.description,
        this.file,
        this.video,
        this.date,
        this.classDetail,
        this.subjectDetail,
        this.teacherDetail,
        this.fileUrl,
      this.classesId,
      this.subjectId});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    teacherId,
    title,
    description,
    file,
    video,
    date,
    classDetail,
    subjectDetail,
    teacherDetail,
    fileUrl,
    classesId,
    subjectId
  ];
}
