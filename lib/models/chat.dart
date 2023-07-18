import 'package:equatable/equatable.dart';
import 'contact.dart';
import 'group.dart';
import 'message.dart';

class Chat extends Equatable {
  final Message message;
  final Message lastMessage;
  final Contact sender;
  final Contact receiver;
  final Group receivers;
  final String readReceiptCount;


  Chat({
    this.message,
    this.lastMessage,
    this.sender,
    this.receiver,
    this.receivers,
    this.readReceiptCount,
  });

  @override
  List<Object> get props => [
    message,
    lastMessage,
    sender,
    receiver,
    receivers,
    readReceiptCount
  ];
}