import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/class_labels.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewClassLabelsRepository {
  Future<List<ClassLabels>> fetchClassLabels(String apiToken);
}

class ViewClassLabelsRequest implements ViewClassLabelsRepository {
  List<ClassLabels> _classLabels = new List();
  @override
  Future<List<ClassLabels>> fetchClassLabels(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewClassLabelsUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _classLabels.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Class Label available, Please do well to add some");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _classLabels;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _classLabels.add(new ClassLabels(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          label: result[i]["label"].toString(),
          date:
          "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}",
          status: result[i]["status"].toString()));
    }
  }
}
