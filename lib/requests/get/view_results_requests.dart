import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/class_results.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/grade.dart';
import 'package:school_pal/models/result_comments.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/student_result.dart';
import 'package:school_pal/models/subject_results.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewResultsRepository{
  Future<List<ClassResults>> fetchClassResults(String sessionId, String termId, String classId, String type);
  Future<SubjectResult> fetchSubjectResult(String resultId, String subjectId, String sessionId, String termId, String classId, String type);
  Future<StudentResult> fetchStudentResults({String studentId, String sessionId, String termId, String classId, String type});
  Future<StudentResult> fetchStudentCumulativeResults({String studentId, String sessionId, String classId, String type});
  Future<List<List<String>>> fetchStudentsAttendanceInterface({String teacherId, String classId, String termId, String sessionId});
  Future<List<List<String>>> fetchStudentsBehaviouralSkillsInterface({String teacherId, String classId, String termId, String sessionId});
  Future<List<ResultComments>> fetchTeacherComments({String classId, String termId, String sessionId});
  Future<List<ResultComments>> fetchPrincipalComments({String termId, String sessionId});
}

class ViewResultsRequest implements ViewResultsRepository{
  List<ClassResults> _classResults=new List();
  @override
  Future<List<ClassResults>> fetchClassResults(String sessionId, String termId, String classId, String type) async {
    try {
        final response = await http.get((type=='pending')
            ?MyStrings.domain+MyStrings.viewPendingClassResultUrl+await getApiToken()+'/$sessionId/$termId/$classId'
            :MyStrings.domain+MyStrings.viewConfirmedClassResultUrl+await getApiToken()+'/$sessionId/$termId/$classId/confirmed');

      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }


      _classResults.clear();
      Map result=map["return_data"];
      if (result["main_result_details"].length<1) {
        throw ApiException("No Result data available, Please do well to add Some");
      }
      _populateClassResultLists(result);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _classResults;
  }

  void _populateClassResultLists(Map result){
    for(int i=0; i<result["main_result_details"].length; i++ ){
      _classResults.add(new ClassResults(
        id: result['main_result_details'][i]['id'].toString(),
        uniqueId:  result['main_result_details'][i]['unique_id'].toString(),
        confirmationStatus:  result['main_result_details'][i]['confirmation_status'].toString(),
        fileName:  result['main_result_details'][i]['file_name'].toString(),
        reasonForDecline:  result['main_result_details'][i]['reason_for_decline'].toString(),
        classes: Classes(id: result["main_result_details"][i]["class_details"]["id"].toString(),
          uniqueId: result["main_result_details"][i]["class_details"]["unique_id"].toString(),
          label: result["main_result_details"][i]["class_label"]["label"].toString(),
          level: result["main_result_details"][i]["class_level"]["level"].toString(),
          category: result["main_result_details"][i]["class_category"]["category"].toString()),
        sessions: Sessions(
            id: result["main_result_details"][i]['session']["id"].toString(),
            uniqueId: result["main_result_details"][i]['session']["unique_id"].toString(),
            sessionDate: result["main_result_details"][i]['session']["session_date"].toString(),
            status: result["main_result_details"][i]['session']["status"].toString(),
            admissionNumberPrefix: result["main_result_details"][i]['session']["admission_no_prefix"].toString()),
        terms: Terms(
            id: result["main_result_details"][i]['term']["id"].toString(),
            uniqueId: result["main_result_details"][i]['term']["unique_id"].toString(),
            term: result["main_result_details"][i]['term']["term"].toString(),
            status: result["main_result_details"][i]['term']["status"].toString()),
        subjects: Subjects(
            id: result["main_result_details"][i]['selected_subject']["id"].toString(),
            uniqueId: result["main_result_details"][i]['selected_subject']["unique_id"].toString(),
            title: result["main_result_details"][i]['selected_subject']["title"].toString()),
        teachers: Teachers(
            id:result["main_result_details"][i]['teacher']["id"].toString(),
            uniqueId:result["main_result_details"][i]['teacher']["unique_id"].toString(),
            role:result["main_result_details"][i]['teacher']["role"].toString(),
            fName:result["main_result_details"][i]['teacher']["firstname"].toString(),
            mName:result["main_result_details"][i]['teacher']["othernames"].toString(),
            lName:result["main_result_details"][i]['teacher']["lastname"].toString(),
            gender:result["main_result_details"][i]['teacher']["sex"].toString(),
            phone:result["main_result_details"][i]['teacher']["phone"].toString(),
            email:result["main_result_details"][i]['teacher']["email"].toString(),
            passport:result["main_result_details"][i]['teacher']["passport"].toString(),
            address:result["main_result_details"][i]['teacher']["contact_address"].toString(),
            city:result["main_result_details"][i]['teacher']["city"].toString(),
            state:result["main_result_details"][i]['teacher']["state"].toString(),
            nationality:result["main_result_details"][i]['teacher']["country"].toString(),
            salary:result["main_result_details"][i]['teacher']["salary"].toString(),
            dob:result["main_result_details"][i]['teacher']["birthday"].toString(),
            employmentStatus:
           result["main_result_details"][i]['teacher']["employment_status"].toString())

      ));
    }
  }

  @override
  Future<SubjectResult> fetchSubjectResult(String resultId, String subjectId, String sessionId, String termId, String classId, String type) async{
    // TODO: implement fetchSubjectResult
    SubjectResult _subjectResults;
    try {
        final response = await http.get((type=='pending')
            ?MyStrings.domain+MyStrings.viewPendingSubjectResultUrl+await getApiToken()+'/$subjectId/$classId/$sessionId/$termId'
            :MyStrings.domain+MyStrings.viewConfirmedSubjectResultUrl+await getApiToken()+'/$subjectId/$classId/$resultId/$sessionId/$termId');

      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

    Map result=map["return_data"];
    if (result.length<1) {
    throw ApiException("No Result data available, Please do well to add Some");
    }
      if(type=='pending'){
        _subjectResults=_populatePendingSubjectResultLists(result);
      }else{
        _subjectResults=_populateConfirmedSubjectResultLists(result);
      }


    } on SocketException {
    throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _subjectResults;
  }

  SubjectResult _populatePendingSubjectResultLists(Map result){
    List<List<String>> resultDetail=List();
    List<Grade> _grade=new List();
    for(int i=0; i<result["result_details"].length; i++ ){
      List<String> results=List();
      for(int j=0; j<result["result_details"][i].length; j++ ){
        results.add(result["result_details"][i][j].toString());
      }
      resultDetail.add(results);
    }

    for(int i=0; i<result["grade_details_array"]["grades_unique_id"].length; i++ ){
      _grade.add(Grade(
        uniqueId: result["grade_details_array"]["grades_unique_id"][i],
        startLimit: result["grade_details_array"]["start_limit"][i],
        endLimit: result["grade_details_array"]["end_limit"][i],
        grade: result["grade_details_array"]["grades"][i],
        remark: result["grade_details_array"]["remark"][i]
      ));
    }

    return SubjectResult(
      resultDetail: resultDetail,
      grade: _grade,
      classResults: ClassResults(
          id: result['single_result_details']['id'].toString(),
          uniqueId:  result['single_result_details']['unique_id'].toString(),
          confirmationStatus:  result['single_result_details']['confirmation_status'].toString(),
          fileName:  result['single_result_details']['file_name'].toString(),
          reasonForDecline:  result['single_result_details']['reason_for_decline'].toString(),
          classes: Classes(id: result["class_details"]["class_details_array"]["id"].toString(),
              uniqueId: result["class_details"]["class_details_array"]["unique_id"].toString(),
              label: result["class_details"]["class_label_details"]["label"].toString(),
              level: result["class_details"]["class_level_details"]["level"].toString(),
              category: result["class_details"]["class_category_details"]["category"].toString()),
          sessions: Sessions(
              id: result['session_details']["id"].toString(),
              uniqueId: result['session_details']["unique_id"].toString(),
              sessionDate: result['session_details']["session_date"].toString(),
              status: result['session_details']["status"].toString(),
              admissionNumberPrefix: result['session_details']["admission_no_prefix"].toString()),
          terms: Terms(
              id: result['term_details']["id"].toString(),
              uniqueId: result['term_details']["unique_id"].toString(),
              term: result['term_details']["term"].toString(),
              status: result['term_details']["status"].toString()),
          subjects: Subjects(
              id: result['subject_details']["id"].toString(),
              uniqueId: result['subject_details']["unique_id"].toString(),
              title: result['subject_details']["title"].toString()),
          teachers: Teachers(
              id:result['teacher_details']["id"].toString(),
              uniqueId:result['teacher_details']["unique_id"].toString(),
              role:result['teacher_details']["role"].toString(),
              fName:result['teacher_details']["firstname"].toString(),
              mName:result['teacher_details']["othernames"].toString(),
              lName:result['teacher_details']["lastname"].toString(),
              gender:result['teacher_details']["sex"].toString(),
              phone:result['teacher_details']["phone"].toString(),
              email:result['teacher_details']["email"].toString(),
              passport:result['teacher_details']["passport"].toString(),
              address:result['teacher_details']["contact_address"].toString(),
              city:result['teacher_details']["city"].toString(),
              state:result['teacher_details']["state"].toString(),
              nationality:result['teacher_details']["country"].toString(),
              salary:result['teacher_details']["salary"].toString(),
              dob:result['teacher_details']["birthday"].toString(),
              employmentStatus:
              result['teacher_details']["employment_status"].toString())

      )
    );
  }

  SubjectResult _populateConfirmedSubjectResultLists(Map result){
    List<List<String>> resultDetail=List();
    for(int i=0; i<result["detailed_result_list"].length; i++ ){
      List<String> results=List();
      for(int j=0; j<result["detailed_result_list"][i].length; j++ ){
        results.add(result["detailed_result_list"][i][j].toString());
      }
      resultDetail.add(results);
    }

    return SubjectResult(
        resultDetail: resultDetail,
        classResults: ClassResults(
            id: result['result_array'][0]['id'].toString(),
            uniqueId:  result['result_array'][0]['unique_id'].toString(),
            confirmationStatus:  result['result_array'][0]['confirmation_status'].toString(),
            fileName:  result['result_array'][0]['file_name'].toString(),
            reasonForDecline:  result['result_array'][0]['reason_for_decline'].toString(),
            classes: Classes(id: result['result_array'][0]["class_id"].toString(),
                uniqueId: result['result_array'][0]["class_id"].toString(),
                label: result['result_array'][0]["class_label"]["label"].toString(),
                level: result['result_array'][0]["class_level"]["level"].toString(),
                category: result['result_array'][0]["class_category"]["category"].toString()),
            sessions: Sessions(
                id: result['result_array'][0]['session']["id"].toString(),
                uniqueId: result['result_array'][0]['session']["unique_id"].toString(),
                sessionDate: result['result_array'][0]['session']["session_date"].toString(),
                status: result['result_array'][0]['session']["status"].toString(),
                admissionNumberPrefix: result['result_array'][0]['session']["admission_no_prefix"].toString()),
            terms: Terms(
                id: result['result_array'][0]['term']["id"].toString(),
                uniqueId: result['result_array'][0]['term']["unique_id"].toString(),
                term: result['result_array'][0]['term']["term"].toString(),
                status: result['result_array'][0]['term']["status"].toString()),
            subjects: Subjects(
                id: result['result_array'][0]['selected_subject']["id"].toString(),
                uniqueId: result['result_array'][0]['selected_subject']["unique_id"].toString(),
                title: result['result_array'][0]['selected_subject']["title"].toString()),
            teachers: Teachers(
                id:result['result_array'][0]['teacher']["id"].toString(),
                uniqueId:result['result_array'][0]['teacher']["unique_id"].toString(),
                role:result['result_array'][0]['teacher']["role"].toString(),
                fName:result['result_array'][0]['teacher']["firstname"].toString(),
                mName:result['result_array'][0]['teacher']["othernames"].toString(),
                lName:result['result_array'][0]['teacher']["lastname"].toString(),
                gender:result['result_array'][0]['teacher']["sex"].toString(),
                phone:result['result_array'][0]['teacher']["phone"].toString(),
                email:result['result_array'][0]['teacher']["email"].toString(),
                passport:result['result_array'][0]['teacher']["passport"].toString(),
                address:result['result_array'][0]['teacher']["contact_address"].toString(),
                city:result['result_array'][0]['teacher']["city"].toString(),
                state:result['result_array'][0]['teacher']["state"].toString(),
                nationality:result['result_array'][0]['teacher']["country"].toString(),
                salary:result['result_array'][0]['teacher']["salary"].toString(),
                dob:result['result_array'][0]['teacher']["birthday"].toString(),
                employmentStatus:
                result['result_array'][0]['teacher']["employment_status"].toString())

        )
    );
  }

  @override
  Future<StudentResult> fetchStudentResults({String studentId, String sessionId, String termId, String classId, String type})async{
    // TODO: implement fetchStudentResults
    String _fileName, _downloadLink;
    try {
      final response = await http.get("${MyStrings.domain}${MyStrings.viewStudentResultUrl}${await getApiToken()}/$studentId/$classId/$termId/$sessionId/$type");
      logPrint('Response body: ${response.body}');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map resultDetails = map['return_data'];
      _fileName = resultDetails['file_name'].toString();
      _downloadLink = resultDetails['download_link'].toString();

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return StudentResult(
        fileName: _fileName,
        downloadLink: _downloadLink
    );
  }

  @override
  Future<StudentResult> fetchStudentCumulativeResults({String studentId, String sessionId, String classId, String type}) async{
    // TODO: implement fetchStudentCumulativeResults
    print(MyStrings.domain + MyStrings.viewStudentCumulativeResultUrl + await getApiToken()+'/$studentId/$classId/$sessionId/$type');
    String _fileName, _downloadLink;
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewStudentCumulativeResultUrl + await getApiToken()+'/$studentId/$classId/$sessionId/$type');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map resultDetails = map['return_data'];
      _fileName = resultDetails['file_name'].toString();
      _downloadLink = resultDetails['download_link'].toString();

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return StudentResult(
        fileName: _fileName,
        downloadLink: _downloadLink
    );
  }

  @override
  Future<List<List<String>>> fetchStudentsAttendanceInterface({String teacherId, String classId, String termId, String sessionId}) async{
    // TODO: implement fetchStudentsAttendanceInterface
    List<List<String>> _attendanceInterface=List();
    try {
      final response = await http.get(MyStrings.domain + MyStrings.viewStudentsAttendanceInterfaceUrl + await getApiToken()+'/$teacherId/$classId/$termId/$sessionId');
      Map map = json.decode(response.body);
      logPrint('Rtn: $map');

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _attendanceInterface.clear();
      if (map["return_data"]['student_attendance_details'].length < 1) {
        throw ApiException(
            "No Student available");
      }

      /// Attendance header
      List<String> _attendance=List();
      for(var interface in map["return_data"]['student_attendance_header']){
        _attendance.add(interface.toString());
      }
      _attendanceInterface.add(_attendance);

      /// Attendance details
      for (int i = 0; i < map["return_data"]['student_attendance_details'].length; i++) {
        List<String> _attendance=List();
        for(var interface in map["return_data"]['student_attendance_details'][i]){
          _attendance.add(interface.toString());
        }
        _attendanceInterface.add(_attendance);
      }

    } on SocketException{
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _attendanceInterface;
  }

  @override
  Future<List<List<String>>> fetchStudentsBehaviouralSkillsInterface({String teacherId, String classId, String termId, String sessionId}) async{
    // TODO: implement fetchStudentsBehaviouralSkillsInterface
    List<List<String>> _behaviouralSkillsInterface=List();
    try {
      final response = await http.get(MyStrings.domain + MyStrings.viewStudentsBehaviouralSkillsInterfaceUrl + await getApiToken()+'/$teacherId/$classId/$termId/$sessionId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _behaviouralSkillsInterface.clear();
      if (map["return_data"]['behavioural_skills_details'].length < 1) {
        throw ApiException(
            "No Student available");
      }

      /// Attendance header
      List<String> _behaviouralSkills=List();
      for(var interface in map["return_data"]['behavioural_skills_headings']){
        _behaviouralSkills.add(interface.toString());
      }
      _behaviouralSkillsInterface.add(_behaviouralSkills);
      for (int i = 0; i < map["return_data"]['behavioural_skills_details'].length; i++) {
        List<String> _behaviouralSkills=List();
        for(var interface in map["return_data"]['behavioural_skills_details'][i]){
          _behaviouralSkills.add(interface.toString());
        }
        _behaviouralSkillsInterface.add(_behaviouralSkills);
      }

    } on SocketException{
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _behaviouralSkillsInterface;
  }

  @override
  Future<List<ResultComments>> fetchTeacherComments({String classId, String termId, String sessionId}) async{
    // TODO: implement fetchTeacherComments
    try {
      final response = await http.get(MyStrings.domain + MyStrings.viewTeacherCommentsUrl + await getApiToken()+'/$sessionId/$termId/$classId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _resultComments.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Comments available");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _resultComments;
  }

  @override
  Future<List<ResultComments>> fetchPrincipalComments({String termId, String sessionId}) async{
    // TODO: implement fetchPrincipalComments
    try {
      final response = await http.get(MyStrings.domain + MyStrings.viewPrincipalCommentsUrl + await getApiToken()+'/$sessionId/$termId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _resultComments.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Comments available");
      }
      _populateLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _resultComments;
  }
  List<ResultComments> _resultComments = new List();
  void _populateLists(List result) {
    for (int i = 0; i < result.length; i++) {
      Classes classes;
      try{
        classes=Classes(
          id: result[i]['class_details']['id'].toString(),
          uniqueId: result[i]['class_details']['unique_id'].toString(),
          label: result[i]['class_details']['class_label']['label'].toString(),
          category: result[i]['class_details']['class_category']['category'].toString(),
          level: result[i]['class_details']['class_level']['level'].toString(),
        );
      }on NoSuchMethodError{}
      _resultComments.add(ResultComments(
        id: result[i]['id'].toString(),
        uniqueId: result[i]['unique_id'].toString(),
        startLimit: result[i]['start_limit'].toString(),
        endLimit: result[i]['end_limit'].toString(),
        remark: result[i]['remark'].toString(),
        deleted: result[i]['is_deleted'].toString()=='yes',
        session: Sessions(
          id: result[i]['session_details']['id'].toString(),
          uniqueId: result[i]['session_details']['unique_id'].toString(),
          sessionDate: result[i]['session_details']['session_date'].toString(),
          startAndEndDate: '${result[i]['session_details']['session_start_date'].toString()}, ${result[i]['session_details']['session_end_date'].toString()}',
        ),
        term: Terms(
          id: result[i]['term_details']['id'].toString(),
          uniqueId: result[i]['term_details']['unique_id'].toString(),
          term: result[i]['term_details']['term'].toString(),
        ),
        classes: classes
      ));
    }
  }


}