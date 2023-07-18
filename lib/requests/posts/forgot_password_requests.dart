import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class ForgotPasswordRepository {
  Future<Map<String, String>> forgotPassword({@required String email});
  Future<Map<String, String>> verifyOpt({@required String otp});
  Future<Map<String, String>> resetPassword({@required String password, @required String confirmPassword, @required String otp});
}

class ForgotPasswordRequests implements ForgotPasswordRepository{
  @override
  Future<Map<String, String>> forgotPassword({String email}) async{
    // TODO: implement forgotPassword
    Map<String, String> otpMessage=Map();
    try {
      await http.post(MyStrings.domain + MyStrings.forgotPasswordUrl, body: {
        'email': email
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        otpMessage['message']=map['success_message'];
        otpMessage['otp']=map['return_data']['token'].toString();

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return otpMessage;
  }

  @override
  Future<Map<String, String>> verifyOpt({String otp}) async{
    // TODO: implement verifyOpt
    Map<String, String> otpMessage=Map();
    try {
      await http.post(MyStrings.domain + MyStrings.verifyOptUrl, body: {
        'reset_token': otp
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        otpMessage['message']=map['success_message'];
        otpMessage['otp']=map['return_data']['token'].toString();

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return otpMessage;
  }

  @override
  Future<Map<String, String>> resetPassword({String password, String confirmPassword, String otp}) async{
    // TODO: implement resetPassword
    Map<String, String> otpMessage=Map();
    try {
      await http.post(MyStrings.domain + MyStrings.resetPasswordUrl, body: {
        'password': password,
        'confirm_password': confirmPassword,
        'reset_token': otp
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        otpMessage['message']=map['success_message'];

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return otpMessage;
  }

}