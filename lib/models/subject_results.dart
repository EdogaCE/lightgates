import 'package:equatable/equatable.dart';
import 'package:school_pal/models/class_results.dart';

import 'grade.dart';

class SubjectResult extends Equatable {
  final List<List<String>> resultDetail;
  final ClassResults classResults;
  final List<Grade> grade;

  SubjectResult(
      {this.resultDetail,
        this.classResults,
      this.grade});

  @override
  // TODO: implement props
  List<Object> get props => [
    resultDetail,
    classResults,
    grade
  ];
}
