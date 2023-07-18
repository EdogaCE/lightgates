import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'dart:async';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print(data);
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(notification);
  }

  // Or do other work.
}

class NotificationProvider extends ChangeNotifier{
  NotificationProvider(){
    initializeNotification();
  }
  //final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  // ignore: cancel_subscriptions
  StreamSubscription iosSubscription;

  Map<String, dynamic> notification=Map();
  List<Chat> chats;

  void initializeNotification(){
    print('Initializing firebase');
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }else{
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        notification=message;
        notifyListeners();
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

        // TODO optional
      },
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();
    String oldFcmToken=await getFirebaseToken();

    // Save it to Firestore
    if (fcmToken != null) {
      if(fcmToken!=oldFcmToken){
        await saveFirebaseTokenToSF(fcmToken);
        sendFirebaseTokenToServer(fcmToken);
        print('NEW TOKEN: $fcmToken');
      }
      print('TOKEN: $fcmToken');
    }
  }

  void _subscribeToTopic(String topic){
    _fcm.subscribeToTopic(topic);
  }

  void _unSubscribeFromTopic(String topic){
    _fcm.unsubscribeFromTopic(topic);
  }

  void sendFirebaseTokenToServer(String token) async{
    String _androidToken, _isoToken;
    if (Platform.isAndroid) {
      _androidToken=token;
      _isoToken='';
    }else if (Platform.isIOS) {
      _androidToken='';
      _isoToken=token;
    }
    ChatRepository chatRepository=ChatRequests();
    try{
      final message=await chatRepository.sendFirebaseToken(androidToken: _androidToken, iosToken: _isoToken);
      print(message);
    } on NetworkError{
      print(MyStrings.networkErrorMessage);
    }on ApiException catch(e){
      print(e.toString());
    }on SystemError{
      print(MyStrings.systemErrorMessage);
    }
  }

}