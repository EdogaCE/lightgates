import 'package:flutter/material.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class WalletRepository {
  Future<String> createFlutterWaveSubAccount(
      {@required String accountBank,
      @required String accountNumber,
      @required String businessName,
      @required String businessEmail,
      @required String businessAddress,
      @required String businessContact1,
      @required String businessContact2});
  Future<String> createPayStackSubAccount(
      {@required String accountBank,
        @required String accountNumber,
        @required String businessName,
        @required String percentageCharge});
}

class WalletRequests implements WalletRepository {
  @override
  Future<String> createFlutterWaveSubAccount(
      {String accountBank,
      String accountNumber,
      String businessName,
      String businessEmail,
      String businessAddress,
      String businessContact1,
      String businessContact2}) async {
    // TODO: implement createFlutterWaveSubAccount
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.addFlutterWaveAccountUrl+await getApiToken(), body: {
        "account_bank": accountBank,
        "account_number": accountNumber,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_contact": businessAddress,
        "business_contact_mobile": businessContact1,
        "business_mobile": businessContact2
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _successMessage = map['success_message'];
        //Todo: get api returns here
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
  Future<String> createPayStackSubAccount({String accountBank, String accountNumber, String businessName, String percentageCharge}) async{
    // TODO: implement createPayStackSubAccount
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.addPayStackAccountUrl+await getApiToken(), body: {
        "settlement_bank": accountBank,
        "account_number": accountNumber,
        "business_name": businessName,
        "percentage_charge": percentageCharge
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _successMessage = map['success_message'];
        //Todo: get api returns here
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
