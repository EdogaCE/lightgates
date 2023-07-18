import 'package:meta/meta.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ResultRepository {
  Future<String> approveResult({@required String resultId, @required String sessionId, @required String termId, @required String classId, @required String subjectId, @required String teacherId, @required List<String> resultHeaders, @required Map results, @required List<String> studentUniqueIds, @required List<String> studentsResults});
  Future<String> declineResult({@required String resultId, @required String senderId, @required String sender, @required String comment});
  Future<String> addStudentsAttendance({@required String classId, @required String termId, @required String sessionId, @required List<String> attendanceHeader, @required List<String> studentsAttendances});
  Future<String> addBehaviouralSkills({@required String classId, @required String termId, @required String sessionId, @required List<String> behaviouralSkillsHeader, @required List<String> studentsBehaviouralSkills});
  Future<String> addTeacherComments({@required String classId, @required String termId, @required String sessionId, @required String remark, @required String startLimit, @required String endLimit});
  Future<String> addPrincipalComments({@required String termId, @required String sessionId, @required String remark, @required String startLimit, @required String endLimit});
  Future<String> updateTeacherComments({@required String commentId, @required String classId, @required String termId, @required String sessionId, @required String remark, @required String startLimit, @required String endLimit});
  Future<String> updatePrincipalComments({@required String commentId, @required String termId, @required String sessionId, @required String remark, @required String startLimit, @required String endLimit});
  Future<String> deleteTeacherComments({@required String commentId, @required String classId, @required String termId, @required String sessionId});
  Future<String> deletePrincipalComments({@required String commentId, @required String termId, @required String sessionId});
  Future<String> restoreTeacherComments({@required String commentId, @required String classId, @required String termId, @required String sessionId});
  Future<String> restorePrincipalComments({@required String commentId, @required String termId, @required String sessionId});
}

class ResultRequests implements ResultRepository{
  @override
  Future<String> approveResult({String resultId, String sessionId, String termId, String classId, String subjectId, String teacherId, List<String> resultHeaders, Map results, List<String> studentUniqueIds, List<String> studentsResults}) async{
    // TODO: implement approveResult
    print(studentUniqueIds.join(','));
    print(studentsResults.join(':'));
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.approveResultUrl+await getApiToken()+'/$resultId', body: {
        "session_i": sessionId,
        "term_id": termId,
        "class_id": classId,
        "subject_id": subjectId,
        "teacher_id": teacherId,
        "result_obj[]": results.toString(),
        "result_header[]": resultHeaders.join(','),
        'mobile_upload': '',
        'student_unique_ids': studentUniqueIds.join(','),
        'result_obj_mobile': studentsResults.join(':'),
        "result_header_mobile": resultHeaders.join(',')
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
      print(e.toString());
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> declineResult({String resultId, String senderId, String sender, String comment}) async {
    // TODO: implement declineResult
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.declineResultUrl+await getApiToken()+'/$resultId', body: {
        "reason_for_decline": comment,
        "sender_id": senderId,
        "sender": sender
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
  Future<String> addStudentsAttendance({String classId, String termId, String sessionId, List<String> attendanceHeader, List<String> studentsAttendances}) async{
    // TODO: implement addStudentsAttendance
    print(attendanceHeader.join(','));
    print(studentsAttendances.join(':'));
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addStudentsAttendanceUrl+await getApiToken(), body: {
        "session_i": sessionId,
        "term_id": termId,
        "class_id": classId,
        "attendance_header": attendanceHeader.join(','),
        "attendance_obj": studentsAttendances.join(':')
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
  Future<String> addBehaviouralSkills({String classId, String termId, String sessionId, List<String> behaviouralSkillsHeader, List<String> studentsBehaviouralSkills}) async{
    // TODO: implement addBehaviouralSkills
    print(behaviouralSkillsHeader.join(','));
    print(studentsBehaviouralSkills.join(':'));
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addStudentsBehaviouralSkillsUrl+await getApiToken(), body: {
        "session_i": sessionId,
        "term_id": termId,
        "class_id": classId,
        "behavioural_skills_header": behaviouralSkillsHeader.join(','),
        "behavioural_skills_score": studentsBehaviouralSkills.join(':'),
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
  Future<String> addTeacherComments({String classId, String termId, String sessionId, String remark, String startLimit, String endLimit}) async{
    // TODO: implement addTeacherComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addTeacherCommentsUrl+await getApiToken(), body: {
        "session_i": sessionId,
        "term_id": termId,
        "class_tb_id": classId,
        "remark[]": remark,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit
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
  Future<String> addPrincipalComments({String termId, String sessionId, String remark, String startLimit, String endLimit}) async{
    // TODO: implement addPrincipalComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addPrincipalCommentsUrl+await getApiToken(), body: {
        "session_i": sessionId,
        "term_id": termId,
        "remark[]": remark,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit
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
  Future<String> updateTeacherComments({String commentId, String classId, String termId, String sessionId, String remark, String startLimit, String endLimit}) async{
    // TODO: implement updateTeacherComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateTeacherCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId,
        "classTb_id": classId,
        "remark[]": remark,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit
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
  Future<String> updatePrincipalComments({String commentId, String termId, String sessionId, String remark, String startLimit, String endLimit}) async{
    // TODO: implement updatePrincipalComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updatePrincipalCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId,
        "remark[]": remark,
        "start_limit[]": startLimit,
        "end_limit[]": endLimit
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
  Future<String> deleteTeacherComments({String commentId, String classId, String termId, String sessionId}) async{
    // TODO: implement deleteTeacherComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteTeacherCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId,
        "class_tb_id": classId
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
  Future<String> deletePrincipalComments({String commentId, String termId, String sessionId}) async{
    // TODO: implement deletePrincipalComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.deletePrincipalCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId
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
  Future<String> restoreTeacherComments({String commentId, String classId, String termId, String sessionId}) async{
    // TODO: implement restoreTeacherComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.restoreTeacherCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId,
        "class_tb_id": classId
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
  Future<String> restorePrincipalComments({String commentId, String termId, String sessionId}) async{
    // TODO: implement restorePrincipalComments
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.restorePrincipalCommentsUrl+await getApiToken(), body: {
        "comment_id[]": commentId,
        "session_i": sessionId,
        "term_id": termId
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


