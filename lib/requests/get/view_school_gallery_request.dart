import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/gallery.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSchoolGalleryRepository{
  Future<List<Gallery>> fetchGallery(String apiToken);
  Future<String> deleteGallery(String galleryId);
}

class ViewSchoolGalleryRequest implements ViewSchoolGalleryRepository{
  List<Gallery> _gallery=new List();
  @override
  Future<List<Gallery>> fetchGallery(String apiToken) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewSchoolGalleryUrl+apiToken);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _gallery.clear();
      if (map["return_data"]['all_school_gallery'].length<1) {
        throw ApiException("No gallery available, Please do well to add Some");
      }
      _populateLists(map["return_data"]);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _gallery;
  }

  void _populateLists(Map result) {
    for (int i = 0; i < result['all_school_gallery'].length; i++) {
      _gallery.add(new Gallery(
          id: result['all_school_gallery'][i]["id"].toString(),
          uniqueId: result['all_school_gallery'][i]["unique_id"].toString(),
          schoolId: result['all_school_gallery'][i]["school_id"].toString(),
          sessionId: result['all_school_gallery'][i]["session_i"].toString(),
          title: result['all_school_gallery'][i]["event_title"].toString(),
          description: result['all_school_gallery'][i]["description"].toString(),
          images: result['all_school_gallery'][i]["image"].toString(),
          videos: result['all_school_gallery'][i]["video"].toString(),
          date: result['all_school_gallery'][i]["event_date"].toString(),
          deleted: result['all_school_gallery'][i]["is_deleted"].toString()=='yes',
      sessions: new Sessions(
          id: result['session_details_array'][i]["id"].toString(),
          uniqueId: result['session_details_array'][i]["unique_id"].toString(),
          sessionDate: result['session_details_array'][i]["session_date"].toString(),
          startAndEndDate:
          "${result['session_details_array'][i]["session_start_date"].toString()},${result['session_details_array'][i]["session_end_date"].toString()}",
          status: result['session_details_array'][i]["status"].toString(),
          admissionNumberPrefix: result['session_details_array'][i]["admission_no_prefix"].toString()
      ),
        imageUrl: result['base_url_school_galleries_image'].toString()
      ));
    }
  }

  @override
  Future<String> deleteGallery(String galleryId) async{
    // TODO: implement deleteGallery
    String rtnData;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.deleteSchoolGalleryUrl+await getApiToken()+'/'+galleryId);
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      rtnData=map['success_message'];
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

}