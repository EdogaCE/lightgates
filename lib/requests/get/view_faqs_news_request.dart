import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/faqs.dart';
import 'package:school_pal/models/news.dart';
import 'package:school_pal/models/news_comment.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewFAQsNewsRepository{
  Future<List<FAQs>> fetchFAQs({bool localDb});
  Future<List<News>> fetchNews({bool localDb});
  Future<News> fetchSingleNews(String newsId);
}

class ViewFAQsNewsRequest implements ViewFAQsNewsRepository{
  List<FAQs> _faqs=new List();
  List<News> _news=new List();
  @override
  Future<List<FAQs>> fetchFAQs({bool localDb}) async {
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'faqs');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http.get(MyStrings.domain+MyStrings.viewFAQUrl+await getApiToken());
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _faqs.clear();
        if (map["return_data"]['all_faqs_details_array'].isEmpty) {
          throw ApiException("No FAQs available, Please do well to add Some");
        }

        if(await databaseHandlerRepository.getData(title: 'faqs')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'faqs', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'faqs', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }


      }

      if(map.isNotEmpty){
        _populateFAQLists(map["return_data"]["all_faqs_details_array"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _faqs;
  }

  void _populateFAQLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _faqs.add(new FAQs(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          schoolId: result[i]["school_id"].toString(),
          question: result[i]["question"].toString(),
          answer: result[i]["answer"].toString(),
          date: "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}"));
    }
  }

  @override
  Future<List<News>> fetchNews({bool localDb}) async {
    // TODO: implement fetchNews
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'news');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{

        final response = await http.get(MyStrings.domain+MyStrings.viewNewsUrl+await getApiToken());
        map = json.decode(response.body);
        print(map);


        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _news.clear();
        if (map["return_data"].length<1) {
          throw ApiException("No News available, Please do well to add Some");
        }

        if(await databaseHandlerRepository.getData(title: 'news')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'news', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'news', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateNewsLists(map["return_data"]["all_blogs"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _news;
  }

  void _populateNewsLists(List result) {
    for (int i = 0; i < result.length; i++) {
      List<NewsComment> _comments=List();
      for(int j = 0; j < result[i]["blog_comments"].length; j++){
        //_comments.add(result[i]["blog_comments"][j]);
      }
      _news.add(new News(
          id: result[i]["id"].toString(),
          uniqueId: result[i]["unique_id"].toString(),
          schoolId: result[i]["school_id"].toString(),
          title: result[i]["title"].toString(),
          content: result[i]["content"].toString(),
          views: result[i]["views"].toString(),
          tags: result[i]["tags"].toString(),
          date: "${result[i]["created_at"].toString()},${result[i]["updated_at"].toString()}",
        comments: _comments
      ));
    }
  }

  @override
  Future<News> fetchSingleNews(String newsId) async{
    // TODO: implement fetchSingleNews
    String _id, _uniqueId, _schoolId, _title, _content, _views, _tags, _date;
    List<NewsComment> _comments;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewSingleNewsUrl+await getApiToken()+'/$newsId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      Map details = map['return_data']['blog_post'];
      _id= details["id"].toString();
      _uniqueId= details["unique_id"].toString();
      _schoolId= details["school_id"].toString();
      _title= details["title"].toString();
      _content=details["content"].toString();
      _views= details["views"].toString();
      _tags= ["tags"].toString();
      _date= '${details["created_at"].toString()}, ${details["updated_at"].toString()}';
      for(int j = 0; j < details["blog_comments"].length; j++){
        //_comments.add(details["blog_comments"][j]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return News(
      id: _id,
      uniqueId: _uniqueId,
      schoolId: _schoolId,
      title: _title,
      content: _content,
      views: _views,
      tags: _tags,
      comments: _comments,
      date: _date
    );
  }

}