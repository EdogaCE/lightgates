import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/notification/notification.dart';
import 'package:school_pal/models/notifications.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_notifications_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/events_calender.dart';
import 'package:school_pal/ui/result_view_option.dart';
import 'package:school_pal/ui/view_adverts.dart';
import 'package:school_pal/ui/view_assessments_by_class.dart';
import 'package:school_pal/ui/view_fees_record.dart';
import 'package:school_pal/ui/view_learning_materials_by_class.dart';
import 'package:school_pal/ui/view_school_gallery.dart';
import 'package:school_pal/ui/view_school_sessions.dart';
import 'package:school_pal/ui/view_school_terms.dart';
import 'package:school_pal/ui/view_students_fee_records.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ViewNotifications extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewNotifications({this.loggedInAs, this.classes});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(viewNotificationsRepository: ViewNotificationsRequest()),
      child: ViewNotificationsPage(loggedInAs, classes),
    );
  }
}

// ignore: must_be_immutable
class ViewNotificationsPage extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewNotificationsPage(this.loggedInAs, this.classes);
  NotificationBloc _notificationBloc;
  List<Notifications> _notifications;

  _viewNotifications() async {
    _notificationBloc.add(ViewNotificationsEvent(await getApiToken(), loggedInAs.replaceAll('school', 'admin'), true));
    _notificationBloc.add(ViewNotificationsEvent(await getApiToken(), loggedInAs.replaceAll('school', 'admin'), false));
  }

  @override
  Widget build(BuildContext context) {
    _notificationBloc = BlocProvider.of<NotificationBloc>(context);
    _viewNotifications();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewNotifications();
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(notificationBloc: _notificationBloc, notifications: _notifications, classes: classes, loggedInAs: loggedInAs));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('Notifications'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Center(
                            child: SvgPicture.asset(
                                "lib/assets/images/notification.svg")
                        ),
                      ),
                    )),
              ),
              _buildNotifications(context)
            ],
          )),
    );
  }

  Widget _buildNotifications(context) {
    return BlocListener<NotificationBloc, NotificationStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NotificationsNetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is NotificationsViewError) {
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
        } else if (state is NotificationsLoaded) {
          _notifications = state.notifications;
        } else if (state is NotificationLoaded) {
          _viewNotifications();
        }else if (state is NotificationsProcessing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is NotificationInitial) {
            return buildInitialScreen();
          } else if (state is NotificationsLoading) {
            try{
              return _notifications.isNotEmpty?_buildLoadedScreen(context, _notifications):buildLoadingScreen();
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is NotificationsLoaded) {
            return _buildLoadedScreen(context, state.notifications);
          } else if (state is NotificationsViewError) {
            try{
              return _notifications.isNotEmpty?_buildLoadedScreen(context, _notifications):buildNODataScreen();
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          } else if (state is NotificationsNetworkErr) {
            try{
              return _notifications.isNotEmpty?_buildLoadedScreen(context, _notifications):buildNetworkErrorScreen();
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _notifications.isNotEmpty?_buildLoadedScreen(context, _notifications):buildInitialScreen();
            }on NoSuchMethodError{
              return buildInitialScreen();
            }
          }
        },
      ),
    );
  }

  Widget buildInitialScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Scaffold(),
          ),
        ));
  }

  Widget buildLoadingScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          MyColors.primaryColor),
                      backgroundColor: Colors.pink,
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget buildNODataScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              MyStrings.noData,
              height: 150.0,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }

  Widget buildNetworkErrorScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: SvgPicture.asset(
                MyStrings.networkError,
                height: 150.0,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => _viewNotifications(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Notifications> notifications) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, _notificationBloc, notifications, index, loggedInAs, classes);
      }, childCount: notifications.length),
    );
  }


}

Widget _buildRow(BuildContext context, NotificationBloc notificationBloc,  List<Notifications> notifications, int index, String loggedInAs,  String classes) {
  Map<String, Widget> notificationPages={
    'calender_events_for_students':EventsCalender(loggedInAs: loggedInAs),
    'calender_events_for_teachers':EventsCalender(loggedInAs: loggedInAs),
    'activation_of_new_session':ViewSchoolSessions(firstTimeLogin: false),
    'activation_of_new_term':ViewSchoolTerms(firstTimeLogin: false),
    'addition_of_new_event_to_gallery':ViewSchoolGallery(loggedInAs: loggedInAs),
    'new_assessments':ViewAssessmentsByClass(loggedInAs: loggedInAs, classes: classes),
    'new_learning_materials':ViewLearningMaterialsByClass(loggedInAs: loggedInAs, classes: classes),
    'result_confirmation':ResultViewOption(title: 'Verified Results', type: 'verified results', loggedInAs: loggedInAs, cumulative: false),
    'declination_of_result':ResultViewOption(title: 'Pending Results', type: 'pending results', loggedInAs: loggedInAs, cumulative: false),
    'result_upload':ResultViewOption(title: 'Pending Results', type: 'pending results', loggedInAs: loggedInAs, cumulative: false),
    'fees_addition':ViewStudentsFeeRecords(),
    'successful_payment_of_fees':ViewFeesRecord(),
    'creation_of_new_ads_campaign':ViewAdvert()
  };

  return !notifications[index].deleted?Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    color: !notifications[index].read?Colors.teal.withOpacity(0.1):Colors.white,
    shadowColor: notifications[index].deleted?Colors.red:Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
    ),
    elevation: 1,
    child: ListTile(
      title: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              color: (index + 1 < 10)
                  ? Colors.pink[100 * (index + 1 % 9)]
                  : Colors.pink,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('${index+1}',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                !notifications[index].read?Container(
                  width: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                    child: Text(toSentenceCase('New'),
                      style: TextStyle(
                          fontSize: 14,
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ):Container(),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                  child: Text(toSentenceCase(notifications[index].title),
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                  child: Text(toSentenceCase(notifications[index].description),
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                )
              ],
            ),
          )
        ],
      ),
      onTap: () async {
        try{
          if(notificationPages.containsKey(notifications[index].notificationType)){
            if((notifications[index].notificationType=='activation_of_new_session'&&loggedInAs!=MyStrings.school)
            ||(notifications[index].notificationType=='activation_of_new_term'&&loggedInAs!=MyStrings.school)){
              Navigator.pop(context);
            }else{
              _navigateToNotificationPageScreen(context: context, page: notificationPages[notifications[index].notificationType], notificationBloc: notificationBloc, notification: notifications[index], loggedInAs: loggedInAs);
            }
            }else{
            Navigator.pop(context);
          }
        }catch(e){
          print(e.toString());
        }

      },
    ),
  ):Container();
}

_navigateToNotificationPageScreen({BuildContext context,  NotificationBloc notificationBloc, Notifications notification,  String loggedInAs, Widget page}) async {
 await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    ),
  );
 notificationBloc.add(ViewNotificationEvent(await getApiToken(), notification.id, loggedInAs.replaceAll('school', 'admin')));

}

class CustomSearchDelegate extends SearchDelegate {
  final NotificationBloc notificationBloc;
  final List<Notifications> notifications;
  final String loggedInAs;
  final String classes;
  CustomSearchDelegate({this.notificationBloc, this.notifications, this.loggedInAs, this.classes});

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    try {
      final suggestionList = query.isEmpty
          ? notifications
          : notifications
          .where((p) =>
      (p.title.contains(query)) || (p.description.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, notificationBloc, suggestionList, index, loggedInAs, classes);
          });
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    try {
      final suggestionList = query.isEmpty
          ? notifications
          : notifications
          .where((p) =>
      (p.title.contains(query)) || (p.description.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, notificationBloc, suggestionList, index, loggedInAs, classes);
          });
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }
}
