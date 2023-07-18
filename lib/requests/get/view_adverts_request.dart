import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/ad_impression.dart';
import 'package:school_pal/models/advert.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewAdvertsRepository{
  Future<List<Advert>> fetchAdverts({@required String userUniqueId});
  Future<List<Advert>> fetchUserAdverts();
  Future<String> pauseOrCancelAdvert({@required adCampaignId, @required option});
  Future<String> restartAdvert({@required adCampaignId});
}

class ViewAdvertsRequest implements ViewAdvertsRepository{
  List<Advert> _adverts=new List();
  @override
  Future<List<Advert>> fetchAdverts({String userUniqueId}) async {
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewAdvertsUrl+await getApiToken());
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }


      if (map["return_data"]['AdvertCampaignsArray'].length<1) {
        throw ApiException("No Adverts data available");
      }

      _populateAdvertList(map["return_data"], userUniqueId);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _adverts;
  }

  void _populateAdvertList(Map adverts, String userUniqueId){
    _adverts.clear();
    for (var advert in adverts['AdvertCampaignsArray']){
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
              deleted: advert['prefered_currency']['is_deleted'].toString()=='yes',
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
  Future<List<Advert>> fetchUserAdverts() async{
    // TODO: implement fetchUserAdverts
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewUserAdvertsUrl+await getApiToken());
      Map map = json.decode(response.body);
      logPrint(map.toString());


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }


      if (map["return_data"]['advertDetailsArray'].length<1) {
        throw ApiException("No Adverts data available");
      }

      _populateUserAdvertList(map["return_data"]);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _adverts;
  }

  void _populateUserAdvertList(Map adverts){
    _adverts.clear();
    for (var advert in adverts['advertDetailsArray']){
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
            deleted: advert['prefered_currency']['is_deleted'].toString()=='yes',
          ),
          adImpressions: adImpressions,
          deleted:advert['is_deleted'].toString()=='yes'
      ));
    }
  }

  @override
  Future<String> pauseOrCancelAdvert({adCampaignId, option}) async{
    // TODO: implement pauseOrCancelAdvert
    String _message;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.pauseOrCancelAdCampaignUrl+await getApiToken()+'/$adCampaignId/$option');
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
      print(e.toString());
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<String> restartAdvert({adCampaignId}) async{
    // TODO: implement restartAdvert
    String _message;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.restartAdCampaignUrl+await getApiToken()+'/$adCampaignId');
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
      print(e.toString());
      throw SystemError();
    }

    return _message;
  }

}