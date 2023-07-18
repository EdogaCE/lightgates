import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/class_categories.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewClassCategoriesRepository {
  Future<List<ClassCategory>> fetchClassCategories(String apiToken);
}

class ViewClassCategoriesRequest implements ViewClassCategoriesRepository {
  List<ClassCategory> _classCategories = new List();
  @override
  Future<List<ClassCategory>> fetchClassCategories(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewClassCategoriesUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _classCategories.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Class Category available, Please do well to add Some");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _classCategories;
  }

  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _classCategories.add(new ClassCategory(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          category: result[i]["category"].toString(),
          date:
              "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}",
          status: result[i]["status"].toString()));
    }
  }
}
