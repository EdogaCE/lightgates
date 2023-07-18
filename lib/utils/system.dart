import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/main.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/login.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/ui/modals.dart';

void reLogUserOut(context) async {
  showMessageModalDialog(context: context, message: 'Please login to continue.', buttonText: 'Ok', closeable: false).then((value){
    DatabaseHandlerOperations().deleteAllData().then((value){
      clearLoginDetails();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        ModalRoute.withName('/'),
      );
    });
  });
}

void logUserOut(context){
  DatabaseHandlerOperations().deleteAllData().then((value){
    clearLoginDetails();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
      ModalRoute.withName('/'),
    );
  });
}

String toSentenceCase(String string) {
  try{
    return string.substring(0, 1).toUpperCase() +
        string.substring(1, string.length);
  }on RangeError{
    return string;
  }on NoSuchMethodError{
    return string;
  }
}

DateTime convertDateFromString(String strDate){
  DateTime todayDate = DateTime.parse(strDate);
  return todayDate;
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if(value.isEmpty){
    return 'Please enter your email.';
  }
  if (!regex.hasMatch(value))
    return 'Please enter a valid email.';
  else
    return null;
}

String getDevicePlatform(){
  String _platform;
  if (Platform.isAndroid) {
    _platform=MyStrings.androidPlatformId;
  }else if (Platform.isIOS) {
    _platform=MyStrings.iosPlatformId;
  }
  return _platform;
}

void logPrint(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

String ordinal(int i){
  List suffixes =["th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th"];
  switch (i % 100) {
    case 11:
    case 12:
    case 13:
      return '$i${suffixes[0]}';
    default:
      return '$i${suffixes[i % 10]}';

  }
}

String convertPrice({Currency currency, String amount}){
  print(currency.expression);
  String price;
  try{
    final formatCurrency = new NumberFormat("#,##0.00", "en_US");
    price='(${currency.secondCurrency}) ${formatCurrency.format((double.parse(amount)*double.parse(currency.rateOfConversion)))}';
    //final formatCurrency = new NumberFormat.simpleCurrency();
  }on FormatException{
    price='(${currency.secondCurrency}) $amount';
  }
  return price;
}

String convertPriceNoFormatting({Currency currency, String amount}){
  print(currency.expression);
  String price;
  try{
    price='${(double.parse(amount)*double.parse(currency.rateOfConversion))}';
  }on FormatException{
    price=amount;
  }
  return price;
}


String handelServerError({Map response}){
  List<String> message = List();
  Map errorStatements = response['error_statement'];
  for (var error in errorStatements.keys) {
    if(errorStatements[error] is String){
      errorStatements[error]=errorStatements[error].split(':');
    }
    for (var err in errorStatements[error]) {
      message.add(err);
    }
  }
  print(message);
  return message.join(',');
}