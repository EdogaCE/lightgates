import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:school_pal/blocs/advert/advert.dart';
import 'package:school_pal/blocs/advert/advert_bloc.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/blocs/navigatoins/navigation.dart';
import 'package:school_pal/blocs/notification/notification.dart';
import 'package:school_pal/models/notifications.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/providers/notification_provider.dart';
import 'package:school_pal/requests/get/view_adverts_request.dart';
import 'package:school_pal/requests/get/view_faqs_news_request.dart';
import 'package:school_pal/requests/get/view_notifications_requests.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/add_edit_faq_news_requests.dart';
import 'package:school_pal/requests/posts/login_request.dart';
import 'package:school_pal/requests/posts/logout_request.dart';
import 'package:school_pal/requests/posts/update_advert_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/ui/dashboard_content.dart';
import 'package:school_pal/ui/dashboard_side_drawer.dart';
import 'package:school_pal/ui/developer_contact.dart';
import 'package:school_pal/ui/faq.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/news.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/ui/school_profile.dart';
import 'package:school_pal/ui/view_notifications.dart';
import 'package:school_pal/utils/system.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class Dashboard extends StatelessWidget {
  final String loggedInAs;
  final User user;
  Dashboard({this.loggedInAs, this.user});
  @override
  Widget build(BuildContext context) {
    //Show status bar
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
              viewProfileRepository: ViewProfileRequest(),
              viewFAQsNewsRepository: ViewFAQsNewsRequest(),
            createFaqNewsRepository: CreateFaqNewsRequests(),
            logoutRepository: LogoutRequests()
          ),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(viewNotificationsRepository: ViewNotificationsRequest()),
        ),
        BlocProvider<AdvertBloc>(
          create: (context) => AdvertBloc(
              viewAdvertsRepository: ViewAdvertsRequest(),
              updateAdvertRepository: UpdateAdvertRequests()),
        ),
      ],
      child: DashBoardPage(loggedInAs, user),
    );
  }
}

// ignore: must_be_immutable
class DashBoardPage extends StatelessWidget {
  final String loggedInAs;
  final User user;
  DashBoardPage(this.loggedInAs, this.user);
  static BuildContext _context;
  // ignore: close_sinks
  static DashboardBloc dashboardBloc;
  NavigationBloc navigationBloc;
  NotificationBloc notificationBloc;
  AdvertBloc advertBloc;
  List<Notifications> _notifications=List();
  bool initialBuild=true;

   void _viewFAQs() async {
     dashboardBloc.add(ViewFAQsEvent(localDB: true));
     dashboardBloc.add(ViewFAQsEvent(localDB: false));
  }

  void _viewNews() async {
    dashboardBloc.add(ViewNewsEvent(localDB: true));
    dashboardBloc.add(ViewNewsEvent(localDB: false));
  }

  void _viewNotifications() async {
    notificationBloc.add(ViewNotificationsEvent(user.apiToken, loggedInAs.replaceAll('school', 'admin'), true));
    notificationBloc.add(ViewNotificationsEvent(user.apiToken, loggedInAs.replaceAll('school', 'admin'), false));
    advertBloc.add(ViewAdvertsEvent(userUniqueId: user.uniqueId));
  }

  startTimeout() {
    return new Timer(Duration(seconds: 25), handleTimeout);
  }

  void handleTimeout() {
    showAppRating(_context);
  }

  void showAppRating(BuildContext context)async{
     bool doNotShowAgain=await doNotOpenAgain();
     int launchesCount=await launches();
     if(!doNotShowAgain && (launchesCount==int.parse(MyStrings.minLaunchesBeforeRating))){
       saveLaunchesToSF(0);
       LoginRequests().fetchAppVersion(localDb: true).then((appVersions){
         try{
           String platform=getDevicePlatform();
           switch(platform){
             case MyStrings.androidPlatformId:{
               showRatingDialog(context: context, message: MyStrings.rateAppMessage, appLink: appVersions.androidPlayStoreLink);
               break;
             }
             case MyStrings.iosPlatformId:{
               showRatingDialog(context: context, message: MyStrings.rateAppMessage, appLink: appVersions.iosAppStoreLink);
               break;
             }
           }
         }catch (e){
           print(e.toString());
         }
       });
     }else{
       if(!doNotShowAgain)
       saveLaunchesToSF(++launchesCount);
     }
  }

  void showAppSetup(BuildContext context){
    if(initialBuild && user.firstTimeLogin){
      initialBuild=false;
      showMessageModalDialog(context: context, message: MyStrings.firsTimeLoginMessage, buttonText: 'Continue', closeable: false)
          .then((value){
        if(value!=null){
          showSetupModalDialog(context: context);
        }
      });
    }
  }

  void _viewProfile() async {
    loggedUser=loggedInAs;
    loggedInDetails=user;
    print('Logged in user: $loggedInAs');
    switch (loggedInAs) {
      case MyStrings.student:
        {
          dashboardBloc.add(ViewStudentProfileEvent(await getApiToken(), await getUserId(), await getLoggedInAs()));
          break;
        }
      case MyStrings.teacher:
        {
          dashboardBloc.add(ViewTeacherProfileEvent(await getApiToken(), await getUserId(), await getLoggedInAs()));
          break;
        }
      case MyStrings.school:
        {
          dashboardBloc.add(ViewSchoolProfileEvent(await getApiToken(), await getLoggedInAs()));
          showAppSetup(_context);
          break;
        }
    }
  }

  _updateAppLauncherBadger({int notificationCount})async{
     if(await FlutterAppBadger.isAppBadgeSupported()){
       //FlutterAppBadger.removeBadge();
       FlutterAppBadger.updateBadgeCount(notificationCount);
     }
  }

  _printApiToken() async {
    print('Api Token:  ${await getApiToken()}');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _context = context;
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    navigationBloc = BlocProvider.of<NavigationBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    advertBloc=BlocProvider.of<AdvertBloc>(context);
    _viewProfile();
    _viewNotifications();
    _printApiToken();
    startTimeout();
    return Scaffold(
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              text: MyStrings.appName, style: TextStyle(fontFamily: 'Roboto', fontSize: 15),
              children: <TextSpan>[
                TextSpan(text: ' ᵀᴹ', style: TextStyle(color: Colors.deepOrange, fontFamily: 'Roboto', fontSize: 10)),
              ],
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.fade,
          ),//Text(MyStrings.appName, style: TextStyle(fontFamily: 'Roboto', fontSize: 15)),
          elevation: 0.0,
          actions: <Widget>[
            Consumer<NotificationProvider>(
              builder: (BuildContext context, NotificationProvider notificationProvider, Widget child) {
                _onIncomingNotification(notificationProvider.notification);
                return BlocListener<NotificationBloc, NotificationStates>(listener:
                    (BuildContext context, NotificationStates state) {
                  if(state is NotificationsLoaded){
                    _notifications.clear();
                    for(Notifications notification in state.notifications){
                      if(!notification.read){
                        _notifications.add(notification);
                      }
                    }
                    _updateAppLauncherBadger(notificationCount: _notifications.length);
                  }
                }, child:BlocBuilder<NotificationBloc, NotificationStates>(builder:
                      (BuildContext context, NotificationStates state) {
                    return Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            String classes=await getStudentClass();
                           _navigateToNotificationScreen(context: context, classes: classes, loggedInAs: loggedInAs)
                               .then((value){
                             notificationBloc.add(ViewNotificationsEvent(user.apiToken, loggedInAs.replaceAll('school', 'admin'), false));
                           });
                          },
                        ),
                        Visibility(
                          visible: _notifications.isNotEmpty,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0, right: 5.0),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text((_notifications.length<100)
                                          ?_notifications.length.toString()
                                          :'99+', textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10),)
                                  ),
                                ),
                              ),
                              onTap: ()async{
                                String classes=await getStudentClass();
                                _navigateToNotificationScreen(context: context, classes: classes, loggedInAs: loggedInAs)
                                    .then((value){
                                  notificationBloc.add(ViewNotificationsEvent(user.apiToken, loggedInAs.replaceAll('school', 'admin'), false));
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.help,
                color: Colors.white,
              ),
              onPressed: () {
                if(loggedInAs!=MyStrings.student){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeveloperContact()),
                  );
                }else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchoolProfile(edit: false),
                      ));
                }
              },
            )
          ],
        ),
        drawer: BlocBuilder<DashboardBloc, DashboardStates>(
            builder: (BuildContext context, DashboardStates state) {
              if (state is SchoolProfileLoaded) {
                return dashboardSideDrawer(context: context, dashboardBloc: dashboardBloc, user: user, loggedInAs: loggedInAs, school: state.school);
              }else if (state is TeacherProfileLoaded) {
                return dashboardSideDrawer(context: context, dashboardBloc: dashboardBloc, user: user, loggedInAs: loggedInAs, teachers: state.teachers);
              }else if (state is StudentProfileLoaded) {
                return dashboardSideDrawer(context: context, dashboardBloc: dashboardBloc, user: user, loggedInAs: loggedInAs, students: state.students);
              } else {
              return dashboardSideDrawer(context: context, dashboardBloc: dashboardBloc, user: user, loggedInAs: loggedInAs);
              }
            }),
        bottomNavigationBar: BlocListener<NavigationBloc, NavigationStates>(
          listener: (BuildContext context, NavigationStates state) {
            if (state is DashboardNavBarItemChanged) {
              if(user.verificationStatus){
                _selectedIndex = state.index;
                if (state.index == 0) {
                  _viewProfile();
                } else if (state.index == 1)
                  _viewNews();
                else if (state.index == 2)
                  _viewFAQs();
              }else{
                showMessageModalDialog(context: context, message: MyStrings.verificationErrorMessage, buttonText: 'Ok', closeable: true).then((value) {
                  print(value);
                });
              }
            }
          },
          child: BlocBuilder<NavigationBloc, NavigationStates>(
              builder: (BuildContext context, NavigationStates state) {
            //if(state is BarItemChanged){
            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.new_releases),
                  label: 'News',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'FAQ',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: MyColors.primaryColor,
              onTap: _onItemTapped,
            );
          }),
        ),
        body: BlocBuilder<NavigationBloc, NavigationStates>(
            builder: (BuildContext context, NavigationStates state) {
          //if(state is BarItemChanged){
          return _bottomNavOptions[_selectedIndex];
        }));
  }

  int _selectedIndex = 0;
  static School school;
  static Teachers teachers;
  static Students students;
  static String loggedUser;
  static User loggedInDetails;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _bottomNavOptions = <Widget>[
     BlocListener<DashboardBloc, DashboardStates>(
        listener: (BuildContext context, DashboardStates state) {
      if (state is SchoolProfileLoaded) {
        school = state.school;
        loggedUser=state.loggedInAs;
        saveSchoolDashboardDetailsToSF(numberOfStudents: state.school.numberOfStudents, numberOfTeachers: state.school.numberOfTeachers, numberOfSubjects: state.school.numberOfSubjects, confirmedFees: convertPriceNoFormatting(currency: state.school.currency, amount: state.school.confirmedFees), pendingFees: convertPriceNoFormatting(currency: state.school.currency, amount: state.school.pendingFees), currency: state.school.currency.secondCurrency);
      }else if (state is TeacherProfileLoaded) {
        teachers = state.teachers;
        loggedUser=state.loggedInAs;

        saveTeacherDashboardDetailsToSF(currency: state.teachers.currency.secondCurrency, formTeacher: state.teachers.isFormTeacher, commentSwitch: state.teachers.school.resultCommentSwitch, pendingResultsCount: state.teachers.pendingResultsCount, confirmedResultsCount: state.teachers.confirmedResultsCount, numberOfClassTeaching: state.teachers.numberOfClassTeaching, numberOfClassForming: state.teachers.numberOfClassForming, learningMaterialsCount: state.teachers.learningMaterialsCount, assessmentsCount: state.teachers.assessmentsCount);

      }else if (state is StudentProfileLoaded) {
        students = state.students;
        loggedUser=state.loggedInAs;

        saveStudentDashboardDetailsToSF(studentClass: '${state.students.classes.label} ${state.students.classes.category}', currency: state.students.currency.secondCurrency, pendingFees: convertPriceNoFormatting(currency: state.students.currency, amount: state.students.pendingFees), eventsCount: state.students.eventsCount, learningMaterialsCount: state.students.learningMaterialsCount, assessmentsCount: state.students.assessmentsCount);

      }if (state is Processing) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(minutes: 30),
            content: General.progressIndicator("Processing..."),
          ),
        );
      } else if (state is NetworkErr) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content:
              Text(state.message, textAlign: TextAlign.center),
            ),
          );
      } else if (state is ViewError) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content:
              Text(state.message, textAlign: TextAlign.center),
            ),
          );
        if (state.message == "Please Login to continue") {
          reLogUserOut(context);
        }
      } else if (state is LoggingOut) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(minutes: 30),
            content: General.progressIndicator("Logging Out..."),
          ),
        );
      } else if (state is LogoutSuccessful) {
        logUserOut(context);
      }
        }, child: BlocBuilder<DashboardBloc, DashboardStates>(
            builder: (BuildContext context, DashboardStates state) {
      if (state is SchoolProfileLoaded) {
        return schoolDashboardContent(context: _context, school: state.school, user: loggedInDetails, loggedInAs: loggedUser, loaded: true);
      }else if (state is TeacherProfileLoaded) {
        return teacherDashboardContent(context: _context, teachers: state.teachers, user: loggedInDetails, loggedInAs: loggedUser, loaded: true);
      }else if (state is StudentProfileLoaded) {
        return studentDashboardContent(context: _context, students: state.students, user: loggedInDetails, loggedInAs: loggedUser, loaded: true);
      } else {
        try {
          return (loggedUser==MyStrings.school)?schoolDashboardContent(
              context: _context, school: school, user: loggedInDetails, loggedInAs: loggedUser, loaded: true):(loggedUser==MyStrings.teacher)?teacherDashboardContent(
              context: _context, teachers: teachers, user: loggedInDetails, loggedInAs: loggedUser, loaded: true):studentDashboardContent(
              context: _context, students: students, user: loggedInDetails, loggedInAs: loggedUser, loaded: true);
        } on NoSuchMethodError{
          return (loggedUser==MyStrings.school)?schoolDashboardContent(
              context: _context, user: loggedInDetails, loggedInAs: loggedUser, loaded: false):(loggedUser==MyStrings.teacher)?teacherDashboardContent(
              context: _context, user: loggedInDetails, loggedInAs: loggedUser, loaded: false):studentDashboardContent(
              context: _context, user: loggedInDetails, loggedInAs: loggedUser, loaded: false);
        }
      }
    })),

    BlocBuilder<DashboardBloc, DashboardStates>(
        builder: (BuildContext context, DashboardStates state) {
         return newsPage(dashboardBloc: dashboardBloc, context: context, loggedInAs: loggedUser);
        }),
    BlocBuilder<DashboardBloc, DashboardStates>(
        builder: (BuildContext context, DashboardStates state) {
          return faqPage(dashboardBloc: dashboardBloc, context: context, loggedInAs: loggedUser);
        })
  ];

  void _onItemTapped(int index) {
    navigationBloc.add(ChangeDashboardNavBarItemEvent(index));
  }

  Future<String> _navigateToNotificationScreen({BuildContext context, String classes, String loggedInAs}) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewNotifications(loggedInAs: loggedInAs, classes: classes)),
    );

    return result;
    }

  void _onIncomingNotification(Map<String, dynamic> message){
    print('New notification ${message.toString()}');
    try{
      Map<String, dynamic> notification=jsonDecode(message['data']['message']);
      if(notification['notification_type']!='chat_notification'){
        //Map chatDetails=notification['chat_details'];
        _viewNotifications();
      }
    }catch(e){
      print(e.toString());
    }
  }

}

Widget buildInitialScreen() {
  return Center(
    child: Scaffold(),
  );
}

Widget buildLoadingScreen() {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100.0),
      child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
              backgroundColor: Colors.pink,
            ),
          )),
    ),
  );
}

Widget buildNODataScreen() {
  return Align(
    alignment: Alignment.topCenter,
    child: SvgPicture.asset(
      MyStrings.noData,
      height: 150.0,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fitWidth,
    ),
  );
}

Widget buildNetworkErrorScreen(String page) {
  return Align(
    alignment: Alignment.topCenter,
    child: GestureDetector(
      child: SvgPicture.asset(
        MyStrings.networkError,
        height: 150.0,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
      ),
      onTap: () {
        switch (page) {
          case "news":
            {
              newsPage();
              break;
            }
          case "faq":
            {
              faqPage();
              break;
            }
        }
      },
    ),
  );
}
