import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSchoolTermRepository {
  Future<List<Terms>> fetchSchoolTerm(String apiToken);
}

class ViewSchoolTermRequest implements ViewSchoolTermRepository {
  List<Terms> _terms = new List();
  @override
  Future<List<Terms>> fetchSchoolTerm(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewSchoolTermUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _terms.clear();
      if (map["return_data"].isEmpty) {
        throw ApiException(
            "No Term available, Please do well to add Some");
      }
      _populateLists(map["return_data"]['term_details']);
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
