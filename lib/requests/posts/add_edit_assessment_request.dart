import 'package:meta/meta.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class AssessmentRepository {
  Future<String> addAssessment({@required String termId, @required String sessionId, @required String classId, @required String subjectId, @required String teacherId, @required String title, @required String type, @required String submissionMode, @required String instructions, @required List<String> files,@required String content, @required String submissionDate});
  Future<String> updateAssessment({@required String assessmentId, @required String termId, @required String sessionId, @required String classId, @required String subjectId, @required String teacherId, @required String title, @required String type, @required String submissionMode, @required String instructions, @required List<String> files,@required String content, @required String submissionDate, @required List<String> filesToDelete});
  Future<String> addAssessmentFile({@required String assessmentId, @required String fileField, @required String fileType });
}

class  AssessmentRequests implements  AssessmentRepository{
  @override
  Future<String> addAssessmentFile({String assessmentId, String fileField, String fileType}) async {
    // TODO: implement addGalleryImage
    String _filename;
    try {
      await http.post((assessmentId.isEmpty)
          ?MyStrings.domain + MyStrings.addSchoolGalleryUrl+ await getApiToken()
          :MyStrings.domain + MyStrings.updateAssessmentsUrl+ await getApiToken()+'/$assessmentId', body: {
        "mobile_upload": '',
        "file_field[]": fileField,
        "file_type": fileType
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _filename=map['return_data'][0];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _filename;
  }

  @override
  Future<String> addAssessment({String termId, String sessionId, String classId, String subjectId, String teacherId, String title, String type, String submissionMode, String instructions, List<String> files, String content, String submissionDate}) async {
    // TODO: implement addAssessment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addAssessmentsUrl+ await getApiToken(), body: {
        "selected_term": termId,
        "selected_session": sessionId,
        "class_id": classId,
        "title_area": title,
        "subject_id": subjectId,
        "teacher_id": teacherId,
        "submission_mode": submissionMode,
        "instructions": instructions,
        "type": type,
        "mobile_upload_file_name[]": files.join(','),
        "content": content,
        "submission_date": submissionDate
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message=map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> updateAssessment({String assessmentId, String termId, String sessionId, String classId, String subjectId, String teacherId, String title, String type, String submissionMode, String instructions, List<String> files, String content, String submissionDate, List<String> filesToDelete}) async{
    // TODO: implement updateAssessment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateAssessmentsUrl+ await getApiToken()+'/$assessmentId', body: {
        "selected_term": termId,
        "selected_session": sessionId,
        "class_id": classId,
        "title_area": title,
        "subject_id": subjectId,
        "teacher_id": teacherId,
        "submission_mode": submissionMode,
        "instructions": instructions,
        "type": type,
        "mobile_upload_file_name[]": files.join(','),
        "content": content,
        "submission_date": submissionDate,
        'files_to_delete[]':filesToDelete.join(',')
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message=map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }
}


