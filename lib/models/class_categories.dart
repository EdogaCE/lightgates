import 'package:equatable/equatable.dart';

class ClassCategory extends Equatable {
  final String id;
  final String uniqueId;
  final String category;
  final String date;
  final String status;

  ClassCategory(
      {this.id,
        this.uniqueId,
        this.category,
        this.date,
        this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    category,
    date,
    status
  ];
}
