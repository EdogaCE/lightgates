import 'package:meta/meta.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class AddEditGradeRepository {
  Future<String> addGrade({@required String grade, @required String startLimit, @required String endLimit, @required String remark});
  Future<String> updateGrade({@required String gradeId, @required String grade, @required String startLimit, @required String endLimit, @required String remark});
  Future<String> deleteGrade({@required String gradeId});
  Future<String> restoreGrade({@required String gradeId});
}

class AddEditGradeRequests implements AddEditGradeRepository{
  @override
  Future<String> addGrade({String grade, String startLimit, String endLimit, String remark}) async {
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addSchoolGradesUrl+ await getApiToken(), body: {
        "grade[]": grade,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit,
        "remark[]": remark
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
  Future<String> updateGrade({String gradeId, String grade, String startLimit, String endLimit, String remark}) async{
    // TODO: implement createComment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateSchoolGradesUrl+ await getApiToken(), body: {
        "grade_id[]": gradeId,
        "grade[]": grade,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit,
        "remark[]": remark
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
  Future<String> deleteGrade({String gradeId}) async{
    // TODO: implement deleteGrade
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteSchoolGradesUrl+ await getApiToken(), body: {
        "grade_id[]": gradeId
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
  Future<String> restoreGrade({String gradeId}) async{
    // TODO: implement restoreGrade
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.restoreSchoolGradesUrl+ await getApiToken(), body: {
        "grade_id[]": gradeId
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


