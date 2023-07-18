import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/notifications.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:meta/meta.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewNotificationsRepository {
  Future<List<Notifications>> fetchNotifications({@required String apiToken, @required String receiverType, @required bool localDb});
  Future<Notifications> fetchNotification({@required String apiToken, @required String notificationId, @required String receiverType});
}

class ViewNotificationsRequest implements ViewNotificationsRepository {
  List<Notifications> _notifications = new List();
  @override
  Future<List<Notifications>> fetchNotifications({String apiToken, String receiverType, bool localDb}) async {
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'notifications');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        print(MyStrings.domain + MyStrings.viewNotificationsUrl + '$apiToken/$receiverType');
        final response = await http
            .get(MyStrings.domain + MyStrings.viewNotificationsUrl + '$apiToken/$receiverType');
        map = json.decode(response.body);
        print(map);

        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _notifications.clear();
        if (map["return_data"].isEmpty) {
          throw ApiException(
              "No Notifications Yet");
        }

        if(await databaseHandlerRepository.getData(title: 'notifications')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'notifications', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'notifications', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateLists(map["return_data"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _notifications;
  }

  void _populateLists(Map map) {
    for (int i = 0; i < map["notification_details"].length; i++) {
      _notifications.add(Notifications(
        id: map["notification_details"][i]['id'].toString(),
        uniqueId: map["notification_details"][i]['unique_id'].toString(),
        title: map["notification_details"][i]['title_'].toString(),
        description: map["notification_details"][i]['notification_details_array']['description'].toString(),
        link: map["notification_details"][i]['link'].toString(),
        notificationType: map["notification_details"][i]['notification_type'].toString(),
        typeOfReceiver: map["notification_details"][i]['notification_details_array']['type_of_reciever'].toString(),
        read: map["notification_details"][i]['read_receipt']!=null,
        deleted: map["notification_details"][i]['is_deleted'].toString()=='yes'
      ));
    }
  }

  @override
  Future<Notifications> fetchNotification({String apiToken, String notificationId, String receiverType}) async{
    // TODO: implement fetchNotification
    String _id, _uniqueId, _title, _description, _link, _notificationType, _typeOfReceiver;
    bool _read, _deleted;
    try {
      print(MyStrings.domain+MyStrings.viewNotificationUrl+'$apiToken/$receiverType/$notificationId');
      final response = await http.get(MyStrings.domain+MyStrings.viewNotificationUrl+'$apiToken/$receiverType/$notificationId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      List details = map['return_data']['notification_details'];
      _id=details[0]['id'].toString();
      _uniqueId=details[0]['unique_id'].toString();
      _title=details[0]['title_'].toString();
      _description=details[0]['notification_details_array']['description'].toString();
      _link=details[0]['link'].toString();
      _notificationType=details[0]['notification_type'].toString();
      _typeOfReceiver=details[0]['notification_details_array']['type_of_reciever'].toString();
      _read=details[0]['read_receipt']!=null;
      _deleted=details[0]['is_deleted'].toString()=='yes';

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return Notifications(
        id: _id,
        uniqueId: _uniqueId,
        title: _title,
        description: _description,
        link: _link,
        notificationType: _notificationType,
        typeOfReceiver: _typeOfReceiver,
        read: _read,
        deleted: _deleted
    );
  }
}
