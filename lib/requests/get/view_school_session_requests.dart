import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSchoolSessionRepository {
  Future<List<Sessions>> fetchSchoolSession(String apiToken);
  Future<List<Sessions>> activateSchoolSession(String id);
}

class ViewSchoolSessionRequest implements ViewSchoolSessionRepository {
  List<Sessions> _sessions = new List();
  @override
  Future<List<Sessions>> fetchSchoolSession(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewSchoolSessionsUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _sessions.clear();
      if (map["return_data"]['session_details'].length < 1) {
        throw ApiException(
            "No Session available, Please do well to add Some");
      }
      _populateLists(map["return_data"]['session_details']);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _sessions;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _sessions.add(new Sessions(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          sessionDate: result[i]["session_date"].toString(),
          startAndEndDate:
          "${result[i]["session_start_date"].toString()},${result[i]["session_end_date"].toString()}",
          status: result[i]["status"].toString(),
          admissionNumberPrefix: result[i]["admission_no_prefix"].toString()));
    }
  }

  @override
  Future<List<Sessions>> activateSchoolSession(String id) async{
    // TODO: implement activateSchoolSession
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.activateSchoolSessionsUrl + await getApiToken()+"/"+id);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _sessions.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Session available, Please do well to add Some");
      }
      _populateLists(map["return_data"]['session_details']);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _sessions;
  }
}
