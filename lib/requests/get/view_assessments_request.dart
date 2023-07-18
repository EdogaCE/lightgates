import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewAssessmentsRepository{
  Future<List<Assessments>> fetchAssessments(String apiToken);
}

class ViewAssessmentsRequest implements ViewAssessmentsRepository{
  List<Assessments> _assessments=new List();
  @override
  Future<List<Assessments>> fetchAssessments(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewAssessmentsUrl+apiToken);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _assessments.clear();
      Map result=map["return_data"];
      if (result["assessment_details_array"].length<1) {
        throw ApiException("No Assessment data available");
      }
      _populateLists(result);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _assessments;
  }

  void _populateLists(Map result){
    for(int i=0; i<result["assessment_details_array"].length; i++ ){
      _assessments.add(new Assessments(id: result["assessment_details_array"][i]["id"].toString(),
          uniqueId: result["assessment_details_array"][i]["unique_id"].toString(),
          teacherId: result["teacher_details_array"][i]["id"].toString(),
          type:result["assessment_details_array"][i]["type"].toString(),
          title:result["assessment_details_array"][i]["title_area"].toString(),
          content:result["assessment_details_array"][i]["content"].toString(),
          file:result["assessment_details_array"][i]["file_name"].toString(),
          submissionMode:result["assessment_details_array"][i]["submission_mode"].toString(),
          noOfSubmission:result["assessment_details_array"][i]["no_of_submissions"].toString(),
          termId: result["assessment_details_array"][i]["term_id"].toString(),
          sessionId: result["assessment_details_array"][i]["session_id"].toString(),
          classesId: result["assessment_details_array"][i]["class_id"].toString(),
          subjectId: result["assessment_details_array"][i]["subject_id"].toString(),
          date:'${result['assessment_details_array'][i]["date_added"]} => ${result["assessment_details_array"][i]["submission_date"]}',
          instructions: result["assessment_details_array"][i]["instructions"].toString(),
          term:result["term_details_array"][i]["term"].toString(),
          termStatus:result["term_details_array"][i]["status"].toString(),
          session:result["session_details_array"][i]["session_date"].toString(),
          sessionMode:result["session_details_array"][i]["status"].toString(),
          classDetail:'${result["all_class_details_array"][i]["class_label_details"]["label"]} ${result["all_class_details_array"][i]["class_category_details"]["category"]}',
          subjectDetail:result["subject_details_array"][i]["title"].toString(),
          teacherDetail:'${result["teacher_details_array"][i]["lastname"]??''}  ${result["teacher_details_array"][i]["firstname"]??''} ${result["teacher_details_array"][i]["othernames"]??''}',
          fileUrl: result['base_url_assessment_image'].toString()
      ));
    }
  }

}