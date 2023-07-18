import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditClassCategoryRepository {
  Future<String> addClassCategory({String category});
  Future<String> editClassCategory({String category, String id});
  Future<String> deleteClassCategory({String id});
}

class AddEditClassCategoryRequests implements AddEditClassCategoryRepository{
  @override
  Future<String> addClassCategory({String category}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.addClassCategoriesUrl+await getApiToken(), body: {
        "category": category
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
  Future<String> editClassCategory({String category, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.editClassCategoriesUrl+await getApiToken()+"/"+id, body: {
        "category": category
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
  Future<String> deleteClassCategory({String id}) async{
    // TODO: implement deleteClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteClassCategoriesUrl+await getApiToken()+"/"+id, body: {
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

