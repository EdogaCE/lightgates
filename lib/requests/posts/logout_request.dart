import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class LogoutRepository {
  Future<String> logSchoolOut({String platform});
  Future<String> logTeacherOut({String platform});
  Future<String> logStudentOut({String platform});
}

class LogoutRequests implements LogoutRepository{
  @override
  Future<String> logSchoolOut({String platform}) async{
    // TODO: implement logSchoolOut
    String rtnData;
    try {
      print(MyStrings.domain + MyStrings.schoolLogoutUrl+await getApiToken()+'/$platform');
      await http.post(MyStrings.domain + MyStrings.schoolLogoutUrl+await getApiToken()+'/$platform', body: {
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
  Future<String> logTeacherOut({String platform})async{
    // TODO: implement logTeacherOut
    String rtnData;
    try {
      print(MyStrings.domain + MyStrings.teacherLogOutUrl + await getApiToken()+'/$platform');
      await http.post(MyStrings.domain + MyStrings.teacherLogOutUrl + await getApiToken()+'/$platform', body: {
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
    } on SocketException{
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

  @override
  Future<String> logStudentOut({String platform})async{
    // TODO: implement logStudentOut
    String rtnData;
    try {
      print(MyStrings.domain + MyStrings.studentLogOutUrl + await getApiToken()+'/$platform');
      await http.post(MyStrings.domain + MyStrings.studentLogOutUrl + await getApiToken()+'/$platform', body: {
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
    } on SocketException{
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }
}