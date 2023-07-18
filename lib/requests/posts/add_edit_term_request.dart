import 'package:school_pal/models/terms.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditTermRepository {
  Future<List<Terms>> addTerm({String term});
  Future<String> editTerm({String term, String id});
  Future<List<Terms>> activateTerm({String termId, String sessionId, String startDate, String endDate});
  Future<List<Terms>> rearrangeTerm({List<String> termId});
}

class AddEditTermRequests implements AddEditTermRepository {
  List<Terms> _terms = new List();
  @override
  Future<List<Terms>> addTerm({String term}) async{
    // TODO: implement addClassCategory
    try {
      await http.post(MyStrings.domain + MyStrings.addSchoolTermUrl+await getApiToken(), body: {
        "term": term
      }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _terms.clear();
        _populateLists(map["return_data"]);

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _terms;
  }

  @override
  Future<String> editTerm({String term, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.updateSchoolTermUrl+await getApiToken()+"/"+id, body: {
        "term": term
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

  @override
  Future<List<Terms>> activateTerm({String termId, String sessionId, String startDate, String endDate}) async{
    // TODO: implement addClassCategory
    try {
      await http.post(MyStrings.domain + MyStrings.activateSchoolTermUrl+await getApiToken()+"/"+termId, body: {
        "term_id": termId,
        "session_i": sessionId,
        "start_date": startDate,
        "end_date": endDate
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _terms.clear();
        _populateLists(map["return_data"]['term_details']);

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _terms;
  }

  @override
  Future<List<Terms>> rearrangeTerm({List<String> termId}) async{
    // TODO: implement rearrangeTerm
    print(termId.join(','));
    try {
      await http.post(MyStrings.domain + MyStrings.rearrangeSchoolTermUrl+await getApiToken(), body: {
        "term_id[]": termId.join(',')
      }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _terms.clear();
        _populateLists(map["return_data"]['term_details']);

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _terms;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _terms.add(new Terms(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          term: result[i]["term"].toString(),
          date:
          "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}",
          status: result[i]["status"].toString()));
    }
  }

}