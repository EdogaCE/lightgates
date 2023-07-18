import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/school/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_school_session_requests.dart';
import 'package:school_pal/requests/posts/add_edit_session_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_session_dialog.dart';
import 'general.dart';

class ViewSchoolSessions extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSchoolSessions({this.firstTimeLogin});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SchoolBloc(viewSchoolSessionRepository: ViewSchoolSessionRequest(), addEditSessionRepository: AddEditSessionRequests()),
      child: ViewSchoolSessionsPage(firstTimeLogin),
    );
  }
}

// ignore: must_be_immutable
class ViewSchoolSessionsPage extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSchoolSessionsPage(this.firstTimeLogin);
  static SchoolBloc _schoolBloc;
  List<Sessions> _schoolSessions;

  void viewSchoolSessions() async {
    _schoolBloc.add(ViewSessionsEvent(await getApiToken()));
  }

  bool completedFirstTimeLoginSetup=false;
  void _firstTimeLoginActions(BuildContext context){
    Future.delayed(const Duration(milliseconds: 500), () {
      if(firstTimeLogin){
        showCreateOrEditSessionModalDialog(context: context, type: "Add").then((value){
          if(value!=null){
            _schoolBloc.add(AddSessionEvent(value['sessionDate'], value['startDate'], value['endDate'], value['admissionPrefix']));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();
    _schoolBloc = BlocProvider.of<SchoolBloc>(context);
    viewSchoolSessions();
    _firstTimeLoginActions(context);
    return WillPopScope(
      onWillPop: () =>_popNavigator(context, !firstTimeLogin),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              viewSchoolSessions();
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
                              delegate: CustomSearchDelegate(_schoolSessions));
                        })
                  ],
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text("Class Levels")),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text("School Sessions"),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Center(
                              child: SvgPicture.asset("lib/assets/images/levels.svg")
                          ),
                        ),
                      )),
                ),
                _studentsGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton(
          heroTag: "Add session",
          onPressed: () {
            showCreateOrEditSessionModalDialog(context: context, type: "Add").then((value){
              if(value!=null){
                _schoolBloc.add(AddSessionEvent(value['sessionDate'], value['startDate'], value['endDate'], value['admissionPrefix']));
              }
            });
          },
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _studentsGrid(context) {
    return BlocListener<SchoolBloc, SchoolStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is ViewError) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is Processing) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator(state.message),
            ),
          );
        }else if (state is SessionsLoaded) {
          Scaffold.of(context).removeCurrentSnackBar();
          _schoolSessions = state.sessions;
        }else if (state is SessionActivated) {
          Scaffold.of(context).removeCurrentSnackBar();
          _schoolSessions = state.sessions;
          if(firstTimeLogin){
           completedFirstTimeLoginSetup=true;
          }
        }else if (state is SessionAdded) {
          _schoolSessions = state.sessions;
          showModalAlertOptionDialog(context: context, title: 'Activate Session', message: 'Do you wish to activate session ${state.sessions.last.sessionDate}', buttonYesText: 'Yes', buttonNoText: 'No').then((value){
            if(value!=null){
              if(value)
                _schoolBloc.add(ActivateSessionEvent(state.sessions.last.id));
            }
          });
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Session was created successfully', textAlign: TextAlign.center),
              ),
            );
        }else if (state is SessionUpdated) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          viewSchoolSessions();
        }

      },
      child: BlocBuilder<SchoolBloc, SchoolStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is SchoolInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _schoolSessions);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is SessionsLoaded) {
            return _buildLoadedScreen(context, state.sessions);
          } else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _schoolSessions);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _schoolSessions);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _schoolSessions);
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
                      valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
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
              onTap: () => viewSchoolSessions(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(
      BuildContext context, List<Sessions> sessions) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return buildSchoolSessions(context, sessions, index);
      }, childCount: sessions.length),
    );
  }

  static void showEditOrActivateModalBottomSheet({BuildContext context, Sessions sessions, String id}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    Icons.update,
                    color: MyColors.primaryColor,
                  ),
                  title: new Text('Activate'),
                  onTap: () {
                    Navigator.pop(context);
                    _schoolBloc.add(ActivateSessionEvent(id));
                  },
                ),
                ListTile(
                    leading: new Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                    title: new Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      showCreateOrEditSessionModalDialog(context: context, sessions: sessions, type: "Edit").then((value){
                       if(value!=null){
                         _schoolBloc.add(UpdateSessionEvent(id, value['sessionDate'], value['startDate'], value['endDate'], value['admissionPrefix']));
                       }
                      });
                    }),
              ],
            ),
          );
        });
  }

  static Future<Map<String, String>> showCreateOrEditSessionModalDialog(
      {BuildContext context, Sessions sessions, String type}) async{
    final data= await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: CreateSessionDialog(sessions, type),
          );
        });
    return data;
  }

  Future<bool> _popNavigator(BuildContext context, bool closeable) async {
    if (closeable) {
      print("onwill goback");
      return Future.value(true);
    } else {
      print("onwillNot goback");
      Navigator.pop(context, completedFirstTimeLoginSetup);
      return Future.value(false);
    }
  }

}


Widget buildSchoolSessions(
    BuildContext context, List<Sessions> sessions, int index) {
  return Card(
    // margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: RaisedButton(
                  onLongPress: (){
                    ViewSchoolSessionsPage.showEditOrActivateModalBottomSheet(context: context, sessions: sessions[index], id:  sessions[index].id);
                  },
                  onPressed: () {
                    ViewSchoolSessionsPage.showEditOrActivateModalBottomSheet(context: context, sessions: sessions[index], id:  sessions[index].id);
                  },
                  color: Colors.blue,
                  padding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        width: 5.0, style: BorderStyle.solid, color:(index + 1 < 5)
                        ? Colors.pink[200 * (index + 1 % 9)]
                        : Colors.pink),
                    // borderRadius: new BorderRadius.circular(50.0),
                  ),
                  child: Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(sessions[index].sessionDate.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              )),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child:Text(toSentenceCase(sessions[index].status),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 14,
                      color:(sessions[index].status!='active')?Colors.black54:Colors.green,
                      fontWeight: FontWeight.normal)),
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Sessions> sessions;
  CustomSearchDelegate(this.sessions);

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
          ? sessions
          : sessions
          .where((p) =>
          p.sessionDate.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return buildSchoolSessions(context, suggestionList, index);
        },
      );
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
          ? sessions
          : sessions
          .where((p) =>
          p.sessionDate.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return buildSchoolSessions(context, suggestionList, index);
        },
      );
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


