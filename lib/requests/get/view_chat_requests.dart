import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/models/message.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewChatRepository{
  Future<List<Contact>> fetchChatContacts({String apiToken, String senderId, String senderType, bool localDb});
  Future<List<Group>> fetchChatGroups({String apiToken, String senderId, bool localDb});
  Future<List<Chat>> fetchChats({String apiToken, String senderId, bool localDb});
  Future<List<Chat>> fetchChatMessages({String apiToken, String senderId, String senderType, String receiverId, String receiverType, String groupId, String chatType, bool localDb});
  Future<String> updateChatReadMessages({String apiToken, String senderId, String chatId, String chatType});
}

class ViewChatRequest implements ViewChatRepository{
  List<Contact> _contacts=new List();
  List<Group> _groups=new List();
  List<Chat> _chats=new List();
  @override
  Future<List<Contact>> fetchChatContacts({String apiToken, String senderId, String senderType, bool localDb}) async{
    // TODO: implement fetchChatContacts
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'chatContacts');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.viewChatContactsUrl+'$apiToken/$senderId/$senderType');
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _contacts.clear();
        List contacts=map["return_data"]['chat_contacts'];
        if (contacts.length<1) {
          throw ApiException("No Contacts available");
        }

        if(await databaseHandlerRepository.getData(title: 'chatContacts')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'chatContacts', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'chatContacts', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateContactLists(map["return_data"]['chat_contacts']);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
      throw SystemError();
    }

    return _contacts;
  }

  void _populateContactLists(List contacts){
    for(int i=0; i<contacts.length; i++ ){
      _contacts.add(Contact(id: contacts[i]['id'].toString(),
          uniqueId: contacts[i]['unique_id'].toString(),
          schoolId: contacts[i]['school_id'].toString(),
          userName: contacts[i]['full_name'].toString(),
          userUniqueId: contacts[i]['user_unique_id'].toString(),
          userType: contacts[i]['the_type_of_user'].toString(),
          admissionNumber: contacts[i]['admission_number'].toString(),
          classDetails: contacts[i]['class_details'].toString(),
          emailAddress: contacts[i]['email_address'].toString(),
          phone: contacts[i]['phone'].toString(),
          status: contacts[i]['status'].toString(),
          passport: contacts[i]['image'].toString(),
          passportLink: contacts[i]['image_link'].toString(),
          date: contacts[i]['updated_at'].toString(),
          deleted: contacts[i]['is_deleted'].toString()=='yes'
      ));
    }
  }

  @override
  Future<List<Group>> fetchChatGroups({String apiToken, String senderId, bool localDb}) async{
    // TODO: implement fetchChatGroups
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'chatGroups');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.viewChatGroupsUrl+'$apiToken/$senderId');
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _groups.clear();
        List groups=map["return_data"];
        if (groups.length<1) {
          throw ApiException("No Groups available");
        }

        if(await databaseHandlerRepository.getData(title: 'chatGroups')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'chatGroups', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'chatGroups', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateGroupLists(map["return_data"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
      throw SystemError();
    }

    return _groups;
  }

  void _populateGroupLists(List groups){
    for(int i=0; i<groups.length; i++ ){
      List<Contact> members=List();
      int index=0;
      for(var member in groups[i]['each_member_details']){
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
          userType:  groups[i]['type_of_member_array'][index].toString(),
          passport:  member['image'].toString(),
          passportLink:  member['image_link'].toString(),
          status:  member['status'].toString(),
          date: member['updated_at'].toString(),
          deleted:  member['is_deleted'].toString()=='yes'
        ));
        index++;
      }
      _groups.add(Group(
        id: groups[i]['id'].toString(),
        uniqueId: groups[i]['unique_id'].toString(),
        schoolId: groups[i]['school_id'].toString(),
        name: groups[i]['group_name'].toString(),
        description: groups[i]['description'].toString(),
        creatorId: groups[i]['creator'].toString(),
        creatorType: groups[i]['creator_type'].toString(),
        memberIds: groups[i]['members'].toString(),
        image: groups[i]['image'].toString(),
        imageLink: groups[i]['passport_link'].toString(),
        members: members,
        date: groups[i]['updated_at'].toString(),
        deleted: groups[i]['is_deleted'].toString()=='yes',
      ));
    }
  }

  @override
  Future<List<Chat>> fetchChats({String apiToken, String senderId, bool localDb}) async{
    // TODO: implement fetchChas
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;

      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'chats');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.viewChatsUrl+'$apiToken/$senderId');
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _chats.clear();
        List chats=map["return_data"];
        if (chats.length<1) {
          throw ApiException("No Chats available");
        }

        if(await databaseHandlerRepository.getData(title: 'chats')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'chats', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'chats', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateChatsLists(map["return_data"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
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

  @override
  Future<List<Chat>> fetchChatMessages({String apiToken, String senderId, String senderType, String receiverId, String receiverType, String groupId, String chatType, bool localDb}) async{
    // TODO: implement fetchChatMessages
    //print(MyStrings.domain+MyStrings.viewChatMessagesUrl+'$apiToken/$senderId/$senderType/$receiverId/$receiverType/$groupId/$chatType');
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'chatMessages$senderId$receiverId$groupId');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.viewChatMessagesUrl+'$apiToken/$senderId/$senderType/$receiverId/$receiverType/$groupId/$chatType');
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _chats.clear();
        List chats=map["return_data"];
        if (chats.length<1) {
          throw ApiException("No Chats available");
        }

        if(await databaseHandlerRepository.getData(title: 'chatMessages$senderId$receiverId$groupId')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'chatMessages$senderId$receiverId$groupId', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'chatMessages$senderId$receiverId$groupId', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateChatsLists(map["return_data"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
      throw SystemError();
    }

    return _chats;
  }

  @override
  Future<String> updateChatReadMessages({String apiToken, String senderId, String chatId, String chatType}) async{
    // TODO: implement updateChatReadMessages
    print(MyStrings.domain+MyStrings.updateChatReadMessagesUrl+'$apiToken/$senderId/$chatId/$chatType');

    String _message;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.updateChatReadMessagesUrl+'$apiToken/$senderId/$chatId/$chatType');
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _message=map['success_message'].toString();


    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
      throw SystemError();
    }

    return _message;
  }

}