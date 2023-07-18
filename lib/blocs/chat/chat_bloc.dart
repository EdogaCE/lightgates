import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/requests/get/view_chat_requests.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class ChatBloc extends Bloc<ChatEvents, ChatStates>{
  final ViewChatRepository viewChatRepository;
  final ChatRepository chatRepository;
  ChatBloc({this.viewChatRepository, this.chatRepository}) : super(ChatInitial());

  @override
  Stream<ChatStates> mapEventToState(ChatEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewChatContactsEvent){
      yield Loading();
      try{
        final contacts=await viewChatRepository.fetchChatContacts(apiToken: event.apiToken, senderId: event.userId, senderType: event.userType, localDb: event.localDb);
        yield ChatContactsLoaded(contacts);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewChatGroupsEvent){
      yield Loading();
      try{
        final groups=await viewChatRepository.fetchChatGroups(apiToken: event.apiToken, senderId: event.userId, localDb: event.localDb);
        yield ChatGroupsLoaded(groups);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewChatsEvent){
      yield Loading();
      try{
        final chats=await viewChatRepository.fetchChats(apiToken: event.apiToken, senderId: event.userId, localDb: event.localDb);
        yield ChatsLoaded(chats);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewChatMessagesEvent){
      yield Loading();
      try{
        final chats=await viewChatRepository.fetchChatMessages(apiToken: event.apiToken, senderId: event.senderId, senderType: event.senderType, receiverId: event.receiverId, receiverType: event.receiverType, groupId: event.groupId, chatType: event.chatType, localDb: event.localDb);
        yield ChatsLoaded(chats);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is CreateGroupEvent){
      yield Processing();
      try{
        final group=await chatRepository.createGroup(creatorId: event.creatorId, creatorType: event.creatorType, groupName: event.groupName, description: event.description);
        yield GroupCreated(group);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddGroupMembersEvent){
      yield Processing();
      try{
        final message=await chatRepository.addGroupMembers(groupId: event.groupId, memberIds: event.membersId);
        yield GroupMembersAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is SelectMemberEvent){
      yield MemberSelected(event.memberId, event.membersContact);
    }else if (event is DeSelectMemberEvent){
      yield MemberDeSelected(event.memberId, event.membersContact);
    }else if(event is SendChatMessageEvent){
      yield Processing();
      try{
        final chats=await chatRepository.sendMessage(message: event.message, senderId: event.senderId, senderType: event.senderType, receiverId: event.receiverId, receiverType: event.receiverType, groupId: event.groupId, chatType: event.chatType);
        yield ChatsLoaded(chats);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is RenderEmojiEvent){
      yield EmojiRendered(event.show);
    }else if(event is LoadImagesEvent){
      yield ImagesLoaded(event.images);
    }else if(event is UpdateChatReadMessagesEvent){
      yield Loading();
      try{
        final message=await viewChatRepository.updateChatReadMessages(apiToken: event.apiToken, senderId: event.senderId, chatId: event.chatId, chatType: event.chatType);
        yield ChatReadMessagesUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }

}