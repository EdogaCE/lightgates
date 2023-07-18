import 'package:equatable/equatable.dart';
import 'package:school_pal/models/contact.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class ChatEvents extends Equatable{
  const ChatEvents();
}

class ViewChatContactsEvent extends ChatEvents{
  final String apiToken;
  final String userId;
  final String userType;
  final bool localDb;
  const ViewChatContactsEvent(this.apiToken, this.userId, this.userType, this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, userId, userType, localDb];

}

class ViewChatGroupsEvent extends ChatEvents{
  final String apiToken;
  final String userId;
  final bool localDb;
  const ViewChatGroupsEvent(this.apiToken, this.userId, this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, userId, localDb];

}

class ViewChatsEvent extends ChatEvents{
  final String apiToken;
  final String userId;
  final bool localDb;
  const ViewChatsEvent(this.apiToken, this.userId, this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, userId, localDb];

}

class ViewChatMessagesEvent extends ChatEvents{
  final String apiToken;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String groupId;
  final String chatType;
  final bool localDb;
  const ViewChatMessagesEvent(this.apiToken, this.senderId, this.senderType, this.receiverId, this.receiverType, this.groupId, this.chatType, this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, senderId, senderType, receiverId, receiverType, groupId, chatType, localDb];

}

class CreateGroupEvent extends ChatEvents{
  final String creatorId;
  final String creatorType;
  final String groupName;
  final String description;
  const CreateGroupEvent(this.creatorId, this.creatorType, this.groupName, this.description);
  @override
  // TODO: implement props
  List<Object> get props => [creatorId, creatorType, groupName, description];

}

class AddGroupMembersEvent extends ChatEvents{
  final String groupId;
  final List<String> membersId;
  const AddGroupMembersEvent(this.groupId, this.membersId);
  @override
  // TODO: implement props
  List<Object> get props => [groupId, membersId];

}

class SelectMemberEvent extends ChatEvents{
  final String memberId;
  final Contact membersContact;
  const SelectMemberEvent(this.memberId, this.membersContact);
  @override
  // TODO: implement props
  List<Object> get props => [memberId, membersContact];

}

class DeSelectMemberEvent extends ChatEvents{
  final String memberId;
  final Contact membersContact;
  const DeSelectMemberEvent(this.memberId, this.membersContact);
  @override
  // TODO: implement props
  List<Object> get props => [memberId, membersContact];

}

class SendChatMessageEvent extends ChatEvents{
  final String message;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String groupId;
  final String chatType;
  const SendChatMessageEvent(this.message, this.senderId, this.senderType, this.receiverId, this.receiverType, this.groupId, this.chatType);
  @override
  // TODO: implement props
  List<Object> get props => [message, senderId, senderType, receiverId, receiverType, groupId, chatType];

}

class UpdateChatReadMessagesEvent extends ChatEvents{
  final String apiToken;
  final String senderId;
  final String chatId;
  final String chatType;
  const UpdateChatReadMessagesEvent(this.apiToken, this.senderId, this.chatId, this.chatType);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, senderId, chatId, chatType];

}

class RenderEmojiEvent extends ChatEvents{
  final bool show;
  const RenderEmojiEvent(this.show);
  @override
  // TODO: implement props
  List<Object> get props => [show];

}

class LoadImagesEvent extends ChatEvents{
  final List<Asset> images;
  const LoadImagesEvent(this.images);
  @override
  // TODO: implement props
  List<Object> get props => [images];

}