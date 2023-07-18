import 'package:equatable/equatable.dart';
import 'package:school_pal/models/tickets.dart';

abstract class TicketsStates extends Equatable{
  const TicketsStates();
}

class TicketsInitial extends TicketsStates{
  const TicketsInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends TicketsStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends TicketsStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TicketsLoaded extends TicketsStates{
  final List<Tickets> tickets;
  const TicketsLoaded(this.tickets);
  @override
  // TODO: implement props
  List<Object> get props => [tickets];
}

class TicketCategoriesLoaded extends TicketsStates{
  final List<List<String>> categories;
  const TicketCategoriesLoaded(this.categories);
  @override
  // TODO: implement props
  List<Object> get props => [categories];
}

class SpinnerDataSelected extends TicketsStates{
  final String selectedData;
  const SpinnerDataSelected(this.selectedData);
  @override
  // TODO: implement props
  List<Object> get props => [selectedData];
}

class TicketCreated extends TicketsStates{
  final String message;
  const TicketCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class CommentCreated extends TicketsStates{
  final String message;
  const CommentCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends TicketsStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends TicketsStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}