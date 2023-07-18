import 'package:equatable/equatable.dart';

abstract class EventsEvents extends Equatable{
  const EventsEvents();
}

class ViewEventsEvent extends EventsEvents{
  final String apiToken;
  const ViewEventsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ChangeDateFromEvent extends EventsEvents{
  final DateTime from;
  const ChangeDateFromEvent(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class ChangeDateToEvent extends EventsEvents{
  final DateTime to;
  const ChangeDateToEvent(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class AddSchoolEvent extends EventsEvents{
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  AddSchoolEvent(this.title, this.description, this.startDate, this.endDate);
  @override
  // TODO: implement props
  List<Object> get props => [title, description, startDate, endDate];
}

class UpdateSchoolEvent extends EventsEvents{
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  UpdateSchoolEvent(this.id, this.title, this.description, this.startDate, this.endDate);
  @override
  // TODO: implement props
  List<Object> get props => [id, title, description, startDate, endDate];
}

class DeleteSchoolEvent extends EventsEvents{
  final String id;
  DeleteSchoolEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];
}