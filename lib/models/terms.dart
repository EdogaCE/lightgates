import 'package:equatable/equatable.dart';

class Terms extends Equatable {
  final String id;
  final String uniqueId;
  final String term;
  final String date;
  final String status;

  Terms(
      {this.id,
        this.uniqueId,
        this.term,
        this.date,
        this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    term,
    date,
    status
  ];
}
