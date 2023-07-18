import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pal/blocs/login/login.dart';
import 'package:school_pal/models/app_versions.dart';
import 'package:school_pal/requests/posts/login_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/home.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(LoginRequests()),
      child: SplashScreenPage(),
    );
  }
}

// ignore: must_be_immutable
class SplashScreenPage extends StatelessWidget {
  LoginBloc loginBloc;

  startTimeout() {
    return new Timer(Duration(seconds: 2), handleTimeout);
  }

  void handleTimeout() {
    loginBloc.add(InitializeAppEvent(false));
  }

  changeScreen(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Home();
        },
      ),
    );
  }


  bool currentAppVersion(BuildContext context, AppVersions appVersions){
    bool currentVersion;
    try{
      String platform=getDevicePlatform();
      switch(platform){
        case MyStrings.androidPlatformId:{
          currentVersion=MyStrings.androidVersion==appVersions.androidVersion;
          if(!currentVersion)
            showUpdateDialog(context: context, message: MyStrings.updateAndroidMessage, appLink: appVersions.androidPlayStoreLink);
          break;
        }
        case MyStrings.iosPlatformId:{
          currentVersion=MyStrings.iosVersion==appVersions.iosVersion;
          if(!currentVersion)
            showUpdateDialog(context: context, message: MyStrings.updateIOSMessage, appLink: appVersions.iosAppStoreLink);
          break;
        }
      }
    }catch (e){
      currentVersion=true;
      print(e.toString());
    }
    return currentVersion;
  }


  Widget build(BuildContext context) {
    loginBloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginStates>(
        listener: (BuildContext context, LoginStates state) {
          if (state is UserLoading) {
            /*Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(minutes: 30),
                backgroundColor: MyColors.primaryColor,
                content: General.progressIndicator("Initializing..."),
              ),
            );*/
          } else if (state is NetworkErr || state is UserError) {
            //Scaffold.of(context).removeCurrentSnackBar();
            loginBloc.add(InitializeAppEvent(true));
          }  else if (state is AppInitialized) {
            //Scaffold.of(context).removeCurrentSnackBar();
            if(currentAppVersion(context, state.appVersions)){
              changeScreen(context);
            }
          }

        },
        child: BlocBuilder<LoginBloc, LoginStates>(
          builder: (BuildContext context, LoginStates state) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    color: Colors.white,
                    child: Animator<double>(
                      tween: Tween<double>(begin: 0, end: 500),
                      repeats: 1,
                      endAnimationListener: (_) {
                        print("Animation ended");
                        startTimeout();
                      },
                      duration: Duration(seconds: 2),
                      builder: (context, anim1, child) => Animator<double>(
                        tween: Tween<double>(begin: -0, end: 0),
                        cycles: 0,
                        builder: (context, anim2, child) => Center(
                          child: Transform.rotate(
                            angle: anim2.value,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: anim1.value,
                              width: anim1.value,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  MyStrings.logoPath,
                                  scale: 5,
                                  colorBlendMode: BlendMode.darken,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Learning ', style: TextStyle(color: Colors.deepOrange, fontSize: 25),
                        children: <TextSpan>[
                          TextSpan(text: '+', style: TextStyle(color: MyColors.primaryColor, fontSize: 25)),
                          TextSpan(text: ' Convenience', style: TextStyle(color:Colors.lightGreen, fontSize: 25)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}