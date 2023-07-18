import 'package:meta/meta.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/models/students.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class PickUpIdRepository {
  Future<Students> verifyPickUpId({@required String pickUpId});
  Future<String> generatePickUpId({@required String studentId, @required String password});
}

class PickUpIdRequests implements PickUpIdRepository{
  @override
  Future<Students> verifyPickUpId({String pickUpId}) async {
    String _id, _uniqueId, _fName, _mName, _lName, _email, _phone, _gender, _passport, _dob, _bloodGroup,
    _genotype, _healthHistory, _admissionNumber,_genAdmissionNumber, _residentAddress, _city, _state, _nationality,
    _stClass, _parentName, _parentTitle, _parentPhone, _parentEmail, _parentAddress, _parentPassport, _parentOccupation,
    _passportLink, _preferredCurrencyId, _boardingStatus, _deleted, _username, _password;
    Sessions _sessions;

    try {
      await http.post(MyStrings.domain + MyStrings.verifyPickUpIdUrl+ await getApiToken(), body: {
        "pickUpPupil_id": pickUpId,
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _id=map['return_data']["pickUpId_StudentDetails"]["id"].toString();
        _uniqueId=map['return_data']["pickUpId_StudentDetails"]["unique_id"]??'';
        _fName=map['return_data']["pickUpId_StudentDetails"]["firstname"]??'';
        _mName=map['return_data']["pickUpId_StudentDetails"]["othernames"]??'';
        _lName=map['return_data']["pickUpId_StudentDetails"]["lastname"]??'';
        _username=map['return_data']["pickUpId_StudentDetails"]["username"]??'';
        _password=map['return_data']["pickUpId_StudentDetails"]["alt_pass"]??'';
        _email=map['return_data']["pickUpId_StudentDetails"]["email"]??'';
        _phone=map['return_data']["pickUpId_StudentDetails"]["phone"]??'';
        _gender=map['return_data']["pickUpId_StudentDetails"]["sex"]??'';
        _passport=map['return_data']["pickUpId_StudentDetails"]["passport"]??'';
        _dob=map['return_data']["pickUpId_StudentDetails"]["birthday"]??'';
        _bloodGroup= map['return_data']["pickUpId_StudentDetails"]["blood_group"]??'';
        _genotype=map['return_data']["pickUpId_StudentDetails"]["genotype"]??'';
        _healthHistory=map['return_data']["pickUpId_StudentDetails"]["health_history"]??'';
        _admissionNumber=map['return_data']["pickUpId_StudentDetails"]
        ["addmission_number"].toString().replaceAll('null', '');
        _genAdmissionNumber=map['return_data']["pickUpId_StudentDetails"]
        ["gen_addmission_number"].toString().replaceAll('null', '');
        _residentAddress=map['return_data']["pickUpId_StudentDetails"]["resident_address"].toString().replaceAll('null', '');
        _city=map['return_data']["pickUpId_StudentDetails"]["city"].toString().replaceAll('null', '');
        _state=map['return_data']["pickUpId_StudentDetails"]["state"].toString().replaceAll('null', '');
        _nationality=map['return_data']["pickUpId_StudentDetails"]["nationality"].toString().replaceAll('null', '');
        _stClass="${map['return_data']["class_details"]["class_label_details"]["label"]}, ${map['return_data']["class_details"]["class_category_details"]["category"]} , ${map['return_data']["class_details"]["class_level_details"]["level"]}";
        _preferredCurrencyId=map['return_data']["pickUpId_StudentDetails"]["prefered_currency"].toString().replaceAll('null', '');
        _boardingStatus=map['return_data']["pickUpId_StudentDetails"]['boarding_status'].toString().replaceAll('null', '');
        _deleted=map['return_data']["pickUpId_StudentDetails"]['is_deleted'].toString().replaceAll('null', '');
        _parentName=map['return_data']["parents_data"]["parent_full_name"].toString().replaceAll('null', '');
        _parentTitle=map['return_data']["parents_data"]["parent_title"].toString().replaceAll('null', '');
        _parentPhone=map['return_data']["parents_data"]["parent_phone"].toString().replaceAll('null', '');
        _parentEmail=map['return_data']["parents_data"]["parent_email"].toString().replaceAll('null', '');
        _parentAddress=map['return_data']["parents_data"]["parent_address"].toString().replaceAll('null', '');
        _parentPassport=map['return_data']["parents_data"]["parent_passport"].toString().replaceAll('null', '');
        _parentOccupation=map['return_data']["parents_data"]
        ["parents_occupation"].toString().replaceAll('null', '');
        _passportLink=map['return_data']["students_passprt_link"].toString().replaceAll('null', '');
        _sessions=Sessions(
          id: map['return_data']["pickUpId_StudentDetails"]
          ["session"]["id"].toString().replaceAll('null', ''),
          uniqueId: map['return_data']["pickUpId_StudentDetails"]
          ["session"]["unique_id"].toString().replaceAll('null', ''),
          admissionNumberPrefix: map['return_data']["pickUpId_StudentDetails"]
          ["session"]["admission_no_prefix"].toString().replaceAll('null', ''),
          sessionDate: map['return_data']["pickUpId_StudentDetails"]
          ["session"]["session_date"].toString().replaceAll('null', ''),
          status: map['return_data']["pickUpId_StudentDetails"]
          ["session"]["status"].toString().replaceAll('null', '')
        );
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return Students(
        id: _id,
        uniqueId: _uniqueId,
        fName: _fName,
        mName: _mName,
        lName: _lName,
        userName: _username,
        password: _password,
        email: _email,
        phone: _phone,
        gender: _gender,
        passport: _passport,
        dob: _dob,
        bloodGroup:_bloodGroup,
        genotype: _genotype,
        healthHistory: _healthHistory,
        admissionNumber: _admissionNumber,
        genAdmissionNumber: _genAdmissionNumber,
        residentAddress: _residentAddress,
        city: _city,
        state: _state,
        nationality: _nationality,
        stClass: _stClass,
        parentName: _parentName,
        parentTitle: _parentTitle,
        parentPhone: _parentPhone,
        parentEmail: _parentEmail,
        parentAddress: _parentAddress,
        parentPassport: _parentPassport,
        parentOccupation: _parentOccupation,
        passportLink: _passportLink,
        preferredCurrencyId: _preferredCurrencyId,
        boardingStatus: _boardingStatus=='yes',
        deleted: _deleted!='no',
      sessions: _sessions
    );
  }

  @override
  Future<String> generatePickUpId({String studentId, String password}) async{
    // TODO: implement generatePickUpId
    String _pickUpId;
    try {
      await http.post(
          MyStrings.domain + MyStrings.generatePickUpIdUrl + await getApiToken(),
          body: {
            "student_id": studentId,
            "password": password
          }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        //Todo: get api returns here
        _pickUpId = map['return_data'].toString().replaceAll('null', '');
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _pickUpId;
  }
}


