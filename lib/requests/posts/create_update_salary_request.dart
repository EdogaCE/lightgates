import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class CreateSalaryRepository {
  Future<String> createSalaryRecord(
      {@required String paymentFrequency,
      @required String sessionId,
      @required String termId,
      @required String startDate,
      @required String endDate,
      @required String title,
      @required String description});
  Future<String> updateSalaryRecord(
      {@required String recordId,
      @required String paymentFrequency,
      @required String sessionId,
      @required String termId,
      @required String startDate,
      @required String endDate,
      @required String title,
      @required String description});
  Future<String> updateTeacherSalaryPaymentRecord(
      {@required String paymentId, @required String paymentStatus});
  Future<String> payTeachersSalary(
      {@required String paymentId,
        @required List<String> idForPaymentsToBeUpdated,
        @required List<String> salary,
        @required List<String> bonus,
        @required List<String> paymentStatus});
}

class CreateSalaryRequests implements CreateSalaryRepository {
  @override
  Future<String> createSalaryRecord(
      {String paymentFrequency,
      String sessionId,
      String termId,
      String startDate,
      String endDate,
      String title,
      String description}) async {
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.createParticularSalaryRecordUrl +
              await getApiToken(),
          body: {
            "payment_frequency": paymentFrequency,
            "session_i": sessionId,
            "term_id": termId,
            "start_date": startDate,
            "end_date": endDate,
            "payment_title": title,
            "description": description
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
  Future<String> updateSalaryRecord(
      {String recordId,
      String paymentFrequency,
      String sessionId,
      String termId,
      String startDate,
      String endDate,
      String title,
      String description}) async {
    // TODO: implement createComment
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateParticularSalaryRecordUrl +
              await getApiToken() +
              "/" +
              recordId,
          body: {
            "payment_frequency": paymentFrequency,
            "session_i": sessionId,
            "term_id": termId,
            "start_date": startDate,
            "end_date": endDate,
            "payment_title": title,
            "description": description
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
  Future<String> updateTeacherSalaryPaymentRecord(
      {String paymentId, String paymentStatus}) async {
    // TODO: implement updateTeacherSalaryPaymentRecord
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateTeacherSalaryPaymentRecordUrl +
              await getApiToken(),
          body: {
            "id_for_payments_to_be_updated[]": paymentId,
            "payment_status[]": paymentStatus
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
  Future<String> payTeachersSalary({String paymentId, List<String> idForPaymentsToBeUpdated, List<String> salary, List<String> bonus, List<String> paymentStatus}) async{
    // TODO: implement paySalary
    String _message;
    print(MyStrings.domain + MyStrings.payTeachersSalaryWithFlutterWaveUrl + '${await getApiToken()}/$paymentId');
    print(idForPaymentsToBeUpdated.join(':'));
    print(bonus.join(':'));
    print(paymentStatus.join(':'));
    try {
      await http.post(
          MyStrings.domain + MyStrings.payTeachersSalaryWithFlutterWaveUrl + '${await getApiToken()}/$paymentId',
          body: {
            "id_for_payments_to_be_updated": idForPaymentsToBeUpdated.join(':'),
            "salary": salary.join(':'),
            "bonus": bonus.join(':'),
            "payment_status": paymentStatus.join(':')
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

}
