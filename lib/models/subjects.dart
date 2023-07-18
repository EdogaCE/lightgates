import 'package:equatable/equatable.dart';

class Subjects extends Equatable {
  final String id;
  final String uniqueId;
  final String title;
  final String status;
  final String date;

  Subjects(
      {this.id,
        this.uniqueId,
        this.title,
        this.status,
        this.date,});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    title,
    status,
    date,
  ];
}
