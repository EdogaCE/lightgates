import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pal/providers/notification_provider.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:provider/provider.dart';
import 'package:school_pal/ui/splash_screen.dart';

void main() => runApp(MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ],
  child: MyApp(),
));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Hide status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: MyStrings.appName,
      themeMode:ThemeMode.light,
      darkTheme: ThemeData(
          primarySwatch: MyColors.darkColor,
          fontFamily: 'CenturyGothic'
      ),
      theme: ThemeData(
          primarySwatch: MyColors.primaryColor,
          fontFamily: 'CenturyGothic'
      ),
      home:SplashScreen(),
    );
  }
}
