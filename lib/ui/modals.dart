import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/app_rating_dialog.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/login.dart';
import 'package:school_pal/ui/message_dialog.dart';
import 'package:school_pal/ui/setup_dialog.dart';
import 'package:school_pal/utils/launch_request.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';

void loginAsModalBottomSheet(context) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text('Login As',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  leading: new Icon(
                    Icons.people,
                    color: Colors.orange,
                  ),
                  title: new Text('Student/Parent'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login(
                                loginAs: MyStrings.student,
                              )),
                    );
                  }),
              ListTile(
                leading: new Icon(
                  Icons.person,
                  color: Colors.teal,
                ),
                title: new Text('Teacher'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(
                              loginAs: MyStrings.teacher,
                            )),
                  );
                },
              ),
              ListTile(
                leading: new Icon(
                  Icons.business,
                  color: Colors.pink,
                ),
                title: new Text('School Admin'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(
                              loginAs: MyStrings.school,
                            )),
                  );
                },
              ),
            ],
          ),
        );
      });
}

void showProgressModalBottomSheet({BuildContext context, String progressMessage}) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      builder: (BuildContext bc) {
        return General.progressIndicator(progressMessage);
      });
}

Future<bool> showLogoutModalBottomSheet(context) async{
  final data= await showModalBottomSheet<bool>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 15.0, bottom: 8.0),
                child: Text('Logout',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 25.0, bottom: 25.0, left: 8.0, right: 8.0),
                    child: Text(MyStrings.logOut,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(bc, false);
                            },
                            textColor: Colors.white,
                            color: MyColors.primaryColor,
                            padding: const EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 15.0,
                                  right: 8.0,
                                  bottom: 15.0),
                              child: const Text("No",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.pop(bc, true);
                              },
                              textColor: MyColors.primaryColor,
                              color: Colors.white70,
                              padding: const EdgeInsets.all(0.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  side: BorderSide(color: MyColors.primaryColor)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 15.0,
                                    right: 8.0,
                                    bottom: 15.0),
                                child: const Text("Yes",
                                    style: TextStyle(fontSize: 20)),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      });
  return data;
}

Future<bool> showConfirmDeleteModalAlertDialog({context, title}) async{
  final data=await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Delete $title ?"),
          actions: [
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      });
  return data;
}

void showModalAlertDialog({context, title, message, buttonText}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

Future<bool> showModalAlertOptionDialog({context, title, message, buttonYesText, buttonNoText}) async{
  final data=await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FlatButton(
              child: Text(buttonYesText),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text(buttonNoText),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      });
  return data;
}


void showCallWhatsappMessageModalBottomSheet({BuildContext context, String countryCode, String number}) {
  showModalBottomSheet(
      context: context,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text('Options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: new Icon(
                  Icons.call,
                  color: Colors.teal,
                ),
                title: new Text('Dail'),
                onTap: () {
                  Navigator.pop(context);
                  LaunchRequest().launchCaller(number);
                },
              ),
              ListTile(
                  leading: new Icon(
                    Icons.chat,
                    color: Colors.blue,
                  ),
                  title: new Text('Whatsapp'),
                  onTap: () {
                    Navigator.pop(context);
                    LaunchRequest().launchWhasapp(int.parse(countryCode+number));
                  }),
              ListTile(
                leading: new Icon(
                  Icons.message,
                  color: Colors.blueGrey,
                ),
                title: new Text('Message'),
                onTap: () {
                  Navigator.pop(context);
                  LaunchRequest().launchMessage(number);
                },
              ),
              ListTile(
                leading: new Icon(
                  Icons.content_copy,
                  color: Colors.teal,
                ),
                title: new Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: number));
                },
              ),
            ],
          ),
        );
      });
}

void showCopyShareModalBottomSheet({BuildContext context, String content, String subject}) {
  showModalBottomSheet(
      context: context,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text('Options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: new Icon(
                  Icons.content_copy,
                  color: Colors.teal,
                ),
                title: new Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: '$content'));
                  /*Scaffold.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content:
                        Text('Copied To Clipboard', textAlign: TextAlign.center),
                      ),
                    );*/
                },
              ),
              ListTile(
                  leading: new Icon(
                    Icons.share,
                    color: Colors.blue,
                  ),
                  title: new Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    final RenderBox box = context.findRenderObject();
                    Share.share(content, subject: subject, sharePositionOrigin: box.localToGlobal(Offset.zero) &
                    box.size);
                  }),
            ],
          ),
        );
      });
}

void showToast({String message}){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<String> showMessageModalDialog({BuildContext context, String message, String buttonText, bool closeable})async{
  final data= await showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext,
          Animation animation,
          Animation secondaryAnimation) {
        return MessageDialog(message: message, buttonText: buttonText, closeable: closeable);
      });
  return data;
}

 showUpdateDialog({BuildContext  context, String message, String appLink}) {
  showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () =>Future.value(false),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20.0)), //this right here
                child: Container(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('System Update',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(message,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none))
                        ),
                        SizedBox(
                          width: 320.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  onPressed: () {
                                    LaunchRequest().launchURL(appLink);
                                  },
                                  textColor: Colors.white,
                                  color: MyColors.primaryColor, //MyColors.primaryColor,
                                  padding: const EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(25.0),
                                      side: BorderSide(color: Colors.white)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                                    child: const Text("Continue",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FlatButton(
                                  onPressed: () {
                                    if(Platform.isIOS){
                                      exit(0);
                                    }else if(Platform.isAndroid){
                                      SystemNavigator.pop();
                                    }
                                  },
                                  textColor: Colors.white,
                                  color:MyColors.transparent, //MyColors.primaryColor,
                                  padding: const EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(25.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                                    child:  Text("Exit",
                                        style: TextStyle(fontSize: 18, color: MyColors.primaryColor)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
      });
}

showRatingDialog({BuildContext  context, String message, String appLink}){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () =>Future.value(false),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: AppRatingDialog(message: message, appLink: appLink),
          ),
        );
      });
}

showSetupModalDialog({BuildContext  context})async{
  showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext,
          Animation animation,
          Animation secondaryAnimation) {
        return SetupDialog();
      });
}