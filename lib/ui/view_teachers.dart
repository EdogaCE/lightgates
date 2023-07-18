import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_teachers_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_form_teacher_dialog.dart';
import 'package:school_pal/ui/add_teacher_class_subject_dialog.dart';
import 'package:school_pal/ui/create_teacher_profile.dart';
import 'package:school_pal/ui/teacher_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'general.dart';

class ViewTeachers extends StatelessWidget {
  final SalaryRecord salaryRecord;
  final List<Teachers> teachers;
  final String from;
  final String classes;
  ViewTeachers({this.salaryRecord, this.teachers, this.from, this.classes});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TeachersBloc>(
          create: (context) => TeachersBloc(viewTeachersRepository: ViewTeachersRequest(),
              updateProfileRepository: UpdateProfileRequest()),
        )
      ],
      child: ViewTeachersPage(salaryRecord, teachers, from, classes),
    );
  }
}

// ignore: must_be_immutable
class ViewTeachersPage extends StatelessWidget {
  final SalaryRecord salaryRecord;
  List<Teachers> teachers;
  final String from;
  final String classes;
  ViewTeachersPage(this.salaryRecord, this.teachers, this.from, this.classes);

  static bool _updated=false;
  static TeachersBloc _teachersBloc;
  void _viewTeachers() async {
      _teachersBloc.add(ViewTeachersEvent(apiToken: await getApiToken(), localDb: false));
  }

  @override
  Widget build(BuildContext context) {
    _teachersBloc = BlocProvider.of<TeachersBloc>(context);
    getApiToken().then((value){
      if(value!=null){
        _teachersBloc.add(ViewTeachersEvent(apiToken: value, localDb: true));
      }
    });
    _viewTeachers();
    final _refreshController = RefreshController();

    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewTeachers();
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
                              delegate: CustomSearchDelegate(teachers, salaryRecord, from));
                        })
                  ],
                  pinned: true,
                  expandedHeight: 250.0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text('Teachers'),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child:Center(
                            child:SvgPicture.asset("lib/assets/images/teachers.svg")
                        ),
                      )),
                ),
               _teachersGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "Add record",
          onPressed: () {
            _navigateCreateEditTeacherScreen(context: context, type: 'Add');
          },
          label: Text('Create'),
          icon: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _teachersGrid(context) {
    return BlocListener<TeachersBloc, TeachersStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
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
        } else if (state is TeachersLoaded) {
          if(classes.isEmpty){
            teachers = state.teachers;
          }else{
            teachers = state.teachers.where((p) => (p.classes.contains(classes)))
                .toList();
          }
        }else if (state is TeachersProcessing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if (state is FormTeacherAdded) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }else if (state is FormTeacherRemoved) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }else if (state is TeacherClassSubjectAdded){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }
      },
      child: BlocBuilder<TeachersBloc, TeachersStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is TeachersInitial) {
            return buildInitialScreen();
          } else if (state is TeachersLoading) {
            try{
              return (teachers.isNotEmpty)?_buildLoadedScreen(context, teachers):buildLoadingScreen();
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is TeachersLoaded) {
            return _buildLoadedScreen(context, teachers);
          } else if (state is ViewError) {
            try{
              return (teachers.isNotEmpty)?_buildLoadedScreen(context, teachers):buildNODataScreen();
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return (teachers.isNotEmpty)?_buildLoadedScreen(context, teachers):buildNetworkErrorScreen();
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return (teachers.isNotEmpty)?_buildLoadedScreen(context, teachers): buildInitialScreen();
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
                      valueColor:
                      new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
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
              onTap: () {
                _viewTeachers();
              },
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Teachers> teachers) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context: context, teachers: teachers, index: index, salaryRecord: salaryRecord, from: from);
      }, childCount: teachers.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context,List<Teachers> teachers, int index, SalaryRecord salaryRecord, String from}) {
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
                    Icons.view_agenda,
                    color: Colors.amber,
                  ),
                  title: new Text('View'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToViewTeachersDetailScreen(context, teachers, index, salaryRecord, from);
                  },
                ),
                (from.isEmpty)?ListTile(
                    leading: new Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                    title: new Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateCreateEditTeacherScreen(context: context, teachers: teachers[index], type: 'Edit');
                    }):Container(),
                (from.isEmpty)?ListTile(
                    leading: new Icon(
                      Icons.add_box,
                      color: Colors.brown,
                    ),
                    title: new Text('Make Form Teacher'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddFormTeacherModalDialog(context: context, teachers: teachers[index]);
                    }):Container(),
                (from.isEmpty)?ListTile(
                    leading: new Icon(
                      Icons.add_box,
                      color: Colors.blueGrey,
                    ),
                    title: new Text('Assign Class And Subject'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddTeacherClassSubjectModalDialog(context: context, teachers: teachers[index]);
                    }):Container(),
              ],
            ),
          );
        });
  }

  static _navigateToViewTeachersDetailScreen(BuildContext context,List<Teachers> teachers, int index,  SalaryRecord salaryRecord, String from) async {

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TeachersDetails(teachers: teachers, index: index, salaryRecord: salaryRecord, from: from)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
      try{
        _updated=true;
        _teachersBloc.add(ViewTeachersEvent(apiToken: await getApiToken(), localDb: false));
      }on NoSuchMethodError{}
    }
  }

  static _navigateCreateEditTeacherScreen({BuildContext context, Teachers teachers, String type}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTeacherProfile(teacher: teachers, type: type)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _updated=true;
      _teachersBloc.add(ViewTeachersEvent(apiToken: await getApiToken(), localDb: false));
      //Refresh after update
    }
  }

  static void _showAddFormTeacherModalDialog({BuildContext context, Teachers teachers}) async {
    final data = await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: AddFormTeacherDialog(),
          );
        });
    if (data != null) {
//TODO: Activate term here
      print(data.toString());
      _teachersBloc.add(AddFormTeacherEvent(data['classId'], data['sessionId'], data['termId'], teachers.id));
    }
  }

  static void _showAddTeacherClassSubjectModalDialog({BuildContext context, Teachers teachers}) async {
    final data = await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: AddTeacherClassSubjectDialog(edit: false),
          );
        });
    if (data != null) {
//TODO: Activate term here
      print(data.toString());
      _teachersBloc.add(AddTeacherClassSubjectEvent(data['classId'], data['subjectId'], data['sessionId'], data['termId'], teachers.id));
    }
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_updated) {
      print("onwill goback");
      Navigator.pop(context, 'new update');
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}

Widget _buildRow({BuildContext context, List<Teachers> teachers, int index, SalaryRecord salaryRecord, String from}) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        child: ListTile(
          title: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Container(
                    child: Hero(
                      tag: "teacher passport tag $index",
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: FadeInImage.assetNetwork(
                            placeholderScale: 5,
                            height: 200,
                            width: 200,
                            fit: BoxFit.fill,
                            fadeInDuration: const Duration(seconds: 1),
                            fadeInCurve: Curves.easeInCirc,
                            placeholder: 'lib/assets/images/avatar.png',
                            image: teachers[index].passportLink+teachers[index].passport,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                      ' ${toSentenceCase(teachers[index].title)} ${toSentenceCase(teachers[index].lName)} ${toSentenceCase(teachers[index].fName)} ${toSentenceCase(teachers[index].mName)}',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18,
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                      (teachers[index].email.isNotEmpty)
                          ? teachers[index].email
                          : "Email unknown",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ],
          ),
          onTap: () {
            ViewTeachersPage._navigateToViewTeachersDetailScreen(context, teachers, index, salaryRecord, (from!='category')?from:'');
            // Add 9 lines from here...
          },
          onLongPress: (){
            ViewTeachersPage.showOptionsModalBottomSheet(context: context, teachers: teachers,
                index: index, salaryRecord: salaryRecord, from: from);
          },// ... to here.// ... to here.
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Teachers> teachers;
  final SalaryRecord salaryRecord;
  final String from;
  CustomSearchDelegate(this.teachers, this.salaryRecord, this.from);

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
          ? teachers
          : teachers
          .where((p) =>
      (p.email.toLowerCase().contains(query.toLowerCase())) ||
          (p.fName.toLowerCase().contains(query.toLowerCase())) ||
          (p.mName.toLowerCase().contains(query.toLowerCase())) ||
          (p.lName.toLowerCase().contains(query.toLowerCase())))
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
          return _buildRow(context: context, teachers: suggestionList, index: index, salaryRecord: salaryRecord, from: from);
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
          ? teachers
          : teachers
          .where((p) =>
      (p.email.toLowerCase().contains(query.toLowerCase())) ||
          (p.fName.toLowerCase().contains(query.toLowerCase())) ||
          (p.mName.toLowerCase().contains(query.toLowerCase())) ||
          (p.lName.toLowerCase().contains(query.toLowerCase())))
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
          return _buildRow(context: context, teachers: suggestionList, index: index, salaryRecord: salaryRecord, from: from);
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
