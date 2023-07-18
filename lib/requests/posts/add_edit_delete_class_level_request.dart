import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditClassLevelRepository {
  Future<String> addClassLevel({String level});
  Future<String> editClassLevel({String level, String id});
  Future<String> deleteClassLevel({String id});
}

class AddEditClassLevelRequests implements AddEditClassLevelRepository{
  @override
  Future<String> addClassLevel({String level}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.addClassLevelUrl+await getApiToken(), body: {
        "level": level
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
  Future<String> editClassLevel({String level, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.editClassLevelUrl+await getApiToken()+"/"+id, body: {
        "level": level
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
  Future<String> deleteClassLevel({String id}) async{
    // TODO: implement deleteClassLevel
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteClassLevelUrl+await getApiToken()+"/"+id, body: {
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

