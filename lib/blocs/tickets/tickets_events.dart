import 'package:equatable/equatable.dart';

abstract class TicketsEvents extends Equatable{
  const TicketsEvents();
}

class ViewTicketsEvent extends TicketsEvents{
  final String apiToken;
  const ViewTicketsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewTicketCategoriesEvent extends TicketsEvents{
  final String apiToken;
  const ViewTicketCategoriesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class CreateTicketEvent extends TicketsEvents{
  final String title;
  final String categoryId;
  final String message;
  CreateTicketEvent(this.title, this.categoryId, this.message);
  @override
  // TODO: implement props
  List<Object> get props => [title, categoryId, message];
}

class CreateTicketCommentEvent extends TicketsEvents{
  final String senderId;
  final String ticketId;
  final String comment;
  CreateTicketCommentEvent(this.senderId, this.ticketId, this.comment);
  @override
  // TODO: implement props
  List<Object> get props => [senderId, ticketId, comment];
}

class SelectSpinnerDataEvent extends TicketsEvents{
  final String selectedData;
  const SelectSpinnerDataEvent(this.selectedData);
  @override
  // TODO: implement props
  List<Object> get props => [selectedData];

}
