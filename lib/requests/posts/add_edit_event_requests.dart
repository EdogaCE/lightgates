import 'package:flutter/material.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class EventRepository {
  Future<String> addSchoolEvent(
      {@required String title,
      @required String description,
      @required String startDate,
      @required String endDate});
  Future<String> updateSchoolEvent(
      {@required String id,
      @required String title,
      @required String description,
      @required String startDate,
      @required String endDate});
}

class EventRequests implements EventRepository {
  String _successMessage;
  @override
  Future<String> addSchoolEvent(
      {String title,
      String description,
      String startDate,
      String endDate}) async {
    // TODO: implement addSchoolEvent
    try {
      await http.post(
          MyStrings.domain + MyStrings.addSchoolEventsUrl + await getApiToken(),
          body: {
            "title_of_event": title,
            "start_date_of_event": startDate,
            "end_date_of_event": endDate,
            "description": description
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
  Future<String> updateSchoolEvent(
      {String id,
      String title,
      String description,
      String startDate,
      String endDate}) async {
    // TODO: implement updateSchoolEvent
    try {
      await http.post(
          MyStrings.domain + MyStrings.updateSchoolEventsUrl + await getApiToken()+"/"+id,
          body: {
            "title_of_event": title,
            "start_date_of_event": startDate,
            "end_date_of_event": endDate,
            "description": description
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
