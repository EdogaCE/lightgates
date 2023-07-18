import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/learning_materials.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewLearningMaterialsRepository{
  Future<List<LearningMaterials>> fetchLearningMaterials(String apiToken);
}

class ViewLearningMaterialsRequest implements ViewLearningMaterialsRepository{
  List<LearningMaterials> _learningMaterials=new List();
  @override
  Future<List<LearningMaterials>> fetchLearningMaterials(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewLearningMaterialsUrl+apiToken);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _learningMaterials.clear();
      Map result=map["return_data"];
      if (result["all_learning_material_array"].length<1) {
        throw ApiException("No learning material available");
      }
      _populateLists(result);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _learningMaterials;
  }

  void _populateLists(Map result){
    for(int i=0; i<result["all_learning_material_array"].length; i++ ){
      _learningMaterials.add(new LearningMaterials(id: result["all_learning_material_array"][i]["id"].toString(),
          uniqueId: result["all_learning_material_array"][i]["unique_id"].toString(),
          teacherId: result["all_learning_material_array"][i]["teacher_id"].toString(),
          title:result["all_learning_material_array"][i]["title_"].toString(),
          description:result["all_learning_material_array"][i]["description"].toString(),
          file:result["all_learning_material_array"][i]["file"].toString(),
          video:result["all_learning_material_array"][i]["video"].toString(),
          subjectId: result["all_learning_material_array"][i]["subject_id"].toString(),
          classesId: result["all_learning_material_array"][i]["class_id"].toString(),
          date:'${result['all_learning_material_array'][i]["created_at"]} , ${result["all_learning_material_array"][i]["updated_at"]}',
          classDetail:(result["class_details_array"][i]['class_details_array'].isNotEmpty)?'${result["class_details_array"][i]["class_label_details"]["label"]} ${result["class_details_array"][i]["class_category_details"]["category"]}':'general',
          subjectDetail:(result["subject_details_array"][i].isNotEmpty)?result["subject_details_array"][i]["title"].toString():'general',
          teacherDetail:(result["teacher_details_array"][i].isNotEmpty)?'${result["teacher_details_array"][i]["lastname"]??''}  ${result["teacher_details_array"][i]["firstname"]??''} ${result["teacher_details_array"][i]["othernames"]??''}':'general',
          fileUrl: result['path_for_learning_materials'].toString(),
      ));
    }
  }

}