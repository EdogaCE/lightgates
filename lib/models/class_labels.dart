import 'package:equatable/equatable.dart';

class ClassLabels extends Equatable {
  final String id;
  final String uniqueId;
  final String label;
  final String date;
  final String status;

  ClassLabels(
      {this.id,
        this.uniqueId,
        this.label,
        this.date,
        this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    label,
    date,
    status
  ];
}
