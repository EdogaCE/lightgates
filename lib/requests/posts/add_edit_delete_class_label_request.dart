import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditClassLabelRepository {
  Future<String> addClassLabel({String label});
  Future<String> editClassLabel({String label, String id});
  Future<String> deleteClassLabel({String id});
}
class AddEditClassLabelRequests implements AddEditClassLabelRepository{
  @override
  Future<String> addClassLabel({String label}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.addClassLabelUrl+await getApiToken(), body: {
        "label": label
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        rtnData=map['success_message'].toString();
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

  @override
  Future<String> editClassLabel({String label, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.editClassLabelUrl+await getApiToken()+"/"+id, body: {
        "label": label
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        rtnData=map['success_message'].toString();
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

  @override
  Future<String> deleteClassLabel({String id}) async{
    // TODO: implement deleteClassLabel
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteClassLabelUrl+await getApiToken()+"/"+id, body: {
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        rtnData=map['success_message'].toString();
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

}

