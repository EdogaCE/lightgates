import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class LearningMaterialRepository {
  Future<String> addLearningMaterial({@required String classId, @required List<String> fileName, @required String description, @required List<String> video, @required String title, @required String teacherId, @required String subjectId});
  Future<String> updateLearningMaterial({@required String materialId, @required String classId, @required List<String> fileName, @required String description, @required List<String> video, @required String title, @required String teacherId, @required String subjectId, @required List<String> filesToDelete});
  Future<String> addLearningMaterialFile({@required String materialId, @required String fileField, @required String fileType});
}

class  LearningMaterialRequests implements  LearningMaterialRepository{
  @override
  Future<String> addLearningMaterialFile({String materialId, String fileField, String fileType}) async {
    // TODO: implement addGalleryImage
    String _filename;
    try {
      await http.post((materialId.isEmpty)
          ?MyStrings.domain + MyStrings.addLearningMaterialsUrl+ await getApiToken()
          :MyStrings.domain + MyStrings.updateLearningMaterialsUrl+ await getApiToken()+'/$materialId', body: {
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
  Future<String> addLearningMaterial({String classId, List<String> fileName, String description, List<String> video, String title, String teacherId, String subjectId}) async{
    // TODO: implement addLearningMaterial
    String _message;
    print(fileName.join(','));
    try {
      await http.post(MyStrings.domain + MyStrings.addLearningMaterialsUrl+ await getApiToken(), body: {
        "class_id": classId,
        "file_name[]": '',
        'mobile_upload_file_name[]': fileName.join(','),
        "description": description,
        "video[]": video.join(','),
        "title_": title,
        "teacher_id": teacherId,
        "subject_id": subjectId
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
  Future<String> updateLearningMaterial({String materialId, String classId, List<String> fileName, String description, List<String> video, String title, String teacherId, String subjectId, List<String> filesToDelete}) async{
    // TODO: implement updateLearningMaterial
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateLearningMaterialsUrl+ await getApiToken()+'/$materialId', body: {
        "class_id": classId,
        "mobile_upload_file_name[]": fileName.join(','),
        "description": description,
        "video[]": video.join(','),
        "title_": title,
        "teacher_id": teacherId,
        "subject_id": subjectId,
        'files_to_delete':filesToDelete.join(',')
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


