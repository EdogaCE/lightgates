import 'package:equatable/equatable.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class ChatStates extends Equatable{
  const ChatStates();
}

class ChatInitial extends ChatStates{
  const ChatInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends ChatStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends ChatStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ChatContactsLoaded extends ChatStates{
  final List<Contact> chatContacts;
  const ChatContactsLoaded(this.chatContacts);
  @override
  // TODO: implement props
  List<Object> get props => [chatContacts];
}

class ChatGroupsLoaded extends ChatStates{
  final List<Group> chatGroups;
  const ChatGroupsLoaded(this.chatGroups);
  @override
  // TODO: implement props
  List<Object> get props => [chatGroups];
}

class ChatsLoaded extends ChatStates{
  final List<Chat> chats;
  const ChatsLoaded(this.chats);
  @override
  // TODO: implement props
  List<Object> get props => [chats];
}

class ChatReadMessagesUpdated extends ChatStates{
  final String message;
  const ChatReadMessagesUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class GroupCreated extends ChatStates{
  final Group group;
  const GroupCreated(this.group);
  @override
  // TODO: implement props
  List<Object> get props => [group];
}

class GroupMembersAdded extends ChatStates{
  final String message;
  const GroupMembersAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class MemberSelected extends ChatStates{
  final String memberId;
  final Contact membersContact;
  const MemberSelected(this.memberId, this.membersContact);
  @override
  // TODO: implement props
  List<Object> get props => [memberId, membersContact];

}

class MemberDeSelected extends ChatStates{
  final String memberId;
  final Contact membersContact;
  const MemberDeSelected(this.memberId, this.membersContact);
  @override
  // TODO: implement props
  List<Object> get props => [memberId, membersContact];

}

class EmojiRendered extends ChatStates{
  final bool show;
  const EmojiRendered(this.show);
  @override
  // TODO: implement props
  List<Object> get props => [show];

}

class ImagesLoaded extends ChatStates{
  final List<Asset> images;
  const ImagesLoaded(this.images);
  @override
  // TODO: implement props
  List<Object> get props => [images];

}

class ViewError extends ChatStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends ChatStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}