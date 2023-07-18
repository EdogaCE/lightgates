import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/class_levels.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewClassLevelsRepository {
  Future<List<ClassLevels>> fetchClassLevels(String apiToken);
}

class ViewClassLevelsRequest implements ViewClassLevelsRepository {
  List<ClassLevels> _classLevels = new List();
  @override
  Future<List<ClassLevels>> fetchClassLevels(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewClassLevelsUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _classLevels.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Class Level available, Please do well to add Some");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _classLevels;
  }

  void _populateLists(List result) {
    Map<String, String> levelInWord={'100':'First Level', '200':'Second Level', '300':'Third Level',
      '400':'Fourth Level', '500':'Fifth Level', '600':'Sixth Level', '700':'Seventh Level',
      '800':'Eight Level', '900':'Ninth Level'};

    for (int i = 0; i < result.length; i++) {
      _classLevels.add(new ClassLevels(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          level: levelInWord[result[i]["level"].toString()]??'Unknown level',
          date:
          "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}",
          status: result[i]["status"].toString()));
    }
  }
}
