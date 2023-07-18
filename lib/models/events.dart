import 'package:equatable/equatable.dart';

class Events extends Equatable {
  final String id;
  final String uniqueId;
  final String titleOfEvent;
  final String description;
  final String date;
  final String status;

  Events(
      {this.id,
        this.uniqueId,
        this.titleOfEvent,
        this.description,
        this.date,
        this.status});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    titleOfEvent,
    description,
    date,
    status
  ];
}
