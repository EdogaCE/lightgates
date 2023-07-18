import 'package:meta/meta.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/models/message.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ChatRepository {
  Future<Group> createGroup({@required String creatorId, @required String creatorType, @required String groupName, @required String description});
  Future<String> addGroupMembers({@required String groupId, @required List<String> memberIds});
  Future<String> sendFirebaseToken({@required String androidToken, @required String iosToken});
  Future<List<Chat>> sendMessage({String message, String senderId, String senderType, String receiverId, String receiverType, String groupId, String chatType});
}

class ChatRequests implements ChatRepository{
  List<Chat> _chats=new List();
  @override
  Future<Group> createGroup({String creatorId, String creatorType, String groupName, String description}) async{
    // TODO: implement createGroup
    Group _group;
    try {
      await http.post(
          MyStrings.domain + MyStrings.createGroupUrl + await getApiToken(),
          body: {
            "creator_id": creatorId,
            "creator_type": creatorType,
            "group_name": groupName,
            "description": description,
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        List<Contact> members=List();
        int index=0;
        for(var member in map['return_data'][0]['each_member_details']){
          members.add(Contact(
              id: member['id'].toString(),
              uniqueId:  member['unique_id'].toString(),
              schoolId:  member['school_id'].toString(),
              userName:  member['full_name'].toString(),
              admissionNumber:  member['admission_number'].toString(),
              classDetails:  member['class_details'].toString(),
              emailAddress:  member['email_address'].toString(),
              phone:  member['phone'].toString(),
              userUniqueId:  member['user_unique_id'].toString(),
              userType:  map['return_data'][0]['type_of_member_array'][index].toString(),
              passport:  member['image'].toString(),
              passportLink:  member['image_link'].toString(),
              status:  member['status'].toString(),
              date: member['updated_at'].toString(),
              deleted:  member['is_deleted'].toString()=='yes'
          ));
          index++;
        }
        _group=Group(
          id: map['return_data'][0]['id'].toString(),
          uniqueId: map['return_data'][0]['unique_id'].toString(),
          schoolId: map['return_data'][0]['school_id'].toString(),
          name: map['return_data'][0]['group_name'].toString(),
          description: map['return_data'][0]['description'].toString(),
          creatorId: map['return_data'][0]['creator'].toString(),
          creatorType: map['return_data'][0]['creator_type'].toString(),
          memberIds: map['return_data'][0]['members'].toString(),
          image: map['return_data'][0]['image'].toString(),
          imageLink: map['return_data'][0]['passport_link'].toString(),
          members: members,
          date: map['return_data'][0]['updated_at'].toString(),
          deleted: map['return_data'][0]['is_deleted'].toString()=='yes',
        );

      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _group;
  }

  @override
  Future<String> addGroupMembers({String groupId, List<String> memberIds}) async{
    // TODO: implement addGroupMembers
    print(MyStrings.domain + MyStrings.addGroupMembersUrl + await getApiToken()+'/$groupId');
    print(memberIds);
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.addGroupMembersUrl + await getApiToken()+'/$groupId',
          body: {
            "user_ids[]": memberIds.join(',')
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _message = map['return_data'].toString();
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> sendFirebaseToken({String androidToken, String iosToken}) async{
    // TODO: implement sendFirebaseToken
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.sendFirebaseTokenUrl + await getApiToken(),
          body: {
            "andriod_fcm_key": androidToken,
            "ios_fcm_key": iosToken,
            "web_fcm_key": ''
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _message = map['return_data'].toString();
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<List<Chat>> sendMessage({String message, String senderId, String senderType, String receiverId, String receiverType, String groupId, String chatType}) async{
    // TODO: implement sendMessage
    print('message: $message, sender_id: $senderId sender_type: $senderType, reciever_id:$receiverId, reciever_type: $receiverType, group_id: $groupId, chat_type:$chatType');
    try {
      await http.post(
          MyStrings.domain + MyStrings.sendChatMessageUrl + await getApiToken(),
          body: {
            "message": message,
            "sender_id": senderId,
            "sender_type": senderType,
            "reciever_id": receiverId,
            "reciever_type": receiverType,
            "group_id": groupId,
            "chat_type": chatType
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'success') {
          throw ApiException(
              handelServerError(response: map));
        }

        _chats.clear();
        List chats=map["chat_details"]["data"]["chat_details_array"];
        if (chats.length<1) {
          throw ApiException("No Chats available in Our Server");
        }
        _populateChatsLists(chats);

      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _chats;
  }

  void _populateChatsLists(List chats){
    for(int i=chats.length-1; i>=0; i--){

      Contact sender,receiver;
      Group receivers;
      Message lastMessage;

      try{
        lastMessage=Message(
          id: chats[i]['last_message']['id'].toString(),
          uniqueId: chats[i]['last_message']['unique_id'].toString(),
          schoolId: chats[i]['last_message']['school_id'].toString(),
          message: chats[i]['last_message']['message'].toString(),
          mainMessageId: chats[i]['last_message']['main_message_id'].toString(),
          messageType: chats[i]['last_message']['message_type'].toString(),
          fileName: chats[i]['last_message']['file_names'].toString(),
          fileLink: chats[i]['last_message']['file_names'].toString(),
          senderId: chats[i]['last_message']['sender'].toString(),
          senderType: chats[i]['last_message']['the_sender_type_of_user'].toString(),
          receiverId: chats[i]['last_message']['reciever'].toString(),
          receiverType: chats[i]['last_message']['the_reciever_type_of_user'].toString(),
          chatType: chats[i]['last_message']['type_of_chat'].toString(),
          groupId: chats[i]['last_message']['group_id'].toString(),
          read: chats[i]['last_message']['read'].toString(),
          date: chats[i]['last_message']['updated_at'].toString(),
          deleted: chats[i]['last_message']['is_deleted'].toString()=='yes',
        );
      }on NoSuchMethodError{}

      if(chats[i]['type_of_chat'].toString()=='private'){
        sender=Contact(
            id: chats[i]['sender_details']['id'].toString(),
            uniqueId:  chats[i]['sender_details']['unique_id'].toString(),
            schoolId:  chats[i]['sender_details']['school_id'].toString(),
            userName:  chats[i]['sender_details']['full_name'].toString(),
            admissionNumber:  chats[i]['sender_details']['admission_number'].toString(),
            classDetails:  chats[i]['sender_details']['class_details'].toString(),
            emailAddress:  chats[i]['sender_details']['email_address'].toString(),
            phone:  chats[i]['sender_details']['phone'].toString(),
            userUniqueId:  chats[i]['sender_details']['user_unique_id'].toString(),
            userType:  chats[i]['sender_details']['user_unique_id'].toString(),
            passport:  chats[i]['sender_details']['image'].toString(),
            passportLink:  chats[i]['sender_details']['image_link'].toString(),
            status:  chats[i]['sender_details']['status'].toString(),
            date: chats[i]['sender_details']['updated_at'].toString(),
            deleted:  chats[i]['sender_details']['is_deleted'].toString()=='yes'
        );
        receiver=Contact(
            id: chats[i]['reciever_details']['id'].toString(),
            uniqueId:  chats[i]['reciever_details']['unique_id'].toString(),
            schoolId:  chats[i]['reciever_details']['school_id'].toString(),
            userName:  chats[i]['reciever_details']['full_name'].toString(),
            admissionNumber:  chats[i]['reciever_details']['admission_number'].toString(),
            classDetails:  chats[i]['reciever_details']['class_details'].toString(),
            emailAddress:  chats[i]['reciever_details']['email_address'].toString(),
            phone:  chats[i]['reciever_details']['phone'].toString(),
            userUniqueId:  chats[i]['reciever_details']['user_unique_id'].toString(),
            userType:  chats[i]['reciever_details']['user_unique_id'].toString(),
            passport:  chats[i]['reciever_details']['image'].toString(),
            passportLink:  chats[i]['reciever_details']['image_link'].toString(),
            status:  chats[i]['reciever_details']['status'].toString(),
            date: chats[i]['reciever_details']['updated_at'].toString(),
            deleted:  chats[i]['reciever_details']['is_deleted'].toString()=='yes'
        );
      }else if(chats[i]['type_of_chat'].toString()=='group'){
        List<Contact> members=List();
        int index=0;
        for(var member in chats[i]['details_of_group_members']){
          members.add(Contact(
              id: member['id'].toString(),
              uniqueId:  member['unique_id'].toString(),
              schoolId:  member['school_id'].toString(),
              userName:  member['full_name'].toString(),
              admissionNumber:  member['admission_number'].toString(),
              classDetails:  member['class_details'].toString(),
              emailAddress:  member['email_address'].toString(),
              phone:  member['phone'].toString(),
              userUniqueId:  member['user_unique_id'].toString(),
              userType:  chats[i]['group_member_types'][index].toString(),
              passport:  member['image'].toString(),
              passportLink:  member['image_link'].toString(),
              status:  member['status'].toString(),
              date: member['updated_at'].toString(),
              deleted:  member['is_deleted'].toString()=='yes'
          ));
          index++;
        }
        receivers=Group(
          id: chats[i]['group_details']['id'].toString(),
          uniqueId: chats[i]['group_details']['unique_id'].toString(),
          schoolId: chats[i]['group_details']['school_id'].toString(),
          name: chats[i]['group_details']['group_name'].toString(),
          description: chats[i]['group_details']['description'].toString(),
          creatorId: chats[i]['group_details']['creator'].toString(),
          creatorType: chats[i]['group_details']['creator_type'].toString(),
          memberIds: chats[i]['group_details']['members'].toString(),
          image: chats[i]['group_details']['image'].toString(),
          imageLink: chats[i]['group_details']['passport_link'].toString(),
          members: members,
          date: chats[i]['group_details']['updated_at'].toString(),
          deleted: chats[i]['group_details']['is_deleted'].toString()=='yes',
        );
      }


      _chats.add(Chat(
          message: Message(
            id: chats[i]['id'].toString(),
            uniqueId: chats[i]['unique_id'].toString(),
            schoolId: chats[i]['school_id'].toString(),
            message: chats[i]['message'].toString(),
            mainMessageId: chats[i]['main_message_id'].toString(),
            messageType: chats[i]['message_type'].toString(),
            fileName: chats[i]['file_names'].toString(),
            fileLink: chats[i]['file_names'].toString(),
            senderId: chats[i]['sender'].toString(),
            senderType: chats[i]['the_sender_type_of_user'].toString(),
            receiverId: chats[i]['reciever'].toString(),
            receiverType: chats[i]['the_reciever_type_of_user'].toString(),
            chatType: chats[i]['type_of_chat'].toString(),
            groupId: chats[i]['group_id'].toString(),
            read: chats[i]['read'].toString(),
            date: chats[i]['updated_at'].toString(),
            deleted: chats[i]['is_deleted'].toString()=='yes',
          ),
          lastMessage: lastMessage,
          readReceiptCount: chats[i]['read_receipt_count'].toString(),
          sender: sender,
          receiver: receiver,
          receivers: receivers
      ));
    }
  }

}