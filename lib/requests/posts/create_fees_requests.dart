import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class CreateFeesRepository {
  Future<String> createFeesRecord({@required String title, @required String type, @required String description, @required String termId, @required String sessionId});
  Future<String> updateFeesRecord({@required String recordId, @required String title, @required String type, @required String description, @required String termId, @required String sessionId});
  Future<String> deleteFee({@required String feeId, @required String recordId});
  Future<String> createFees({@required String recordId, @required String title, @required String division, @required String amount, @required String classId});
  Future<String> updateFees({@required String feeId, @required String recordId, @required String title, @required String division, @required String amount, @required String classId});
  Future<String> confirmFeePayment({@required String recordId, @required String feePaymentId});
  Future<String> deactivateDefaultStudent({@required String recordId, @required String studentId});
}

class CreateFeesRequests implements CreateFeesRepository{
  @override
  Future<String> createFeesRecord({@required String title, @required String type, @required String description, @required String termId, @required String sessionId}) async {
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.createParticularFeesRecordUrl+await getApiToken(), body: {
        "title": title,
        "fee_type": type,
        "description": description,
        "session": sessionId,
        "term": termId
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> updateFeesRecord({String recordId, @required String title, @required String type, @required String description, @required String termId, @required String sessionId}) async{
    // TODO: implement createComment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateParticularFeesRecordUrl+await getApiToken()+"/"+recordId, body: {
        "title": title,
        "fee_type": type,
        "description": description,
        "session": sessionId,
        "term": termId
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> deleteFee({String feeId, String recordId}) async{
    // TODO: implement deleteFee
    print(MyStrings.domain + MyStrings.deleteParticularFeesUrl+await getApiToken()+"/"+recordId);
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.deleteParticularFeesUrl+await getApiToken()+"/"+recordId, body: {
        "fee_id[]": feeId,
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> createFees({String recordId, String title, String division, String amount, String classId}) async{
    // TODO: implement createFees
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.createParticularFeesUrl+await getApiToken()+"/$recordId", body: {
        "title[]": title,
        "division[]": division,
        "amount[]": amount,
        "class_tb_id[]": classId,
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> updateFees({String feeId, String recordId, String title, String division, String amount, String classId}) async{
    // TODO: implement updateFees
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateParticularFeesUrl+await getApiToken()+"/$recordId", body: {
        "title[]": title,
        "division[]": division,
        "amount[]": amount,
        "class_tb_id[]": classId,
        'fee_id[]':feeId
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> confirmFeePayment({String recordId, String feePaymentId}) async{
    // TODO: implement confirmFeePayment
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.confirmFeesPaymentsUrl+await getApiToken()+"/$recordId", body: {
        'payment_confirmation_id[]':feePaymentId
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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
  Future<String> deactivateDefaultStudent({String recordId, String studentId}) async{
    // TODO: implement deactivateDefaultStudent
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.deactivateDefaultStudentUrl+await getApiToken()+"/$recordId", body: {
        'student_ids[]':studentId
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

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


