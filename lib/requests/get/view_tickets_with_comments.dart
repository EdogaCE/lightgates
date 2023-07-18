import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/ticket_comments.dart';
import 'package:school_pal/models/tickets.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewTicketsRepository {
  Future<List<Tickets>> fetchTicket(String apiToken);
  Future<List<List<String>>> fetchTicketCategories(String apiToken);
}

class ViewTicketsRequest implements ViewTicketsRepository {
  List<Tickets> _tickets = new List();
  @override
  Future<List<Tickets>> fetchTicket(String apiToken) async {
    // TODO: implement fetchTicket
    try {
      final response = await http.get(
          MyStrings.domain + MyStrings.viewTicketWithCommentUrl + apiToken);
      logPrint('Response body: ${response.body}');
      Map map = json.decode(response.body);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _tickets.clear();
      if (map["return_data"].isEmpty) {
        throw ApiException("No tickets yet");
      }
      _populateNewsLists(map["return_data"]);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.message);
      throw SystemError();
    }

    return _tickets;
  }

  void _populateNewsLists(List result) {
    for (int i = 0; i < result.length; i++) {
      List<TicketComments> comments = List();
      for (var comment in result[i]['ticket_comments']) {
        if (comment['ticket_id'] == result[i]["id"].toString()) {
          comments.add(TicketComments(
              id: comment['id'].toString(),
              uniqueId: comment['unique_id'].toString(),
              comment: comment['comment'].toString(),
              senderId: comment['sender_id'].toString()));
        }
      }
      _tickets.add(new Tickets(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          title: result[i]["title"].toString(),
          message: result[i]["message"].toString(),
          file: result[i]["file"].toString(),
          senderType: result[i]["sender_type"].toString(),
          senderId: result[i]["sender_id"].toString(),
          comments: comments));
    }
  }

  @override
  Future<List<List<String>>> fetchTicketCategories(String apiToken) async {
    // TODO: implement fetchTicketCategories
    List<String> _values=List();
    List<String> _ids=List();
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewTicketCategoriesUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _values.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Ticket Category available");
      }

      for (int i = 0; i < map["return_data"].length; i++) {
        _values.add(map["return_data"][i]["name"].toString());
        _ids.add(map["return_data"][i]["id"].toString());
      }

    } on SocketException{
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return [_values, _ids];
  }
}
