import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/grade.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSchoolGradesRepository {
  Future<List<Grade>> fetchSchoolGrade(String apiToken);
}

class ViewSchoolGradeRequest implements ViewSchoolGradesRepository {
  List<Grade> _grades = new List();
  @override
  Future<List<Grade>> fetchSchoolGrade(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain + MyStrings.viewSchoolGradesUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _grades.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Grade available, Please do well to add Some");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _grades;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _grades.add(Grade(
        id: result[i]['id'].toString(),
        uniqueId: result[i]['unique_id'].toString(),
        grade: result[i]['grade'].toString(),
        startLimit: result[i]['start_limit'].toString(),
        endLimit: result[i]['end_limit'].toString(),
        remark: result[i]['remark'].toString(),
        deleted: result[i]['is_deleted'].toString()!='no',
      ));
    }
  }

}
