import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewClassesRepository{
  Future<List<Classes>> fetchClasses(String apiToken);
}

class ViewClassesRequest implements ViewClassesRepository{
  List<Classes> _classes=new List();
  @override
  Future<List<Classes>> fetchClasses(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewClassesUrl+apiToken);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _classes.clear();
      Map result=map["return_data"];
      if (result["all_class_with_details"].length<1) {
        throw ApiException("No Class data available, Please do well to add Some");
      }
      _populateLists(result);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _classes;
  }

  void _populateLists(Map result){

    Map<String, String> levelInWord={'100':'First Level', '200':'Second Level', '300':'Third Level',
      '400':'Fourth Level', '500':'Fifth Level', '600':'Sixth Level', '700':'Seventh Level',
      '800':'Eight Level', '900':'Ninth Level'};

    for(int i=0; i<result["all_class_with_details"].length; i++ ){
      _classes.add(new Classes(id: result["all_class_with_details"][i]["class_details_array"]["id"],
        uniqueId: result["all_class_with_details"][i]["class_details_array"]["unique_id"],
        label: result["all_class_with_details"][i]["class_label_details"]["label"],
        level: levelInWord[result["all_class_with_details"][i]["class_level_details"]["level"]]??'Unknown level',
        category: result["all_class_with_details"][i]["class_category_details"]["category"],
        numberOfStudents: result["students_count"][i].toString(),
        numberOfTeachers: result["teacher_count"][i].toString(),
        date: "${result["all_class_with_details"][i]["class_details_array"]["created_at"]}, ${result["all_class_with_details"][i]["class_details_array"]["created_at"]}",
        status: result["all_class_with_details"][i]["class_details_array"]["status"],));
    }
  }

}