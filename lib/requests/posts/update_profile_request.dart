import 'package:flutter/material.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class UpdateProfileRepository {
  Future<String> updateSchoolProfile(
      {@required String schoolId,
        @required String name,
        @required String contactPhoneNumber,
        @required String address,
        @required String town,
        @required String lga,
        @required String city,
        @required String nationality,
        @required String slogan,
        @required String website,
        @required String facebook,
        @required String instagram,
        @required String twitter});

  Future<String> updateSchoolSettings(
      {@required String schoolId,
        @required String poBox,
        @required String preferredCurrencyId,
        @required String resultCommentSwitch,
        @required List<String> traits,
        @required List<String> ratings,
        @required String numOfTerm,
        @required String initialAdmissionNum,
        @required String numOfCumulativeTest,
        @required List<String> testExamScoreLimit,
        @required List<String> behaviouralSkillTestsHeadings,
        @required String useCumulativeResult,
        @required String useCustomAdmissionNum,
        @required String useClassCategoryStatus,
        @required String useOfSignatureOnResults});

  Future<School> uploadSchoolLogo({@required String schoolLogo64Bit});
  Future<String> changeSchoolPassword(
      {@required String oldPassword,
        @required String newPassword,
        @required String confirmPassword});
  Future<String> updateTeacherProfile(
      {@required String teacherId,
        @required String title,
        @required String firstName,
        @required String lastName,
        @required String otherNames,
        @required String gender,
        @required String phone,
        @required String contactAddress,
        @required String city,
        @required String state,
        @required String country,
        @required String birthday,
        @required String role,
        @required String salary,
        @required String preferredCurrencyId,
        @required String bankCode,
        @required String bankName,
        @required String bankAccountNumber});
  Future<Teachers> uploadTeacherImage({@required String teacherId, @required String teacherImage});
  Future<String> uploadTeacherSignatory({@required String teacherId, @required String teacherSignatory});
  Future<String> changeTeacherPassword(
      {@required String oldPassword,
        @required String newPassword,
        @required String confirmPassword});
  Future<Students> uploadStudentImage({@required String studentId, @required String studentImage});
  Future<String> changeStudentPassword(
      {@required String oldPassword,
        @required String newPassword,
        @required String confirmPassword});
  Future<String> updateStudentProfile(
      {@required String studentId,
        @required String firstName,
        @required String lastName,
        @required String otherNames,
        @required String gender,
        @required String email,
        @required String phone,
        @required String contactAddress,
        @required String city,
        @required String state,
        @required String country,
        @required String birthday,
        @required String bloodGroup,
        @required String genotype,
        @required String healthHistory,
        @required String preferredCurrencyId,
        @required String boardingStatus
      });
  Future<String> createStudentProfile(
      {@required String firstName,
        @required String lastName,
        @required String otherNames,
        @required String email,
        @required String admissionNUmber,
        @required String phone,
        @required String contactAddress,
        @required String state,
        @required String city,
        @required String gender,
        @required String country,
        @required String birthday,
        @required String bloodGroup,
        @required String genotype,
        @required String healthHistory,
        @required String boardingStatus,
        @required String classId,
        @required String sessionId,
        @required String parentFullName,
        @required String parentTitle,
        @required String parentEmail,
        @required String parentPhone,
        @required String parentAddress,
        @required String parentsOccupation,
      });
  Future<String> updateParentProfile(
      {@required String studentId,
        @required String parentId,
        @required String parentFullName,
        @required String parentTitle,
        @required String parentAddress,
        @required String parentsOccupation,
      });
  Future<Students> uploadParentImage({@required String studentId, @required String parentId, @required String parentImage});
  Future<String> createTeacherProfile(
      {@required String role,
        @required String title,
        @required String firstName,
        @required String lastName,
        @required String otherNames,
        @required String username,
        @required String password,
        @required String gender,
        @required String phone,
        @required String email,
        @required String contactAddress,
        @required String city,
        @required String state,
        @required String country,
        @required String salary,
        @required String birthday,
        @required String bankCode,
        @required String bankName,
        @required String bankAccountNumber,
        @required String passport
      });
  Future<String> addFormTeacher({@required String classId, @required String sessionId, @required String termId, @required String teacherId});
  Future<String> removeFormTeacher({@required String classId, @required String assignedId, @required String teacherId});
  Future<String> addTeacherClassSubject({@required String teacherId, @required String subjectId, @required String classId, @required String sessionId, @required String termId});
  Future<String> updateTeacherClassSubject({@required String assignmentId, @required String teacherId, @required String subjectId, @required String classId});
  Future<String> deleteTeacherClassSubject({@required String assignmentId});
  Future<String> deleteStudentProfile({@required String studentId});
}

class UpdateProfileRequest implements UpdateProfileRepository {
  @override
  Future<String> updateSchoolProfile(
      {String schoolId,
        String name,
        String email,
        String password,
        String contactPhoneNumber,
        String address,
        String town,
        String lga,
        String city,
        String nationality,
        String slogan,
        String website,
        String facebook,
        String instagram,
        String twitter}) async {
    // TODO: implement updateSchoolProfile
    String _successMessage;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateSchoolProfileUrl +
              await getApiToken() +
              '/' +
              schoolId,
          body: {
            "name": name,
            "contact_phone_number": contactPhoneNumber,
            "address": address,
            "town": town,
            "lga": lga,
            "state": city,
            "nationality": nationality,
            "slogan": slogan,
            'school_website':website,
            'facebook':facebook,
            'instagram':instagram,
            'twitter':twitter
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<School> uploadSchoolLogo({String schoolLogo64Bit}) async {
    // TODO: implement uploadSchoolLogo
    bool _deleted, _useCumulativeResult, _useCustomAdmissionNum, _useClassCategoryStatus, _useOfSignatureOnResults;
    String _id,
        _uniqueId,
         _username,
        _name,
        _email,
        _phone,
        _address,
        _town,
        _lga,
        _city,
        _nationality,
        _slogan,
        _status,
        _image,
        _cacFile,
        _otherFile,
        _poBox,
        _website,
        _facebook,
        _instagram,
        _twitter,
        _imageLink,
        _activeSession,
        _activeTerm,
        _preferredCurrencyId,
        _developerCharge,
        _resultCommentSwitch,
        _keyToTraitRating,
        _numOfTerm,
        _admissionNumPrefix,
        _initialAdmissionNum,
        _numOfCumulativeTest,
        _testExamScoreLimit,
        _behaviouralSkillTestsHeadings;
    Currency _currency;

    try {
      await http.post(
          MyStrings.domain +
              MyStrings.uploadSchoolLogoUrl +
              await getApiToken(),
          body: {"passport": schoolLogo64Bit}).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        Map schoolDetails = map['return_data']['school_details'][0];
        _id = schoolDetails['id'].toString().replaceAll('null', '').replaceAll('null', '');
        _uniqueId = schoolDetails['unique_id'].toString().replaceAll('null', '');
        _username=schoolDetails['username'].toString().replaceAll('null', '');
        _name = schoolDetails['name'].toString().replaceAll('null', '');
        _email = schoolDetails['contact_email'].toString().replaceAll('null', '');
        _phone = schoolDetails['contact_phone_number'].toString().replaceAll('null', '');
        _address = schoolDetails['address'].toString().replaceAll('null', '');
        _town = schoolDetails['town'].toString().replaceAll('null', '');
        _lga = schoolDetails['lga'].toString().replaceAll('null', '');
        _city = schoolDetails['state'].toString().replaceAll('null', '');
        _nationality = schoolDetails['nationality'].toString().replaceAll('null', '');
        _slogan = schoolDetails['slogan'].toString().replaceAll('null', '');
        _status = schoolDetails['verification_status'].toString().replaceAll('null', '');
        _image = schoolDetails['image'].toString().replaceAll('null', '');
        _cacFile = schoolDetails['cac_file'].toString().replaceAll('null', '');
        _otherFile = schoolDetails['otherfile'].toString().replaceAll('null', '');
        _poBox = schoolDetails['p_o_box'].toString().replaceAll('null', '');
        _website=schoolDetails['school_website'].toString().replaceAll('null', '');
        _facebook=schoolDetails['facebook'].toString().replaceAll('null', '');
        _instagram=schoolDetails['instagram'].toString().replaceAll('null', '');
        _twitter=schoolDetails['twitter'].toString().replaceAll('null', '');
        _imageLink = map['return_data']['school_logo_path'].toString().replaceAll('null', '');
        _activeSession = map['active_session']['session_date'].toString().replaceAll('null', '');
        _activeTerm = map['active_term']['term'].toString().replaceAll('null', '');
        _preferredCurrencyId=schoolDetails['prefered_currency'].toString().replaceAll('null', '');
        _developerCharge=schoolDetails['developer_charge'].toString().replaceAll('null', '');
        _resultCommentSwitch=schoolDetails['result_comment_switch'].toString().replaceAll('null', '');
        _keyToTraitRating=schoolDetails['key_to_trait_rating'].toString().replaceAll('null', '');
        _numOfTerm=schoolDetails['no_of_terms'].toString().replaceAll('null', '');
        _admissionNumPrefix=schoolDetails['admission_no_prefix'].toString().replaceAll('null', '');
        _initialAdmissionNum=schoolDetails['initial_admission_no'].toString().replaceAll('null', '');
        _numOfCumulativeTest=schoolDetails['no_of_cumulative_test'].toString().replaceAll('null', '');
        _testExamScoreLimit=schoolDetails['test_exam_score_limit'].toString().replaceAll('null', '');
        _behaviouralSkillTestsHeadings=schoolDetails['behavioural_skill_tests_headings'].toString().replaceAll('null', '');
        _useCustomAdmissionNum=schoolDetails['use_of_custom_admission_number'].toString().replaceAll('null', '')=='yes';
        _useCumulativeResult=schoolDetails['use_of_cummulative_result'].toString().replaceAll('null', '')=='yes';
        _useClassCategoryStatus=schoolDetails['class_category_status'].toString().replaceAll('null', '')=='yes';
        _useOfSignatureOnResults=schoolDetails['use_of_signature_on_results'].toString().replaceAll('null', '')=='yes';
        _deleted=schoolDetails['is_deleted'].toString().replaceAll('null', '')=='yes';
        _currency=Currency(
          id: schoolDetails['currency_rate']['id'].toString().replaceAll('null', ''),
          uniqueId: schoolDetails['currency_rate']['unique_id'].toString().replaceAll('null', ''),
          baseCurrency: schoolDetails['currency_rate']['base_currency'].toString().replaceAll('null', ''),
          secondCurrency: schoolDetails['currency_rate']['second_currency'].toString().replaceAll('null', ''),
          rateOfConversion: schoolDetails['currency_rate']['rate_of_conversion'].toString().replaceAll('null', ''),
          expression: schoolDetails['currency_rate']['expression'].toString().replaceAll('null', ''),
          currencyName: schoolDetails['currency_rate']['currency_name'].toString().replaceAll('null', ''),
          countryName: schoolDetails['currency_rate']['country_name'].toString().replaceAll('null', ''),
          countryAbr: schoolDetails['currency_rate']['country_abbr'].toString().replaceAll('null', ''),
          deleted: schoolDetails['currency_rate']['is_deleted'].toString().replaceAll('null', '')!='no',
        );
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return School(
        id: _id,
        uniqueId: _uniqueId,
        userName: _username,
        name: _name,
        email: _email,
        phone: _phone,
        address: _address,
        town: _town,
        lga: _lga,
        city: _city,
        nationality: _nationality,
        slogan: _slogan,
        status: _status,
        image: _image,
        cacFile: _cacFile,
        otherFile: _otherFile,
        poBox: _poBox,
        website: _website,
        facebook: _facebook,
        instagram: _instagram,
        twitter: _twitter,
        imageLink: _imageLink,
        activeSession: _activeSession,
        activeTerm: _activeTerm,
        preferredCurrencyId: _preferredCurrencyId,
        currency: _currency,
        developerCharge: _developerCharge,
        resultCommentSwitch: _resultCommentSwitch,
        keyToTraitRating: _keyToTraitRating,
        numOfTerm: _numOfTerm,
        numOfCumulativeTest: _numOfCumulativeTest,
        admissionNumPrefix: _admissionNumPrefix,
        initialAdmissionNum: _initialAdmissionNum,
        testExamScoreLimit: _testExamScoreLimit,
        behaviouralSkillTestsHeadings: _behaviouralSkillTestsHeadings,
        useCumulativeResult: _useCumulativeResult,
        useCustomAdmissionNum: _useCustomAdmissionNum,
        useClassCategoryStatus: _useClassCategoryStatus,
        useOfSignatureOnResults: _useOfSignatureOnResults,
        deleted: _deleted
    );
  }

  @override
  Future<String> changeSchoolPassword(
      {String oldPassword, String newPassword, String confirmPassword}) async {
    // TODO: implement changeSchoolPassword
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.changeSchoolPasswordUrl +
              await getApiToken(),
          body: {
            "current_password": oldPassword,
            "new_password": newPassword,
            "new_password_2": confirmPassword
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message = map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _message;
  }

  @override
  Future<Teachers> uploadTeacherImage({String teacherId, String teacherImage}) async {
    // TODO: implement uploadTeacherImage
    bool _isFormTeacher, _deleted;
    String _id,
        _uniqueId,
        _username,
        _role,
        _title,
        _fName,
        _mName,
        _lName,
        _gender,
        _phone,
        _email,
        _passport,
        _address,
        _city,
        _state,
        _nationality,
        _salary,
        _dob,
        _employmentStatus,
        _passportLink,
        _activeSession,
        _activeTerm,
        _preferredCurrency,
        _bankCode,
        _bankName,
        _bankAccountNumber,
        _signatoryArea,
        _signatoryAreaUrl;
    Currency _currency;
    List<String> _subjects=List();
    List<String> _classes=List();
    List<Subjects> _subjectsDetail=List();
    List<Classes> _classesDetail=List();
    List<Classes> _formClasses=List();
    List<Terms> _formTerms=List();
    List<Sessions> _formSessions=List();
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.uploadTeacherImageUrl +
              await getApiToken() +
              "/$teacherId",
          body: {"passport": teacherImage}).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        Map teacherDetails = map['return_data']['student_teacher'][0];
        _id = teacherDetails['id'].toString().replaceAll('null', '');
        _uniqueId = teacherDetails['unique_id'].toString().replaceAll('null', '');
        _username=teacherDetails['username'].toString().replaceAll('null', '');
        _role = teacherDetails['role'].toString().replaceAll('null', '');
        _title=teacherDetails['title'].toString().replaceAll('null', '');
        _fName = teacherDetails['firstname'].toString().replaceAll('null', '');
        _mName = teacherDetails['othernames'].toString().replaceAll('null', '');
        _lName = teacherDetails['lastname'].toString().replaceAll('null', '');
        _gender = teacherDetails['sex'].toString().replaceAll('null', '');
        _phone = teacherDetails['phone'].toString().replaceAll('null', '');
        _email = teacherDetails['email'].toString().replaceAll('null', '');
        _passport = teacherDetails['passport'].toString().replaceAll('null', '');
        _address = teacherDetails['contact_address'].toString().replaceAll('null', '');
        _city = teacherDetails['city'].toString().replaceAll('null', '');
        _state = teacherDetails['state'].toString().replaceAll('null', '');
        _nationality = teacherDetails['country'].toString().replaceAll('null', '');
        _salary = teacherDetails['salary'].toString().replaceAll('null', '');
        _dob = teacherDetails['birthday'].toString().replaceAll('null', '');
        _employmentStatus = teacherDetails['employment_status'].toString().replaceAll('null', '');
        _passportLink = map['return_data']['path_teacher_passport'].toString().replaceAll('null', '');
        _activeSession = map['active_session']['session_date'].toString().replaceAll('null', '');
        _activeTerm = map['active_term']['term'].toString().replaceAll('null', '');
        _preferredCurrency=teacherDetails['prefered_currency'].toString().replaceAll('null', '');
        _bankCode=teacherDetails['bank_code'].toString().replaceAll('null', '');
        _bankName=teacherDetails['bank_name'].toString().replaceAll('null', '');
        _bankAccountNumber=teacherDetails['bank_account_number'].toString().replaceAll('null', '');
        _signatoryArea=teacherDetails['signatory_area'].toString().replaceAll('null', '');
        _signatoryAreaUrl=map['return_data']['path_to_teacher_signatory'].toString().replaceAll('null', '');
        _deleted=teacherDetails['is_deleted'].toString().replaceAll('null', '')=='yes';
        _isFormTeacher=teacherDetails['form_teacher_status'].toString().replaceAll('null', '')=='yes';
        _currency=Currency(
          id: teacherDetails['currency_details']['id'].toString().replaceAll('null', ''),
          uniqueId: teacherDetails['currency_details']['unique_id'].toString().replaceAll('null', ''),
          baseCurrency: teacherDetails['currency_details']['base_currency'].toString().replaceAll('null', ''),
          secondCurrency: teacherDetails['currency_details']['second_currency'].toString().replaceAll('null', ''),
          rateOfConversion: teacherDetails['currency_details']['rate_of_conversion'].toString().replaceAll('null', ''),
          expression: teacherDetails['currency_details']['expression'].toString().replaceAll('null', ''),
          currencyName: teacherDetails['currency_details']['currency_name'].toString().replaceAll('null', ''),
          countryName: teacherDetails['currency_details']['country_name'].toString().replaceAll('null', ''),
          countryAbr: teacherDetails['currency_details']['country_abbr'].toString().replaceAll('null', ''),
          deleted: teacherDetails['currency_details']['is_deleted'].toString().replaceAll('null', '')!='no',
        );

        try{
          if (teacherDetails['formTeacherDetailsArray'].isNotEmpty) {
            for (var clas in teacherDetails['formTeacherDetailsArray']) {
              _formClasses.add(Classes(
                id: clas['class_id'].toString().replaceAll('null', ''),
                level:  clas['class_level']['level'].toString().replaceAll('null', ''),
                label:  clas['class_label']['label'].toString().replaceAll('null', ''),
                category:  clas['class_category']['category'].toString().replaceAll('null', ''),
              ));
              _formTerms.add(Terms(
                id: clas['term_details']['id'].toString().replaceAll('null', ''),
                uniqueId: clas['term_details']['unique_id'].toString().replaceAll('null', ''),
                term: clas['term_details']['term'].toString().replaceAll('null', ''),
                status: clas['term_details']['status'].toString().replaceAll('null', ''),
              ));
              _formSessions.add(Sessions(
                id: clas['session_details']['id'].toString().replaceAll('null', ''),
                uniqueId: clas['session_details']['unique_id'].toString().replaceAll('null', ''),
                sessionDate: clas['session_details']['session_date'].toString().replaceAll('null', ''),
                admissionNumberPrefix: clas['session_details']['admission_no_prefix'].toString().replaceAll('null', ''),
                startAndEndDate: '${clas['session_details']['session_start_date'].toString().replaceAll('null', '')}, ${clas['session_details']['session_end_date'].toString().replaceAll('null', '')}',
                status: clas['session_details']['id'].toString().replaceAll('null', ''),
              ));
            }
          }
        }on NoSuchMethodError{}

        try{
          List teacherSub = map['return_data']["subject_details_array"];
          List teacherClass = map['return_data']["all_class_details_array"];
          if (teacherSub.isNotEmpty && teacherClass.isNotEmpty) {
            for (var subject in teacherSub) {
              _subjects.add(subject["title"].toString());
              _subjectsDetail.add(Subjects(
                  id: subject["id"].toString().replaceAll('null', ''),
                  uniqueId: subject["unique_id"].toString().replaceAll('null', ''),
                  title: subject["title"].toString().replaceAll('null', ''),
                  status: subject["status"].toString().replaceAll('null', '')
              ));
            }
            for (var clas in teacherClass) {
              _classes.add('${clas["class_label_details"]["label"].toString().replaceAll('null', '')} '
                  '${clas["class_category_details"]["category"].toString().replaceAll('null', '')} (${clas["class_level_details"]["level"].toString().replaceAll('null', '')})');
              _classesDetail.add(Classes(
                  id: clas["class_details_array"]["id"].toString().replaceAll('null', ''),
                  uniqueId: clas["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
                  status: clas["class_details_array"]["status"].toString().replaceAll('null', ''),
                  category:clas["class_category_details"]["category"].toString().replaceAll('null', ''),
                  label: clas["class_label_details"]["label"].toString().replaceAll('null', ''),
                  level: clas["class_level_details"]["level"].toString().replaceAll('null', '')
              ));
            }
          }
        }on NoSuchMethodError{}

      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return Teachers(
        id: _id,
        uniqueId: _uniqueId,
        userName: _username,
        role: _role,
        title: _title,
        fName: _fName,
        mName: _mName,
        lName: _lName,
        gender: _gender,
        phone: _phone,
        email: _email,
        passport: _passport,
        address: _address,
        city: _city,
        state: _state,
        nationality: _nationality,
        salary: _salary,
        dob: _dob,
        subjects: _subjects,
        classes: _classes,
        employmentStatus: _employmentStatus,
        passportLink: _passportLink,
        activeSession: _activeSession,
        activeTerm: _activeTerm,
        currency: _currency,
        preferredCurrencyId: _preferredCurrency,
        bankCode: _bankCode,
        bankName: _bankName,
        bankAccountNumber: _bankAccountNumber,
        formClasses: _formClasses,
        formTerm: _formTerms,
        formSession: _formSessions,
        signatoryArea: _signatoryArea,
        signatoryAreaUrl: _signatoryAreaUrl,
        isFormTeacher: _isFormTeacher,
        deleted: _deleted
    );
  }

  @override
  Future<String> uploadTeacherSignatory({String teacherId, String teacherSignatory}) async{
    // TODO: implement uploadTeacherSignatory
    print(MyStrings.domain + MyStrings.uploadTeacherSignatoryUrl+await getApiToken());
    String _successMessage;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(MyStrings.domain + MyStrings.uploadTeacherSignatoryUrl+await getApiToken()));
      request.fields.addAll({
        'mobile_upload': '',
        'ext_from_mob': teacherSignatory.split('.').last
      });
      request.files.add(
          await http.MultipartFile.fromPath('file_name[]', teacherSignatory)
        /// Todo: Use either of the three above options.
      );
      final response=await request.send();

      List res=List();
      await response.stream.forEach((message) {
        res.add(String.fromCharCodes(message));
        print(String.fromCharCodes(message));
      });
      logPrint("Response status: ${response.statusCode}");
      logPrint("Response body: ${res.join('')}");



      Map map = json.decode(res.join(''));
      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _successMessage=map['success_message'];
      //Todo: get api returns here

    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.toString());
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> changeTeacherPassword(
      {String oldPassword, String newPassword, String confirmPassword}) async {
    // TODO: implement changeTeacherPassword
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.changeTeacherPasswordUrl +
              await getApiToken() +
              "/" +
              await getUserId(),
          body: {
            "current_password": oldPassword,
            "new_password": newPassword,
            "new_password_2": confirmPassword
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message = map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _message;
  }

  @override
  Future<String> updateTeacherProfile(
      {String teacherId,
        String title,
        String firstName,
        String lastName,
        String otherNames,
        String gender,
        String phone,
        String contactAddress,
        String city,
        String state,
        String country,
        String birthday,
        String role,
        String salary,
        String preferredCurrencyId,
        String bankCode,
        String bankName,
        String bankAccountNumber}) async {
    // TODO: implement updateTeacherProfile
    String _successMessage;
    print('role: $role Salary: $salary Currency: $preferredCurrencyId');
    try {
      await http.post(MyStrings.domain + MyStrings.updateTeacherProfileUrl + await getApiToken() + "/" + teacherId,
          body: {
            "title": title,
            "firstname": firstName,
            "lastname": lastName,
            "othernames": otherNames,
            "sex": gender,
            "phone": phone,
            "contact_address": contactAddress,
            "city": city,
            "state": state,
            "country": country,
            "birthday": birthday,
            "salary": salary,
            "role": role,
            "prefered_currency": preferredCurrencyId,
            "bank_code": bankCode,
            "bank_name": bankName,
            "bank_account_number": bankAccountNumber
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<Students> uploadStudentImage({String studentId, String studentImage}) async{
    // TODO: implement uploadStudentImage
    String _id, _uniqueId, _username, _fName, _mName, _lName, _email, _phone, _gender, _passport, _dob,
        _bloodGroup, _genotype, _healthHistory, _admissionNumber, _genAdmissionNumber, _residentAddress,
        _city, _state, _nationality, _stClass, _parentId, _parentName, _parentTitle, _parentPhone, _parentEmail, _parentAddress,
        _parentPassport, _parentOccupation, _passportLink, _parentPassportLink, _particularSchoolDetails, _activeSession, _activeTerm, _preferredCurrencyId, _boardingStatus, _deleted;
    Sessions _sessions;
    Classes _classes;
    School _school;
    Currency _currency;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.uploadStudentImageUrl +
              await getApiToken() +
              "/$studentId",
          body: {"passport": studentImage}).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        Map details = map['return_data']['student_details'];
        _id= details["students_details_array"][0]["id"].toString().replaceAll('null', '');
        _uniqueId= details["students_details_array"][0]["unique_id"].toString().replaceAll('null', '');
        _username=details["students_details_array"][0]["username"].toString().replaceAll('null', '');
        _fName= details["students_details_array"][0]["firstname"].toString().replaceAll('null', '');
        _mName= details["students_details_array"][0]["othernames"].toString().replaceAll('null', '');
        _lName=details["students_details_array"][0]["lastname"].toString().replaceAll('null', '');
        _email= details["students_details_array"][0]["email"].toString().replaceAll('null', '');
        _phone= details["students_details_array"][0]["phone"].toString().replaceAll('null', '');
        _gender= details["students_details_array"][0]["sex"].toString().replaceAll('null', '');
        _passport= details["students_details_array"][0]["passport"].toString().replaceAll('null', '');
        _dob= details["students_details_array"][0]["birthday"].toString().replaceAll('null', '');
        _bloodGroup= details["students_details_array"][0]["blood_group"].toString().replaceAll('null', '');
        _genotype= details["students_details_array"][0]["genotype"].toString().replaceAll('null', '');
        _healthHistory= details["students_details_array"][0]["health_history"].toString().replaceAll('null', '');
        _admissionNumber= details["students_details_array"][0]["addmission_number"].toString().replaceAll('null', '');
        _genAdmissionNumber= details["students_details_array"][0]["gen_addmission_number"].toString().replaceAll('null', '');
        _residentAddress= details["students_details_array"][0]["resident_address"].toString().replaceAll('null', '');
        _city= details["students_details_array"][0]["city"].toString().replaceAll('null', '');
        _state= details["students_details_array"][0]["state"].toString().replaceAll('null', '');
        _nationality= details["students_details_array"][0]["nationality"].toString().replaceAll('null', '');
        _preferredCurrencyId=details["students_details_array"][0]["prefered_currency"].toString().replaceAll('null', '');
        _boardingStatus=details["students_details_array"][0]['boarding_status'].toString().replaceAll('null', '');
        _deleted=details["students_details_array"][0]['is_deleted'].toString().replaceAll('null', '');
        _stClass=
        "${details["class_details_array"][0]["class_label_details"]["label"]} ${details["class_details_array"][0]["class_category_details"]["category"]} (${details["class_details_array"][0]["class_level_details"]["level"]})";
        _parentId= details["parent_details_array"][0]["id"].toString().replaceAll('null', '');
        _parentName= details["parent_details_array"][0]["parent_full_name"].toString().replaceAll('null', '');
        _parentTitle= details["parent_details_array"][0]["parent_title"].toString().replaceAll('null', '');
        _parentPhone= details["parent_details_array"][0]["parent_phone"].toString().replaceAll('null', '');
        _parentEmail= details["parent_details_array"][0]["parent_email"].toString().replaceAll('null', '');
        _parentAddress= details["parent_details_array"][0]["parent_address"].toString().replaceAll('null', '');
        _parentPassport= details["parent_details_array"][0]["parent_passport"].toString().replaceAll('null', '');
        _parentOccupation= details["parent_details_array"][0]["parents_occupation"].toString().replaceAll('null', '');
        _passportLink= details["students_passprt_link"].toString().replaceAll('null', '');
        _parentPassportLink= details["parents_passport_link"].toString().replaceAll('null', '');
        _particularSchoolDetails= details["particular_scholl_details"].toString().replaceAll('null', '');
        _activeSession=map['active_session']['session_date'].toString().replaceAll('null', '');
        _activeTerm=map['active_term']['term'].toString().replaceAll('null', '');
        _classes= new Classes(
            status: details["class_details_array"][0]["class_details_array"]["status"].toString().replaceAll('null', ''),
            id: details["class_details_array"][0]["class_details_array"]["id"].toString().replaceAll('null', ''),
            uniqueId: details["class_details_array"][0]["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
            date:'${details["class_details_array"][0]["class_details_array"]["created_at"]}, ${details["class_details_array"][0]["class_details_array"]["updated_at"]}',
            category: details["class_details_array"][0]["class_category_details"]["category"].toString().replaceAll('null', ''),
            label: details["class_details_array"][0]["class_label_details"]["label"].toString().replaceAll('null', ''),
            level: details["class_details_array"][0]["class_level_details"]["level"].toString().replaceAll('null', '')
        );
        _sessions= new Sessions(
            uniqueId:  details["students_details_array"][0]["session"]["unique_id"].toString().replaceAll('null', ''),
            id: details["students_details_array"][0]["session"]["id"].toString().replaceAll('null', ''),
            status: details["students_details_array"][0]["session"]["status"].toString().replaceAll('null', ''),
            startAndEndDate: '${details["students_details_array"][0]["session"]["session_start_date"].toString().replaceAll('null', '')}, ${details["students_details_array"][0]["session"]["session_end_date"].toString().replaceAll('null', '')}',
            sessionDate: details["students_details_array"][0]["session"]["session_date"].toString().replaceAll('null', ''),
            admissionNumberPrefix: details["students_details_array"][0]["session"]["admission_no_prefix"].toString().replaceAll('null', '')
        );
        _school= new School(
          name: map['current_school_details_array']['name'].toString().replaceAll('null', ''),
          email: map['current_school_details_array']['contact_email'].toString().replaceAll('null', ''),
          phone: map['current_school_details_array']['contact_phone_number'].toString().replaceAll('null', ''),
          address: map['current_school_details_array']['address'].toString().replaceAll('null', ''),
          town: map['current_school_details_array']['town'].toString().replaceAll('null', ''),
          lga: map['current_school_details_array']['lga'].toString().replaceAll('null', ''),
          city: map['current_school_details_array']['city'].toString().replaceAll('null', ''),
          nationality: map['current_school_details_array']['nationality'].toString().replaceAll('null', ''),
          slogan: map['current_school_details_array']['slogan'].toString().replaceAll('null', ''),
          status: map['current_school_details_array']['status'].toString().replaceAll('null', ''),
          image: map['current_school_details_array']['image'].toString().replaceAll('null', ''),
          cacFile: map['current_school_details_array']['cac_file'].toString().replaceAll('null', ''),
          otherFile: map['current_school_details_array']['otherfile'].toString().replaceAll('null', ''),
          poBox: map['current_school_details_array']['p_o_box'].toString().replaceAll('null', ''),
          twitter: map['current_school_details_array']['twitter'].toString().replaceAll('null', ''),
          facebook: map['current_school_details_array']['facebook'].toString().replaceAll('null', ''),
          website: map['current_school_details_array']['school_website'].toString().replaceAll('null', ''),
          instagram: map['current_school_details_array']['instagram'].toString().replaceAll('null', ''),
        );
        try{
          _currency= new Currency(
            id: details["students_details_array"][0]["currency_details"]["id"].toString().replaceAll('null', ''),
            uniqueId: details["students_details_array"][0]["currency_details"]["unique_id"].toString().replaceAll('null', ''),
            baseCurrency: details["students_details_array"][0]["currency_details"]["base_currency"].toString().replaceAll('null', ''),
            secondCurrency: details["students_details_array"][0]["currency_details"]["second_currency"].toString().replaceAll('null', ''),
            rateOfConversion: details["students_details_array"][0]["currency_details"]["rate_of_conversion"].toString().replaceAll('null', ''),
            expression: details["students_details_array"][0]["currency_details"]["expression"].toString().replaceAll('null', ''),
            currencyName: details["students_details_array"][0]["currency_details"]["currency_name"].toString().replaceAll('null', ''),
            countryName: details["students_details_array"][0]["currency_details"]["country_name"].toString().replaceAll('null', ''),
            countryAbr: details["students_details_array"][0]["currency_details"]["country_abbr"].toString().replaceAll('null', ''),
            deleted: details["students_details_array"][0]["currency_details"]["is_deleted"].toString().replaceAll('null', '')!='no',
          );
        }on NoSuchMethodError{}
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return Students(
        id: _id,
        uniqueId: _uniqueId,
        userName: _username,
        phone: _phone,
        state: _state,
        city: _city,
        email: _email,
        gender: _gender,
        activeTerm: _activeTerm,
        activeSession: _activeSession,
        nationality: _nationality,
        passportLink: _passportLink,
        admissionNumber: _admissionNumber,
        bloodGroup: _bloodGroup,
        dob: _dob,
        fName: _fName,
        genAdmissionNumber: _genAdmissionNumber,
        genotype: _genotype,
        healthHistory: _healthHistory,
        lName: _lName,
        mName: _mName,
        parentId: _parentId,
        parentAddress: _parentAddress,
        parentEmail: _parentEmail,
        parentName: _parentName,
        parentOccupation: _parentOccupation,
        parentPassport: _parentPassport,
        parentPhone: _parentPhone,
        parentTitle: _parentTitle,
        particularSchoolDetails: _particularSchoolDetails,
        passport: _passport,
        residentAddress: _residentAddress,
        parentPassportLink: _parentPassportLink,
        stClass: _stClass,
        classes: _classes,
        sessions: _sessions,
        school: _school,
        preferredCurrencyId: _preferredCurrencyId,
        currency: _currency,
        boardingStatus: _boardingStatus=='yes',
        deleted: _deleted!='no'
    );
  }

  @override
  Future<String> changeStudentPassword({String oldPassword, String newPassword, String confirmPassword}) async{
    // TODO: implement changeStudentPassword
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.changeStudentPasswordUrl +
              await getApiToken() +
              "/" +
              await getUserId(),
          body: {
            "current_password": oldPassword,
            "new_password": newPassword,
            "new_password_2": confirmPassword
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _message = map['success_message'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _message;
  }

  @override
  Future<String> updateStudentProfile({String studentId, String firstName, String lastName, String otherNames, String gender, String phone, String email, String contactAddress, String city, String state, String country, String birthday, String bloodGroup, String genotype, String healthHistory, String preferredCurrencyId, String boardingStatus}) async{
    // TODO: implement updateStudentProfile
    String _successMessage;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateStudentProfileUrl +
              await getApiToken() +
              "/" +
              studentId,
          body: {
            "firstname": firstName,
            "lastname": lastName,
            "othernames": otherNames,
            "sex": gender,
            "email": email,
            "phone": phone,
            "resident_address": contactAddress,
            "city": city,
            "state": state,
            "nationality": country,
            "birthday": birthday,
            "blood_group": bloodGroup,
            "genotype": genotype,
            "health_history": healthHistory,
            "prefered_currency": preferredCurrencyId,
            "boarding_status": boardingStatus
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> updateParentProfile({String studentId, String parentId, String parentFullName, String parentTitle, String parentAddress, String parentsOccupation}) async{
    // TODO: implement updateParentProfile
    String _successMessage;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateParentProfileUrl +
              await getApiToken() +
              "/$parentId/$studentId",
          body: {
            "parent_full_name": parentFullName,
            "parent_title": parentTitle,
            "parent_address": parentAddress,
            "parents_occupation": parentsOccupation
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<Students> uploadParentImage({String studentId, String parentId, String parentImage}) async{
    // TODO: implement uploadParentImage
    String _id, _uniqueId, _username, _fName, _mName, _lName, _email, _phone, _gender, _passport, _dob,
        _bloodGroup, _genotype, _healthHistory, _admissionNumber, _genAdmissionNumber, _residentAddress,
        _city, _state, _nationality, _stClass, _parentId, _parentName, _parentTitle, _parentPhone, _parentEmail, _parentAddress,
        _parentPassport, _parentOccupation, _passportLink, _parentPassportLink, _particularSchoolDetails, _activeSession, _activeTerm, _preferredCurrencyId, _boardingStatus, _deleted;
    Sessions _sessions;
    Classes _classes;
    School _school;
    Currency _currency;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.changeParentImageUrl +
              await getApiToken() +
              "/$parentId/$studentId",
          body: {"passport": parentImage}).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        Map details = map['return_data']['student_details'];
        _id= details["students_details_array"][0]["id"].toString().replaceAll('null', '');
        _uniqueId= details["students_details_array"][0]["unique_id"].toString().replaceAll('null', '');
        _username=details["students_details_array"][0]["username"].toString().replaceAll('null', '');
        _fName= details["students_details_array"][0]["firstname"].toString().replaceAll('null', '');
        _mName= details["students_details_array"][0]["othernames"].toString().replaceAll('null', '');
        _lName=details["students_details_array"][0]["lastname"].toString().replaceAll('null', '');
        _email= details["students_details_array"][0]["email"].toString().replaceAll('null', '');
        _phone= details["students_details_array"][0]["phone"].toString().replaceAll('null', '');
        _gender= details["students_details_array"][0]["sex"].toString().replaceAll('null', '');
        _passport= details["students_details_array"][0]["passport"].toString().replaceAll('null', '');
        _dob= details["students_details_array"][0]["birthday"].toString().replaceAll('null', '');
        _bloodGroup= details["students_details_array"][0]["blood_group"].toString().replaceAll('null', '');
        _genotype= details["students_details_array"][0]["genotype"].toString().replaceAll('null', '');
        _healthHistory= details["students_details_array"][0]["health_history"].toString().replaceAll('null', '');
        _admissionNumber= details["students_details_array"][0]["addmission_number"].toString().replaceAll('null', '');
        _genAdmissionNumber= details["students_details_array"][0]["gen_addmission_number"].toString().replaceAll('null', '');
        _residentAddress= details["students_details_array"][0]["resident_address"].toString().replaceAll('null', '');
        _city= details["students_details_array"][0]["city"].toString().replaceAll('null', '');
        _state= details["students_details_array"][0]["state"].toString().replaceAll('null', '');
        _nationality= details["students_details_array"][0]["nationality"].toString().replaceAll('null', '');
        _preferredCurrencyId=details["students_details_array"][0]["prefered_currency"].toString().replaceAll('null', '');
        _boardingStatus=details["students_details_array"][0]['boarding_status'].toString().replaceAll('null', '');
        _deleted=details["students_details_array"][0]['is_deleted'].toString().replaceAll('null', '');
        _stClass=
        "${details["class_details_array"][0]["class_label_details"]["label"]} ${details["class_details_array"][0]["class_category_details"]["category"]} (${details["class_details_array"][0]["class_level_details"]["level"]})";
        _parentId= details["parent_details_array"][0]["id"].toString().replaceAll('null', '');
        _parentName= details["parent_details_array"][0]["parent_full_name"].toString().replaceAll('null', '');
        _parentTitle= details["parent_details_array"][0]["parent_title"].toString().replaceAll('null', '');
        _parentPhone= details["parent_details_array"][0]["parent_phone"].toString().replaceAll('null', '');
        _parentEmail= details["parent_details_array"][0]["parent_email"].toString().replaceAll('null', '');
        _parentAddress= details["parent_details_array"][0]["parent_address"].toString().replaceAll('null', '');
        _parentPassport= details["parent_details_array"][0]["parent_passport"].toString().replaceAll('null', '');
        _parentOccupation= details["parent_details_array"][0]["parents_occupation"].toString().replaceAll('null', '');
        _passportLink= details["students_passprt_link"].toString().replaceAll('null', '');
        _parentPassportLink= details["parents_passport_link"].toString().replaceAll('null', '');
        _particularSchoolDetails= details["particular_scholl_details"].toString().replaceAll('null', '');
        _activeSession=map['active_session']['session_date'].toString().replaceAll('null', '');
        _activeTerm=map['active_term']['term'].toString().replaceAll('null', '');
        _classes= new Classes(
            status: details["class_details_array"][0]["class_details_array"]["status"].toString().replaceAll('null', ''),
            id: details["class_details_array"][0]["class_details_array"]["id"].toString().replaceAll('null', ''),
            uniqueId: details["class_details_array"][0]["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
            date:'${details["class_details_array"][0]["class_details_array"]["created_at"]}, ${details["class_details_array"][0]["class_details_array"]["updated_at"]}',
            category: details["class_details_array"][0]["class_category_details"]["category"].toString().replaceAll('null', ''),
            label: details["class_details_array"][0]["class_label_details"]["label"].toString().replaceAll('null', ''),
            level: details["class_details_array"][0]["class_level_details"]["level"].toString().replaceAll('null', '')
        );
        _sessions= new Sessions(
            uniqueId:  details["students_details_array"][0]["session"]["unique_id"].toString().replaceAll('null', ''),
            id: details["students_details_array"][0]["session"]["id"].toString().replaceAll('null', ''),
            status: details["students_details_array"][0]["session"]["status"].toString().replaceAll('null', ''),
            startAndEndDate: '${details["students_details_array"][0]["session"]["session_start_date"].toString().replaceAll('null', '')}, ${details["students_details_array"][0]["session"]["session_end_date"].toString().replaceAll('null', '')}',
            sessionDate: details["students_details_array"][0]["session"]["session_date"].toString().replaceAll('null', ''),
            admissionNumberPrefix: details["students_details_array"][0]["session"]["admission_no_prefix"].toString().replaceAll('null', '')
        );
        _school= new School(
          name: map['current_school_details_array']['name'].toString().replaceAll('null', ''),
          email: map['current_school_details_array']['contact_email'].toString().replaceAll('null', ''),
          phone: map['current_school_details_array']['contact_phone_number'].toString().replaceAll('null', ''),
          address: map['current_school_details_array']['address'].toString().replaceAll('null', ''),
          town: map['current_school_details_array']['town'].toString().replaceAll('null', ''),
          lga: map['current_school_details_array']['lga'].toString().replaceAll('null', ''),
          city: map['current_school_details_array']['city'].toString().replaceAll('null', ''),
          nationality: map['current_school_details_array']['nationality'].toString().replaceAll('null', ''),
          slogan: map['current_school_details_array']['slogan'].toString().replaceAll('null', ''),
          status: map['current_school_details_array']['status'].toString().replaceAll('null', ''),
          image: map['current_school_details_array']['image'].toString().replaceAll('null', ''),
          cacFile: map['current_school_details_array']['cac_file'].toString().replaceAll('null', ''),
          otherFile: map['current_school_details_array']['otherfile'].toString().replaceAll('null', ''),
          poBox: map['current_school_details_array']['p_o_box'].toString().replaceAll('null', ''),
          twitter: map['current_school_details_array']['twitter'].toString().replaceAll('null', ''),
          facebook: map['current_school_details_array']['facebook'].toString().replaceAll('null', ''),
          website: map['current_school_details_array']['school_website'].toString().replaceAll('null', ''),
          instagram: map['current_school_details_array']['instagram'].toString().replaceAll('null', ''),
        );
        try{
          _currency= new Currency(
            id: details["students_details_array"][0]["currency_details"]["id"].toString().replaceAll('null', ''),
            uniqueId: details["students_details_array"][0]["currency_details"]["unique_id"].toString().replaceAll('null', ''),
            baseCurrency: details["students_details_array"][0]["currency_details"]["base_currency"].toString().replaceAll('null', ''),
            secondCurrency: details["students_details_array"][0]["currency_details"]["second_currency"].toString().replaceAll('null', ''),
            rateOfConversion: details["students_details_array"][0]["currency_details"]["rate_of_conversion"].toString().replaceAll('null', ''),
            expression: details["students_details_array"][0]["currency_details"]["expression"].toString().replaceAll('null', ''),
            currencyName: details["students_details_array"][0]["currency_details"]["currency_name"].toString().replaceAll('null', ''),
            countryName: details["students_details_array"][0]["currency_details"]["country_name"].toString().replaceAll('null', ''),
            countryAbr: details["students_details_array"][0]["currency_details"]["country_abbr"].toString().replaceAll('null', ''),
            deleted: details["students_details_array"][0]["currency_details"]["is_deleted"].toString().replaceAll('null', '')!='no',
          );
        }on NoSuchMethodError{}
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return Students(
        id: _id,
        uniqueId: _uniqueId,
        userName: _username,
        phone: _phone,
        state: _state,
        city: _city,
        email: _email,
        gender: _gender,
        activeTerm: _activeTerm,
        activeSession: _activeSession,
        nationality: _nationality,
        passportLink: _passportLink,
        admissionNumber: _admissionNumber,
        bloodGroup: _bloodGroup,
        dob: _dob,
        fName: _fName,
        genAdmissionNumber: _genAdmissionNumber,
        genotype: _genotype,
        healthHistory: _healthHistory,
        lName: _lName,
        mName: _mName,
        parentId: _parentId,
        parentAddress: _parentAddress,
        parentEmail: _parentEmail,
        parentName: _parentName,
        parentOccupation: _parentOccupation,
        parentPassport: _parentPassport,
        parentPhone: _parentPhone,
        parentTitle: _parentTitle,
        particularSchoolDetails: _particularSchoolDetails,
        passport: _passport,
        residentAddress: _residentAddress,
        parentPassportLink: _parentPassportLink,
        stClass: _stClass,
        classes: _classes,
        sessions: _sessions,
        school: _school,
        preferredCurrencyId: _preferredCurrencyId,
        currency: _currency,
        boardingStatus: _boardingStatus=='yes',
        deleted: _deleted!='no'
    );
  }

  @override
  Future<String> createTeacherProfile({String role, String title, String firstName, String lastName, String otherNames, String username,
    String password, String gender, String phone, String email, String contactAddress, String city, String state, String country, String salary,
    String birthday, @required String bankCode,
    String bankName, String bankAccountNumber, String passport}) async{
    // TODO: implement createTeacherProfile
    String _successMessage;
    try {
      await http.post(
          MyStrings.domain + MyStrings.createTeacherProfileUrl + await getApiToken(),
          body: {
            "role": role,
            "title": title,
            "firstname": firstName,
            "lastname": lastName,
            "othernames": otherNames,
            "username": username,
            "password": password,
            "sex": gender,
            "phone": phone,
            "email": email,
            "contact_address": contactAddress,
            "city": city,
            "state": state,
            "country": country,
            "salary": salary,
            "birthday": birthday,
            "bank_code": bankCode,
            "bank_name": bankName,
            "bank_account_number": bankAccountNumber
            //"passport": passport
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> addFormTeacher({String classId, String sessionId, String termId, String teacherId}) async{
    // TODO: implement addFormTeacher
    print(MyStrings.domain + MyStrings.addFormTeacherUrl + await getApiToken());
    String _successMessage;
    try {
      await http.post(
          MyStrings.domain + MyStrings.addFormTeacherUrl + await getApiToken(),
          body: {
            "class_id": classId,
            "session_i": sessionId,
            "term_id": termId,
            "teacher_id": teacherId
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> removeFormTeacher({String classId, String assignedId, String teacherId}) async{
    // TODO: implement removeFormTeacher
    String _successMessage;
    try {
      print(MyStrings.domain + MyStrings.removeFormTeacherUrl + await getApiToken());
      await http.post(
          MyStrings.domain + MyStrings.removeFormTeacherUrl + await getApiToken(),
          body: {
            "class_id": classId,
            "assigned_id": assignedId,
            "teacher_id": teacherId
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> addTeacherClassSubject({String teacherId, String subjectId, String classId, String sessionId, String termId}) async{
    // TODO: implement addTeacherClassSubject
    print(MyStrings.domain + MyStrings.addTeacherClassSubjectUrl + await getApiToken());
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.addTeacherClassSubjectUrl + await getApiToken(),
          body: {
            "teacher_id": teacherId,
            "subject_id": subjectId,
            "class_id": classId,
            "session_i": sessionId,
            "term_id": termId
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> updateTeacherClassSubject({String assignmentId, String teacherId, String subjectId, String classId}) async{
    // TODO: implement updateTeacherClassSubject
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.updateTeacherClassSubjectUrl +'${ await getApiToken()}/$assignmentId',
          body: {
            "teacher_id": teacherId,
            "subject_id": subjectId,
            "class_id": classId,
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> deleteTeacherClassSubject({String assignmentId}) async{
    // TODO: implement deleteTeacherClassSubject
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.removeTeacherClassSubjectUrl +'${ await getApiToken()}/$assignmentId',
          body: {}).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> createStudentProfile({String firstName, String lastName, String otherNames, String email, String admissionNUmber, String phone, String contactAddress, String state, String city, String gender, String country, String birthday, String bloodGroup, String genotype, String healthHistory, String boardingStatus, String classId, String sessionId, String parentFullName, String parentTitle, String parentEmail, String parentPhone, String parentAddress, String parentsOccupation}) async{
    // TODO: implement createStudentProfile
    String _successMessage;
    /*print("session_i $sessionId, class_i: $classId,last_name: $lastName,first_name: $firstName,othernames: $otherNames,addmission_number: $admissionNUmber,birthday: $birthday,gender: $gender,address: $contactAddress,city: $city,country: $country,state_of_residence: $contactAddress,parents_title: $parentTitle,parents_fullname: $parentFullName,parents_occupation: $parentsOccupation,parents_phone: $parentPhone,parent_email: $parentEmail,parents_address: $parentAddress,boarding_status: $boardingStatus,blood_group: $bloodGroup,genotype: $genotype phone: $phone, email : $email");*/
    try {
      //print(MyStrings.domain + MyStrings.createStudentProfileUrl + await getApiToken());
      await http.post(
          MyStrings.domain + MyStrings.createStudentProfileUrl + await getApiToken(),
          body: {
            "session_i": sessionId,
            "class_i": classId,
            "last_name": lastName,
            "first_name": firstName,
            "othernames": otherNames,
            "addmission_number": admissionNUmber,
            "birthday": birthday,
            "gender": gender,
            "address": contactAddress,
            "phone": phone,
            'email': email,
            "city": city,
            "country": country,
            "state_of_residence": contactAddress,
            "parents_title": parentTitle,
            "parents_fullname": parentFullName,
            "parents_occupation": parentsOccupation,
            "parents_phone": parentPhone,
            "parent_email": parentEmail,
            "parents_address": parentAddress,
            "boarding_status": boardingStatus,
            "blood_group": bloodGroup,
            "genotype": genotype,
            "health_history": healthHistory
          }).then((response) {

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> deleteStudentProfile({String studentId}) async{
    // TODO: implement deleteStudentProfile
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteStudentProfileUrl +await getApiToken(),
          body: {
            "student_id": studentId
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

  @override
  Future<String> updateSchoolSettings({String schoolId, String poBox, String preferredCurrencyId, String resultCommentSwitch, List<String> traits, List<String> ratings, String numOfTerm, String initialAdmissionNum, String numOfCumulativeTest, List<String> testExamScoreLimit, List<String> behaviouralSkillTestsHeadings, String useCumulativeResult, String useCustomAdmissionNum, String useClassCategoryStatus, String useOfSignatureOnResults}) async{
    // TODO: implement updateSchoolSettings
    String _successMessage;
    try {
      print(MyStrings.domain + MyStrings.updateSchoolSettingsUrl + await getApiToken());
      await http.post(
          MyStrings.domain + MyStrings.updateSchoolSettingsUrl + await getApiToken(), body: {
            "p_o_box": poBox,
            'prefered_currency':preferredCurrencyId,
            "result_comment_switch": resultCommentSwitch,
            "traits": traits.join(','),
            "ratings": ratings.join(','),
            "no_of_terms": numOfTerm,
            "initial_admission_no": initialAdmissionNum,
            "no_of_cumulative_test": numOfCumulativeTest,
            'test_exam_score_limit':testExamScoreLimit.join(','),
            'behavioural_skill_tests_headings':behaviouralSkillTestsHeadings.join(','),
            'use_of_cummulative_result':useCumulativeResult,
            'use_of_custom_admission_number':useCustomAdmissionNum,
            'class_category_status': useClassCategoryStatus,
            'use_of_signature_on_results': useOfSignatureOnResults
          }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _successMessage = map['success_message'];
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _successMessage;
  }

}
