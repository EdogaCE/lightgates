import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/events.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewEventsRepository {
  Future<List<Events>> fetchEvents(String apiToken);
  Future<String> deleteEvents(String id);
}

class ViewEventsRequest implements ViewEventsRepository {
  List<Events> _events = new List();
  @override
  Future<List<Events>> fetchEvents(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewSchoolEventsUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _events.clear();
      if (map["return_data"]['calender_details_array'].length < 1) {
        throw ApiException(
            "No event available, Please do well to add Some");
      }
      _populateLists(map["return_data"]['calender_details_array']);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _events;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _events.add(new Events(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          titleOfEvent: result[i]["title_of_event"].toString(),
          description: result[i]["description"].toString(),
          date:
          "${result[i]["start_date_of_event"].toString()},${result[i]["end_date_of_event"].toString()}",
          status: result[i]["delete_status"].toString()));
    }
  }

  @override
  Future<String> deleteEvents(String id) async {
    String _successMessage;
    // TODO: implement deleteEvents
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.deleteSchoolEventsUrl + await getApiToken()+"/"+id);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

     _successMessage=map['success_message'];
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }
}
