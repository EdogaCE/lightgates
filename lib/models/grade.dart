import 'package:equatable/equatable.dart';

class Grade extends Equatable {
  final String id;
  final String uniqueId;
  final String startLimit;
  final String endLimit;
  final String grade;
  final String remark;
  final bool deleted;

  Grade(
      {this.id,
      this.uniqueId,
      this.startLimit,
      this.endLimit,
      this.grade,
      this.remark,
      this.deleted});

  @override
  // TODO: implement props
  List<Object> get props =>
      [id, uniqueId, startLimit, endLimit, grade, remark, deleted];
}
