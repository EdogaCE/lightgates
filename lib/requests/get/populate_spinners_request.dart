import 'package:http/http.dart' as http;
import 'package:school_pal/models/top_up.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

Future<List<TopUp>> getBillCategoriesSpinnerValue(String apiToken)async{
  List<TopUp> _values=List();
  try {
    final response = await http.get(MyStrings.domain + MyStrings.viewBillPaymentCategoryUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Class Category available in Our Server, Please do well to add Some");
    }

    for (var category in map['return_data']['billCategories']) {
      _values.add(TopUp(
        id: category['id'].toString(),
        uniqueId: category['unique_id']??'',
        billerCode: category['biller_code']??'',
        name: category['name']??'',
        defaultCommission: category['default_commission']??'',
        country: category['country']??'',
        isAirtime: category['is_airtime'].toString()=='1',
        billerName: category['biller_name']??'',
        itemCode: category['item_code']??'',
        shortName: category['short_name']??'',
        fee: category['fee']??'',
        commissionOnFee: category['commission_on_fee']??'',
        labelName: category['label_name']??'',
        amount: category['amount']??'',
        description: category['description']??''
      ));
    }

  } on SocketException{
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return _values;
}

Future<List<List<String>>> getCategoriesSpinnerValue(String apiToken)async{
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewClassCategoriesUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Class Category available in Our Server, Please do well to add Some");
    }

    for (int i = 0; i < map["return_data"].length; i++) {
      if(!_values.contains(map["return_data"][i]["category"].toString())){
        _values.add(map["return_data"][i]["category"].toString());
        _ids.add(map["return_data"][i]["id"].toString());
      }
    }

  } on SocketException{
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}


Future<List<List<String>>> getLevelsSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewClassLevelsUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Class Level available in Our Server, Please do well to add Some");
    }

    Map<String, String> levelInWord={'100':'First Level', '200':'Second Level', '300':'Third Level',
      '400':'Fourth Level', '500':'Fifth Level', '600':'Sixth Level', '700':'Seventh Level',
      '800':'Eight Level', '900':'Ninth Level'};

    for (int i = 0; i < map["return_data"].length; i++) {
      if(!_values.contains(map["return_data"][i]["level"].toString())){
        _values.add(levelInWord[map["return_data"][i]["level"].toString()]??'Unknown level');
        _ids.add(map["return_data"][i]["id"].toString());
      }
    }

  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}


Future<List<List<String>>> getLabelsSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewClassLabelsUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Class Label available in Our Server, Please do well to add Some");
    }

    for (int i = 0; i < map["return_data"].length; i++) {
      if(!_values.contains(map["return_data"][i]["label"].toString())){
        _values.add(map["return_data"][i]["label"].toString());
        _ids.add(map["return_data"][i]["id"].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getSessionSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  List<String> _activeSession=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewSchoolSessionsUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"]['session_details'].length < 1) {
      throw ApiException(
          "No Session available in Our Server, Please do well to add Some");
    }

    _activeSession.addAll([map['active_session']['id'].toString(), map['active_session']['session_date'].toString()]);
    for (int i = 0; i < map["return_data"]['session_details'].length; i++) {
      if(!_values.contains(map["return_data"]['session_details'][i]["session_date"].toString())){
        _values.add(map["return_data"]['session_details'][i]["session_date"].toString());
        _ids.add(map["return_data"]['session_details'][i]["id"].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids, _activeSession];
}

Future<List<List<String>>> getTermSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  List<String> _activeTerm=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewSchoolTermUrl + apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"]['term_details'].length < 1) {
      throw ApiException(
          "No Term available in Our Server, Please do well to add Some");
    }

    _activeTerm.addAll([map['active_term']['id'].toString(), map['active_term']['term'].toString()]);
    for (int i = 0; i < map["return_data"]['term_details'].length; i++) {
      if(!_values.contains(map["return_data"]['term_details'][i]["term"].toString())){
        _values.add(map["return_data"]['term_details'][i]["term"].toString());
        _ids.add(map["return_data"]['term_details'][i]["id"].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids, _activeTerm];
}

Future<List<List<String>>> getSchoolsSpinnerValue() async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewAllSchoolUrl);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"]['schools'].length < 1) {
      throw ApiException(
          "No School available in Our Server");
    }

    for (int i = 0; i < map["return_data"]['schools'].length; i++) {
      if(!_values.contains(map["return_data"]['schools'][i]["name"].toString())){
        _values.add(map["return_data"]['schools'][i]["name"].toString());
        _ids.add(map["return_data"]['schools'][i]["id"].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getClassesSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewClassesUrl+apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"]['all_class_with_details'].length < 1) {
      throw ApiException(
          "No Class available in Our Server, Please do well to add Some");
    }

    for (int i = 0; i < map["return_data"]['all_class_with_details'].length; i++) {
      if(!_values.contains('${map["return_data"]['all_class_with_details'][i]["class_label_details"]['label'].toString()} ${map["return_data"]['all_class_with_details'][i]["class_category_details"]['category'].toString()}')){
        _values.add('${map["return_data"]['all_class_with_details'][i]["class_label_details"]['label'].toString()} ${map["return_data"]['all_class_with_details'][i]["class_category_details"]['category'].toString()}');
        _ids.add(map["return_data"]['all_class_with_details'][i]["class_details_array"]['id'].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getSubjectsSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain+MyStrings.viewSubjectsUrl+apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Subject available in Our Server, Please do well to add Some");
    }

    for (int i = 0; i < map["return_data"].length; i++) {
      if(!_values.contains(map["return_data"][i]['title'].toString())){
        _values.add(map["return_data"][i]['title'].toString());
        _ids.add(map["return_data"][i]['id'].toString());
      }

    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getCurrenciesSpinnerValue(String apiToken) async {
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain+MyStrings.viewAllCurrenciesUrl+apiToken);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"]['currency_rate_details'].length < 1) {
      throw ApiException(
          "No Currency available in Our Server");
    }

    List<String> currencyArray = ['BIF', 'CAD', 'CDF', 'CVE', 'EUR', 'GBP', 'GHS', 'GMD', 'GNF', 'KES', 'LRD', 'MWK', 'MZN',
      'NGN', 'RWF', 'SLL', 'STD', 'TZS', 'UGX', 'USD', 'XAF', 'XOF', 'ZMK', 'ZMW', 'ZWD', 'ZAR'];
    for (int i = 0; i < map["return_data"]['currency_rate_details'].length; i++) {
      if(currencyArray.contains(map["return_data"]['currency_rate_details'][i]['second_currency'].toString())
      && !_values.contains('${map["return_data"]['currency_rate_details'][i]['currency_name'].toString().replaceAll('null', 'Unkonwn')} (${map["return_data"]['currency_rate_details'][i]['second_currency'].toString()})')){
        _values.add('${map["return_data"]['currency_rate_details'][i]['currency_name'].toString().replaceAll('null', 'Unkonwn')} (${map["return_data"]['currency_rate_details'][i]['second_currency'].toString()})');
        _ids.add(map["return_data"]['currency_rate_details'][i]['id'].toString());
      }
    }


  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getPayStackBankCodesSpinnerValue()async{
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewPayStackBankCodesUrl);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Bank Codes available in Our Server");
    }

    for (var currency in map["return_data"].keys) {
      for (var bank in map["return_data"][currency]) {
        if(!_values.contains('${bank["name"].toString()}($currency)')){
          _values.add('${bank["name"].toString()}($currency)');
          _ids.add(bank["code"].toString());
        }
      }
    }

  } on SocketException{
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getFlutterWaveBankCodesSpinnerValue()async{
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http
        .get(MyStrings.domain + MyStrings.viewFlutterWaveBankCodesUrl);
    Map map = json.decode(response.body);
    print(map);

    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    _values.clear();
    _ids.clear();
    if (map["return_data"].length < 1) {
      throw ApiException(
          "No Bank Codes available in Our Server");
    }

   /* for (var currency in map["return_data"].keys) {
      for (var bank in map["return_data"][currency]) {
        _values.add('${bank["Name"].toString()}($currency)');
        _ids.add(bank["Code"].toString());
      }
    }*/
   for(var bank in map["return_data"]['flutterWaveBankCodes']){
     if(!_values.contains('${bank["bank_name"].toString()}(${bank["country"].toString()})')){
       _values.add('${bank["bank_name"].toString()}(${bank["country"].toString()})');
       _ids.add(bank["bank_codes"].toString());
     }

   }

  } on SocketException{
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getFormTeacherClassesSpinnerValue(
    String apiToken, String teacherId) async {
  // TODO: implement fetchTeacherProfile
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http.get(MyStrings.domain +
        MyStrings.viewTeacherProfileUrl + apiToken + "/" + teacherId);
    Map map = json.decode(response.body);
    print(map);

    _values.clear();
    _ids.clear();
    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }
    Map teacherDetails = map['return_data']['teacher_details'];
    try{
      if (teacherDetails['formTeacherDetailsArray'].isNotEmpty) {
        for (var clas in teacherDetails['formTeacherDetailsArray']) {
          if(!_ids.contains(clas['class_id'].toString())
              && !_values.contains('${clas['class_label']['label'].toString()} ${clas['class_category']['category'].toString()}')){
            _values.add('${clas['class_label']['label'].toString()} ${clas['class_category']['category'].toString()}');
            _ids.add(clas['class_id'].toString());
          }
        }
      }
    }on NoSuchMethodError{}

  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getTeacherClassesSpinnerValue(
    String apiToken, String teacherId) async {
  // TODO: implement fetchTeacherProfile
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http.get(MyStrings.domain +
        MyStrings.viewTeacherProfileUrl + apiToken + "/" + teacherId);
    Map map = json.decode(response.body);
    print(map);

    _values.clear();
    _ids.clear();
    if (map["status"].toString() != 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    List teacherClass = map['return_data']["all_class_details_array"];
    try{
      if (teacherClass.isNotEmpty) {
        for (var clas in teacherClass) {
          if(!_ids.contains(clas["class_details_array"]["id"].toString())
          && !_values.contains('${clas["class_label_details"]["label"].toString()} ${clas["class_category_details"]["category"].toString().toString()}')){
            _values.add('${clas["class_label_details"]["label"].toString()} ${clas["class_category_details"]["category"].toString().toString()}');
            _ids.add(clas["class_details_array"]["id"].toString());
          }
        }
      }
    }on NoSuchMethodError{}

  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

Future<List<List<String>>> getTeacherSubjectsSpinnerValue(
    String apiToken, String teacherId) async {
  // TODO: implement fetchTeacherProfile
  List<String> _values=List();
  List<String> _ids=List();
  try {
    final response = await http.get(MyStrings.domain +
        MyStrings.viewTeacherProfileUrl + apiToken + "/" + teacherId);
    Map map = json.decode(response.body);
    print(map);

    _values.clear();
    _ids.clear();
    if (map["status"].toString()!= 'true') {
      throw ApiException(
          handelServerError(response: map));
    }

    try{
      List teacherSub = map['return_data']["subject_details_array"];
      if (teacherSub.isNotEmpty) {
        for (var subject in teacherSub) {
          if(!_ids.contains(subject["id"].toString()) && !_values.contains(subject["title"].toString())){
            _values.add(subject["title"].toString());
            _ids.add(subject["id"].toString());
          }
        }
      }
    }on NoSuchMethodError{}

  } on SocketException {
    throw NetworkError();
  } on FormatException catch (e) {
    throw SystemError();
  }

  return [_values, _ids];
}

