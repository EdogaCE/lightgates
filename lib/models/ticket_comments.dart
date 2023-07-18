import 'package:equatable/equatable.dart';

class TicketComments extends Equatable {
  final String id;
  final String uniqueId;
  final String comment;
  final String senderId;

  TicketComments(
      {this.id,
      this.uniqueId,
      this.comment,
      this.senderId});

  @override
  // TODO: implement props
  List<Object> get props =>
      [id, uniqueId, comment, senderId];
}
