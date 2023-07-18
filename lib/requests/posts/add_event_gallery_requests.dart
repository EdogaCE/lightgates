import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class AddEventGalleryRepository {
  Future<String> addGallery({@required String title, @required String sessionId, @required String description, @required List<String> images, @required List<String> videos, @required String date});
  Future<String> updateGallery({@required String galleryId, @required String title, @required String sessionId, @required String description, @required List<String> images, @required List<String> imagesToDelete, @required List<String> videos, @required String date, });
  Future<String> addGalleryImage({@required String galleryId, @required String fileField, @required String fileType});
}

class  AddEventGalleryRequests implements  AddEventGalleryRepository{
  @override
  Future<String> addGallery({String title, String sessionId, String description, List<String> images, List<String> videos, String date}) async {
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.addSchoolGalleryUrl+ await getApiToken(), body: {
        "event_title": title,
        "session_i": sessionId,
        "description": description,
        "mobile_upload_file_name[]": images.join(','),
        "video[]": videos.join(', '),
        "event_date": date
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

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
  Future<String> addGalleryImage({String galleryId, String fileField, String fileType}) async {
    // TODO: implement addGalleryImage
    String _filename;
    try {
      await http.post((galleryId.isEmpty)
          ?MyStrings.domain + MyStrings.addSchoolGalleryUrl+ await getApiToken()
          :MyStrings.domain + MyStrings.updateGalleryUrl+ await getApiToken()+'/'+galleryId, body: {
        "mobile_upload": '',
        "file_field[]": fileField,
        "file_type": fileType
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }
        _filename=map['return_data'][0];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }
    return _filename;
  }

  @override
  Future<String> updateGallery({String galleryId, String title, String sessionId, String description, List<String> images, List<String> imagesToDelete, List<String> videos, String date}) async{
    // TODO: implement updateGallery
    String _message;
    try {
      await http.post(MyStrings.domain + MyStrings.updateGalleryUrl+ await getApiToken()+'/'+galleryId, body: {
        "event_title": title,
        "session_i": sessionId,
        "description": description,
        "mobile_upload_file_name[]": images.join(','),
        "video[]": videos.join(', '),
        "event_date": date,
        "files_to_delete": imagesToDelete.join(',')
      }).then((response) {
        logPrint("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

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
      print(e.toString());
      throw SystemError();
    }
    return _message;
  }
}


