import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Message extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String messageType;
  final String mainMessageId;
  final String message;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String fileName;
  final String fileLink;
  final String chatType;
  final String groupId;
  final String read;
  final String date;
  final bool deleted;

  Message({
    @required this.id,
    @required this.uniqueId,
    @required this.schoolId,
    this.messageType,
    this.mainMessageId,
    this.message,
    this.senderId,
    this.senderType,
    this.receiverId,
    this.receiverType,
    this.fileName,
    this.fileLink,
    this.chatType,
    this.groupId,
    this.read,
    this.date,
    this.deleted
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    schoolId,
    messageType,
    mainMessageId,
    message,
    senderId,
    senderType,
    receiverId,
    receiverType,
    fileName,
    fileLink,
    chatType,
    groupId,
    read,
    date,
    deleted
  ];
}