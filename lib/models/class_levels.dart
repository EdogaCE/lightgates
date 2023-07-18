import 'package:equatable/equatable.dart';

class ClassLevels extends Equatable {
  final String id;
  final String uniqueId;
  final String level;
  final String date;
  final String status;

  ClassLevels(
      {this.id,
        this.uniqueId,
        this.level,
        this.date,
        this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    level,
    date,
    status
  ];
}
