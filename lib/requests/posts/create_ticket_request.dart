import 'package:meta/meta.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class CreateTicketRepository {
  Future<String> createTicket({@required String title, @required String categoryId, @required String message});
  Future<String> createComment({@required String senderId, @required String ticketId, @required String comment});
}

class CreateTicketRequests implements CreateTicketRepository{
  @override
  Future<String> createTicket({String title, String categoryId, String message}) async {
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.createTicketUrl+ await getApiToken(), body: {
        "title": title,
        "ticket_category_id": categoryId,
        "message": message
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message=map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> createComment({String senderId, String ticketId, String comment}) async{
    // TODO: implement createComment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.createTicketCommentUrl+ await getApiToken(), body: {
        "sender_id": senderId,
        "ticket_id": ticketId,
        "comment": comment
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message=map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }
}


