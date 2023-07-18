import 'package:meta/meta.dart';
import 'package:school_pal/models/ad_impression.dart';
import 'package:school_pal/models/advert.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class UpdateAdvertRepository {
  Future<List<Advert>> captureAdImpression({@required String userUniqueId, @required String adUniqueId, @required String impression});

  Future<String> createAdvertCampaign({@required String budget, @required String startDate, @required String endDate, @required String driveTrafficTo, @required String caption, @required String webAppUrl, @required String webUrl, @required String appUrl, @required String whatsAppNo, @required String countryCode, @required List<String> images});

  Future<String> updateAdvertCampaign({@required String addCampaignId, @required String budget, @required String startDate, @required String endDate, @required String driveTrafficTo, @required String caption, @required String webAppUrl, @required String webUrl, @required String appUrl, @required String whatsAppNo, @required String countryCode, @required List<String> images});

  Future<String> validateAdvert({@required String budget, @required String startDate, @required String endDate});
}

class UpdateAdvertRequests implements UpdateAdvertRepository{
  List<Advert> _adverts=new List();
  @override
  Future<List<Advert>> captureAdImpression({String userUniqueId, String adUniqueId, String impression}) async {

    try {
      await http.post(MyStrings.domain + MyStrings.captureAdImpressionUrl+ await getApiToken(), body: {
        "advert_unique_id": adUniqueId,
        "user_id_of_reacter": userUniqueId,
        "type_of_impression": impression,
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _populateAdvertList(map["return_data"], userUniqueId);

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _adverts;
  }

  void _populateAdvertList(List adverts, String userUniqueId){
    _adverts.clear();
    for (var advert in adverts){
      //if(advert['ads_impressions'].where((element) => element['user_id_of_reacter']==userUniqueId).toList().isEmpty){
        List<AdImpression> adImpressions=List();
        for(var impression in advert['ads_impressions']){
          AdImpression(
              id: impression['id'].toString(),
              uniqueId: impression['unique_id'].toString(),
              adUniqueId: impression['advert_unique_id'].toString(),
              reactorUniqueId: impression['user_id_of_reacter'].toString(),
              impression: impression['type_of_impression'].toString(),
              amountCharged: impression['amount_charged'].toString(),
              chargeStatus: impression['charge_status'].toString(),
              dateCreated: impression['date_created'].toString(),
              deleted: impression['is_deleted'].toString()=='yes'
          );
        }
        _adverts.add(Advert(
            id: advert['id'].toString(),
            uniqueId: advert['unique_id'].toString(),
            userUniqueId: advert['user_unique_id']??'',
            title: advert['title_of_campaign']??'',
            budget:advert['budget']??'',
            startDate:advert['start_date']??'',
            endDate:advert['end_date']??'',
            driveTrafficTo:advert['drive_traffic_to']??'',
            whatsAppNo:advert['whats_app_no']??'',
            websiteAppUrl:advert['website_app_url']??'',
            primaryText:advert['primary_text']??'',
            description:advert['description']??'',
            image:advert['image_name']??'',
            imageUrl: advert['image_link']??'',
            status:advert['status']??'',
            amountSpent:advert['amount_spent']??'',
            totalReach:advert['total_reach']??0,
            totalView:advert['total_views']??0,
            totalClick:advert['total_click']??0,
            preferredCurrency: Currency(
              id: advert['prefered_currency']['id'].toString(),
              uniqueId: advert['prefered_currency']['unique_id'].toString(),
              baseCurrency: advert['prefered_currency']['base_currency'].toString(),
              secondCurrency: advert['prefered_currency']['second_currency'].toString(),
              rateOfConversion: advert['prefered_currency']['rate_of_conversion'].toString(),
              expression: advert['prefered_currency']['expression'].toString(),
              currencyName: advert['prefered_currency']['currency_name'].toString(),
              countryName: advert['prefered_currency']['country_name'].toString(),
              countryAbr: advert['prefered_currency']['country_abbr'].toString(),
              deleted: advert['prefered_currency']['is_deleted'].toString()!='no',
            ),
            adImpressions: adImpressions,
            deleted:advert['is_deleted'].toString()=='yes'
        ));
      /*}else{
        print('Advert already seen by this user');
      }*/

    }
  }

  @override
  Future<String> createAdvertCampaign({String title, String budget, String startDate, String endDate, String driveTrafficTo, String caption,String webAppUrl, String webUrl, String appUrl, String whatsAppNo, String countryCode, List<String> images}) async {
    print(MyStrings.domain + MyStrings.createAdCampaignUrl+await getApiToken());
    String _successMessage;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(MyStrings.domain + MyStrings.createAdCampaignUrl+await getApiToken()));
      request.fields.addAll({
        'budget': budget,
        'start_date': startDate,
        'end_date': endDate,
        'drive_traffic_to': driveTrafficTo,
        'description': caption,
        'whatsapp':whatsAppNo,
        'country_code': countryCode,
        'website_app_url': webAppUrl,
        'app_url': appUrl,
        'website_url': webAppUrl,
        'primary_text': ''
      });
      if(images.first.isNotEmpty){
        request.files.add(
            await http.MultipartFile.fromPath('image_name[]', images.first)
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
      }
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

  @override
  Future<String> updateAdvertCampaign({String addCampaignId, String title, String budget, String startDate, String endDate, String driveTrafficTo, String caption, String webAppUrl, String webUrl, String appUrl, String whatsAppNo, String countryCode, List<String> images}) async{
    // TODO: implement updateAdvertCampaign
    print(MyStrings.domain + MyStrings.updateAdCampaignUrl+await getApiToken()+'/$addCampaignId');
    String _successMessage;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(MyStrings.domain + MyStrings.updateAdCampaignUrl+await getApiToken()+'/$addCampaignId'));
      request.fields.addAll({
      'budget': budget,
      'start_date': startDate,
      'end_date': endDate,
      'drive_traffic_to': driveTrafficTo,
      'description': caption,
      'whatsapp':whatsAppNo,
      'country_code': countryCode,
      'website_app_url': webAppUrl,
      'app_url': appUrl,
      'website_url': webAppUrl,
      'primary_text': ''
      });
      if(images.first.isNotEmpty){
        request.files.add(
            await http.MultipartFile.fromPath('image_name[]', images.first)
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
      }

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

  @override
  Future<String> validateAdvert({String budget, String startDate, String endDate}) async{
    // TODO: implement validateAdvert
    String message;
    try {
      await http.post(MyStrings.domain + MyStrings.adValidatorUrl+await getApiToken(), body: {
        "budget": budget,
        "start_date": startDate,
        "end_date": endDate
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        message=map['return_data']['estimated_reach'];
      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return message;
  }

}


