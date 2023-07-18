import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditSessionRepository {
  Future<List<Sessions>> addSession({String sessionDate, String sessionStartDate, String sessionEndDate, String admissionNumberPrefix});
  Future<String> editSession({String sessionDate, String sessionStartDate, String sessionEndDate, String admissionNumberPrefix, String id});
}
class AddEditSessionRequests implements AddEditSessionRepository {
  List<Sessions> _sessions = new List();
  @override
  Future<List<Sessions>> addSession({String sessionDate, String sessionStartDate, String sessionEndDate, String admissionNumberPrefix}) async{
    // TODO: implement addClassCategory
    try {
      await http.post(MyStrings.domain + MyStrings.addSchoolSessionsUrl+await getApiToken(), body: {
        "session_date": sessionDate,
        "session_start_date": sessionStartDate,
        "session_end_date": sessionEndDate,
        "admission_no_prefix": admissionNumberPrefix
      }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _sessions.clear();
        _populateLists(map['return_data']);

      });
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
  Future<String> editSession({String sessionDate, String sessionStartDate, String sessionEndDate, String admissionNumberPrefix, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.updateSchoolSessionsUrl+await getApiToken()+"/"+id, body: {
        "session_date": sessionDate,
        "session_start_date": sessionStartDate,
        "session_end_date": sessionEndDate,
        "admission_no_prefix": admissionNumberPrefix
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        rtnData=map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }
}

