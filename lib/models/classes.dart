import 'package:equatable/equatable.dart';

class Classes extends Equatable {
  final String id;
  final String uniqueId;
  final String label;
  final String level;
  final String category;
  final String numberOfStudents;
  final String numberOfTeachers;
  final String date;
  final String status;

  Classes(
      {this.id,
      this.uniqueId,
      this.label,
      this.level,
      this.category,
      this.numberOfStudents,
      this.numberOfTeachers,
      this.date,
      this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        uniqueId,
        label,
        level,
        category,
        numberOfStudents,
        numberOfTeachers,
        date,
        status
      ];
}
