import 'package:flutter/material.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class RegisterRepository {
  Future<String> registerUser({@required String name, @required String slogan, @required String email,@required String username, @required String password, @required String confirmPassword, @required String contactPhoneNumber,@required String address,@required String town,@required String lga,@required String city,@required String nationality});
  Future<String> uploadVerificationVideo({@required String apiToken, String fileField});
}

class RegisterRequest implements RegisterRepository {
  @override
  Future<String> registerUser({String name, String slogan, String email, String username, String password, String confirmPassword, String contactPhoneNumber, String address, String town, String lga, String city, String nationality}) async {
    // TODO: implement registerUser
    String _registrationMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.registerUrl, body: {
        "name": name,
        "contact_email": email,
        "username": username,
        "password": password,
        "password_confirmation": confirmPassword,
        "contact_phone_number": contactPhoneNumber,
        "address": address,
        "town": town,
        "lga": lga,
        "state": city,
        "nationality": nationality,
        "slogan": slogan
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _registrationMessage=map['success_message'];
        //Todo: get api returns here
      });
    } on SocketException {
      print('Network error');
      throw NetworkError();
    } on FormatException catch (e) {
      logPrint(e.message);
      throw SystemError();
    }

    return _registrationMessage;
  }

  @override
  Future<String> uploadVerificationVideo({String apiToken, String fileField}) async{
    // TODO: implement addVerificationVideo
    print(MyStrings.domain + MyStrings.verificationVideo+apiToken);
    String _successMessage;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(MyStrings.domain + MyStrings.verificationVideo+apiToken));
      request.fields.addAll({
        'mobile_upload': '',
        'ext_from_mob': 'mp4'
      });
      request.files.add(
          await http.MultipartFile.fromPath('file_name[]', fileField)
          /*
           http.MultipartFile(
          'picture',
          File(filename).readAsBytes().asStream(),
          File(filename).lengthSync(),
          filename: filename.split("/").last
      )

      http.MultipartFile.fromBytes(
          'picture',
          File(filename).readAsBytesSync(),
          filename: filename.split("/").last
      )*/
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

}
