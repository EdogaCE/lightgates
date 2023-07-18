import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSubjectsRepository{
  Future<List<Subjects>> fetchSubjects(String apiToken);
  Future<String> deleteSubject(String subjectId);
}

class ViewSubjectsRequest implements ViewSubjectsRepository{
  List<Subjects> _subjects=new List();
  @override
  Future<List<Subjects>> fetchSubjects(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewSubjectsUrl+apiToken);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _subjects.clear();
      if (map["return_data"].length<1) {
        throw ApiException("No subject available, Please do well to add Some");
      }
      _populateLists(map["return_data"]);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _subjects;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _subjects.add(new Subjects(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          title: result[i]["title"].toString(),
          date:
          "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}"));
    }
  }

  @override
  Future<String> deleteSubject(String subjectId) async{
    // TODO: implement deleteSubject
    String rtnData;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.deleteSubjectUrl+await getApiToken()+'/'+subjectId);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      rtnData=map['success_message'];
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

}