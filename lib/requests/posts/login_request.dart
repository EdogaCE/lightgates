import 'package:meta/meta.dart';
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/app_versions.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class LoginRepository {
  Future<User> loginSchool({@required String email, @required String password});
  Future<User> loginTeacher({@required String email, @required String password});
  Future<User> loginStudent({@required String email, @required String password});
  Future<AppVersions> fetchAppVersion({bool localDb});
}

class LoginRequests implements LoginRepository{
  String _logoName, _appName, _id, _uniqueId, _userName, _contactPhone,
      _contactEmail, _address, _town, _lga, _city, _nationality, _image, _apiToken, _userChatId, _userChatType, _assessmentsCount='0', _learningMaterialsCount='0', _eventsCount='0', _pendingFees='0',  _numberOfStudents='0', _numberOfTeachers='0', _numberOfSubjects='0', _confirmedFees='0', _pendingResultsCount='0', _confirmedResultsCount='0', _numberOfClassTeaching='0', _numberOfClassForming='0', _videoForVerification;
  @override
  Future<User> loginSchool({String email, String password}) async {
    bool _firstTimeLogin, _verificationStatus;
    String _firstTimeSetupPage;
    try {
      await http.post(MyStrings.domain + MyStrings.schoolLoginUrl, body: {
        "contact_email": email,
        "password": password
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _logoName = map['logo_name'].toString();
        _appName = map["app_name"].toString();
        Map returnData = map['return_data']['school_details'][0];
        _id=returnData['id'].toString();
        _uniqueId=returnData['unique_id'].toString();
        _userName = returnData['name'].toString();
        _contactPhone = returnData['contact_phone_number'].toString();
        _contactEmail = returnData['contact_email'].toString();
        _address = returnData['address'].toString();
        _town = returnData['town'].toString();
        _lga = returnData['lga'].toString();
        _city = returnData['city'].toString();
        _nationality = returnData['nationality'].toString();
        _image = returnData['image'].toString();
        _apiToken = returnData['api_token'].toString();
        _userChatId=returnData['sender_id_for_chat'].toString();
        _userChatType=returnData['type_of_user_for_chat'].toString();
        _firstTimeLogin=returnData['first_time_login'].toString().replaceAll('null', '')=='yes';
        _firstTimeSetupPage=returnData['first_time_setup_page'].toString().replaceAll('null', '');
        _verificationStatus=returnData['verification_status'].toString().replaceAll('null', '')=='yes';
        _videoForVerification=returnData['video_for_verification'].toString().replaceAll('null', '');
        if(map['return_data']['dash_board_details']!=null){
          _numberOfStudents=map['return_data']['dash_board_details']['all_students_array']['count_students'].toString().replaceAll('null', '0');
          _numberOfTeachers=map['return_data']['dash_board_details']['all_teachers_array']['count_teachers'].toString().replaceAll('null', '0');
          _numberOfSubjects=map['return_data']['dash_board_details']['all_subjects_array']['count_subjects'].toString().replaceAll('null', '0');
          _confirmedFees=map['return_data']['dash_board_details']['confirmed_payment_array']['confirmed_amount_paid'].toString().replaceAll('null', '0');
          _pendingFees=map['return_data']['dash_board_details']['confirmed_payment_array']['confirmed_balance'].toString().replaceAll('null', '0');
        }

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return User(
      logoName: _logoName,
      appName: _appName,
      id: _id,
      uniqueId: _uniqueId,
      userName: _userName,
      contactPhone: _contactPhone,
      contactEmail: _contactEmail,
      address: _address,
      town: _town,
      lga: _lga,
      city: _city,
      nationality: _nationality,
      image: _image,
      apiToken: _apiToken,
      userChatId: _userChatId,
      userChatType: _userChatType,
      numberOfStudents: _numberOfStudents,
      numberOfTeachers: _numberOfTeachers,
      numberOfSubjects: _numberOfSubjects,
      pendingFees: _pendingFees,
      confirmedFees: _confirmedFees,
      firstTimeLogin: _firstTimeLogin,
      verificationStatus: _verificationStatus,
      videoForVerification: _videoForVerification,
      firstTimeSetupPage: _firstTimeSetupPage
    );
  }

  @override
  Future<User> loginTeacher({String email, String password}) async {
    // TODO: implement loginTeacher
    print(email);
    print(password);
    bool _isFormTeacher;
    try {
      await http.post(MyStrings.domain+MyStrings.teacherLoginUrl, body: {
        "contact_email": email,
        "password": password
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _logoName = map['logo_name'].toString();
        _appName = map["app_name"].toString();
        Map returnData = map['return_data'];
        _id=returnData['id'].toString();
        _uniqueId=returnData['unique_id'].toString();
        _userName = '${returnData['firstname'].toString()} ${returnData['lastname'].toString()} ${returnData['othernames'].toString()}';
        _contactPhone = returnData['phone'].toString();
        _contactEmail = returnData['email'].toString();
        _address = returnData['contact_address'].toString();
        _town = returnData['state'].toString();
        _lga = '';
        _city = returnData['city'].toString();
        _nationality = returnData['country'].toString();
        _image = returnData['passport'].toString();
        _apiToken = returnData['api_token'].toString();
        _isFormTeacher=returnData['form_teacher_status']=='yes';
        _userChatId=returnData['sender_id_for_chat'].toString();
        _userChatType=returnData['type_of_user_for_chat'].toString();
        if(returnData['teacher_dashboard_details']!=null){
          _assessmentsCount=returnData['teacher_dashboard_details']['teacher_assessments_count'].toString().replaceAll('null', '0');
          _learningMaterialsCount=returnData['teacher_dashboard_details']['learning_materials_count'].toString().replaceAll('null', '0');
          _pendingResultsCount=returnData['teacher_dashboard_details']['pending_results_count'].toString().replaceAll('null', '0');
          _confirmedResultsCount=returnData['teacher_dashboard_details']['confirmed_results_count'].toString().replaceAll('null', '0');
          _numberOfClassTeaching=returnData['teacher_dashboard_details']['class_teaching_count'].toString().replaceAll('null', '0');
          _numberOfClassForming=returnData['teacher_dashboard_details']['formTeachers_count'].toString().replaceAll('null', '0');
        }

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return User(
      logoName: _logoName,
      appName: _appName,
      id: _id,
      uniqueId: _uniqueId,
      userName: _userName,
      contactPhone: _contactPhone,
      contactEmail: _contactEmail,
      address: _address,
      town: _town,
      lga: _lga,
      city: _city,
      nationality: _nationality,
      image: _image,
      apiToken: _apiToken,
      isFormTeacher: _isFormTeacher,
      userChatType: _userChatType,
      userChatId: _userChatId,
      assessmentsCount: _assessmentsCount,
      learningMaterialsCount: _learningMaterialsCount,
      pendingResultsCount: _pendingResultsCount,
      confirmedResultsCount: _confirmedResultsCount,
      numberOfClassTeaching: _numberOfClassTeaching,
      numberOfClassForming: _numberOfClassForming,
      verificationStatus: true,
      firstTimeLogin: false,
      firstTimeSetupPage: ''
    );
  }

  @override
  Future<User> loginStudent({String email, String password}) async{
    // TODO: implement loginStudent
    print(email);
    print(password);
    try {
      await http.post(MyStrings.domain+MyStrings.studentLoginUrl, body: {
        "contact_email": email,
        "password": password
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _logoName = map['logo_name'].toString();
        _appName = map["app_name"].toString();
        Map returnData = map['return_data'];
        _id=returnData['id'].toString();
        _uniqueId=returnData['unique_id'].toString();
        _userName = '${returnData['firstname'].toString()} ${returnData['lastname'].toString()} ${returnData['othernames'].toString()}';
        _contactPhone = returnData['phone'].toString();
        _contactEmail = returnData['email'].toString();
        _address = returnData['sex'].toString();
        _town = returnData['addmission_number'].toString();
        _lga = returnData['gen_addmission_number'].toString();
        _city = returnData['username'].toString();
        _nationality = returnData['parent_unique_id'].toString();
        _image = returnData['passport'].toString();
        _apiToken = returnData['api_token'].toString();
        _userChatId=returnData['sender_id_for_chat'].toString();
        _userChatType=returnData['type_of_user_for_chat'].toString();
        if(returnData['student_dashboard_details']!=null){
          _assessmentsCount=returnData['student_dashboard_details']["student_assessments_count"].toString().replaceAll('null', '0');
          _learningMaterialsCount=returnData['student_dashboard_details']["learning_materials_count"].toString().replaceAll('null', '0');
          _eventsCount=returnData['student_dashboard_details']["events_count"].toString().replaceAll('null', '0');
          _pendingFees=returnData['student_dashboard_details']["pending_fees_sum"].toString().replaceAll('null', '0');
        }
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return User(
      logoName: _logoName,
      appName: _appName,
      id: _id,
      uniqueId: _uniqueId,
      userName: _userName,
      contactPhone: _contactPhone,
      contactEmail: _contactEmail,
      address: _address,
      town: _town,
      lga: _lga,
      city: _city,
      nationality: _nationality,
      image: _image,
      apiToken: _apiToken,
      userChatId: _userChatId,
      userChatType: _userChatType,
      assessmentsCount: _assessmentsCount,
      learningMaterialsCount: _learningMaterialsCount,
      eventsCount: _eventsCount,
      pendingFees: _pendingFees,
        verificationStatus: true,
        firstTimeLogin: false,
      firstTimeSetupPage: ''
    );
  }

  @override
  Future<AppVersions> fetchAppVersion({bool localDb}) async{
    // TODO: implement fetchAppVersion
    AppVersions appVersions;
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;

      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'appVersion');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.getAppVersionUrl);
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        if(await databaseHandlerRepository.getData(title: 'appVersion')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'appVersion', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'appVersion', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        Map appDetails=map['return_data']['settings_details'];
        appVersions=AppVersions(
            androidVersion: appDetails['android_app_version'].toString(),
            iosVersion: appDetails['ios_app_version'].toString(),
            androidPlayStoreLink: appDetails['play_store_link'].toString(),
            iosAppStoreLink: appDetails['ios_app_store_link'].toString()

        );
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return appVersions;
  }

}


