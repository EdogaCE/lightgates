import 'package:meta/meta.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class CreateFaqNewsRepository {
  Future<String> addFaq({@required String question, @required String answer});
  Future<String> updateFaq(
      {@required String id,
      @required String question,
      @required String answer});
  Future<String> deleteFaq({@required String id});
  Future<String> addNews(
      {@required String title,
      @required String content,
      @required String tags});
  Future<String> updateNews(
      {@required String id,
      @required String title,
      @required String content,
      @required String tags});
  Future<String> deleteNews({@required String id});
  Future<String> addNewsComment(
      {@required String newsId,
        @required String userId,
        @required String comment});
  Future<String> updateNewsComment(
      {@required String commentId,
        @required String newsId,
        @required String userId,
        @required String comment});
  Future<String> deleteNewsComment(
      {@required String commentId});
}

class CreateFaqNewsRequests implements CreateFaqNewsRepository {
  @override
  Future<String> addFaq({String question, String answer}) async {
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.addFAQUrl + await getApiToken(),
          body: {"question": question, "answer": answer}).then((response) {
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
  Future<String> updateFaq({String id, String question, String answer}) async {
    // TODO: implement createComment
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateFAQUrl +
              await getApiToken() +
              '/' +
              id,
          body: {"question": question, "answer": answer}).then((response) {
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
  Future<String> addNews({String title, String content, String tags}) async {
    // TODO: implement addNews
    String _message;
    print(tags);
    try {
      await http.post(
          MyStrings.domain + MyStrings.addNewsUrl + await getApiToken(),
          body: {
            "title": title,
            "content": content,
            "tags": tags
          }).then((response) {
        print("Response status: ${response.statusCode}");
        logPrint("Response body: ${response.body}");

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
  Future<String> updateNews(
      {String id, String title, String content, String tags}) async {
    // TODO: implement updateNews
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.updateNewsUrl +
              await getApiToken() +
              '/' +
              id,
          body: {
            "title": title,
            "content": content,
            "tags": tags
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
  Future<String> deleteFaq({String id}) async {
    // TODO: implement deleteFaq
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.deleteFAQUrl +
              await getApiToken() ,
          body: {
            "faqs_id[]": id
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
  Future<String> deleteNews({String id}) async {
    // TODO: implement deleteNews
    String _message;
    try {
      await http.post(
          MyStrings.domain +
              MyStrings.deleteNewsUrl +
              await getApiToken() +
              '/' +
              id,
          body: {}).then((response) {
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
  Future<String> addNewsComment({String newsId, String userId, String comment}) async{
    // TODO: implement addNewsComment
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.addNewsCommentUrl + await getApiToken(),
          body: {
            "blog_id": newsId,
            "user_id": userId,
            "content": comment
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
  Future<String> deleteNewsComment({String commentId}) async{
    // TODO: implement deleteNewsComment
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.deleteNewsCommentUrl + await getApiToken()+'/$commentId',
          body: {
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
  Future<String> updateNewsComment({String commentId, String newsId, String userId, String comment}) async{
    // TODO: implement updateNewsComment
    String _message;
    try {
      await http.post(
          MyStrings.domain + MyStrings.updateNewsCommentUrl + await getApiToken()+'/$commentId',
          body: {
            "blog_id": newsId,
            "user_id": userId,
            "content": comment
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
