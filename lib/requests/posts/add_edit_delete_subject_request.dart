import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEditSubjectRepository {
  Future<String> addSubject({String title});
  Future<String> editSubject({String title, String id});
}

class AddEditSubjectRequests implements AddEditSubjectRepository {
  @override
  Future<String> addSubject({String title}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      print(MyStrings.domain + MyStrings.addSubjectUrl+await getApiToken());
      print(title);
      await http.post(MyStrings.domain + MyStrings.addSubjectUrl+await getApiToken(), body: {
        "title": title
      }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

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
  Future<String> editSubject({String title, String id}) async{
    // TODO: implement addClassCategory
    String rtnData;
    try {
      await http.post(MyStrings.domain + MyStrings.editSubjectUrl+await getApiToken()+"/"+id, body: {
        "title": title
      }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

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

