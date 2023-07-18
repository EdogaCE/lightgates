import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class VerifyRegistrationRepository{
  Future<String> resendVerificationEmail({String email});
  Future<String> updateFirstTimeLogin();
  Future<String> updateFirstTimeSetupPage({String page});
}

class VerifyRegistrationRequest implements VerifyRegistrationRepository{
  String _message;
  @override
  Future<String> resendVerificationEmail({String email}) async{
    // TODO: implement fetchWalletFoundHistory
    print(MyStrings.domain+MyStrings.resentVerificationEmailUrl+email);
    try {
      final response = await http.get(MyStrings.domain+MyStrings.resentVerificationEmailUrl+email);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _message = map['success_message'];

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> updateFirstTimeLogin() async{
    // TODO: implement updateFirstTimeLogin
    try {
      final response = await http.get(MyStrings.domain+MyStrings.updateFirstTimeLoginUrl+await getApiToken());
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _message = map['success_message'];

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> updateFirstTimeSetupPage({String page}) async{
    // TODO: implement updateFirstTimeSetupPage
    try {
      final response = await http.get(MyStrings.domain+MyStrings.updateFirstTimeSetupPageUrl+'${await getApiToken()}/$page');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _message = map['success_message'];

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _message;
  }

}
