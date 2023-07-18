import 'package:equatable/equatable.dart';
import 'package:school_pal/models/events.dart';

abstract class EventsStates extends Equatable{
  const EventsStates();
}

class EventsInitial extends EventsStates{
  const EventsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class EventsLoading extends EventsStates{
  const EventsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class EventsLoaded extends EventsStates{
  final List<Events> events;
  const EventsLoaded(this.events);
  @override
  // TODO: implement props
  List<Object> get props => [events];
}

class DateFromChanged extends EventsStates{
  final DateTime from;
  const DateFromChanged(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class DateToChanged extends EventsStates{
  final DateTime to;
  const DateToChanged(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class EventAdded extends EventsStates{
  final String message;
  const EventAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class EventUpdated extends EventsStates{
  final String message;
  const EventUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class EventDeleted extends EventsStates{
  final String message;
  const EventDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends EventsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends EventsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}