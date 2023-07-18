import 'package:equatable/equatable.dart';
import 'package:school_pal/models/ticket_comments.dart';

class Tickets extends Equatable {
  final String id;
  final String uniqueId;
  final String title;
  final String message;
  final String file;
  final String senderType;
  final String senderId;
  final List<TicketComments> comments;

  Tickets(
      {this.id,
      this.uniqueId,
      this.title,
      this.message,
      this.file,
      this.senderType,
      this.senderId,
      this.comments});

  @override
  // TODO: implement props
  List<Object> get props =>
      [id, uniqueId, title, message, file, senderType, senderId, comments];
}
