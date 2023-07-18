import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditClassRepository {
  Future<String> addClass({String classLevelId, String classCategoryId, String classLabelId});
  Future<String> editClass({String classLevelId, String classCategoryId, String classLabelId, String classId});
  Future<String> deleteClass({String classId});
}

class AddEditClassRequests implements AddEditClassRepository{
  @override
  Future<String> addClass({String classLevelId, String classCategoryId, String classLabelId}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.addClassUrl+await getApiToken(), body: {
        "class_level_id": classLevelId,
        "class_category_id": classCategoryId,
        "class_label_id": classLabelId
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
  Future<String> editClass({String classLevelId, String classCategoryId, String classLabelId, String classId}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.editClassUrl+await getApiToken()+"/"+classId, body: {
        "class_level_id": classLevelId,
        "class_category_id": classCategoryId,
        "class_label_id": classLabelId
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
  Future<String> deleteClass({String classId}) async{
    // TODO: implement deleteClass
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteClassUrl+await getApiToken()+"/"+classId, body: {
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

