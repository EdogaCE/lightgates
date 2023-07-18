import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_students/students.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_students_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_student_profile.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/student_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewStudents extends StatelessWidget {
  final List<Students> students;
  final String classes;
  final bool requireAdmissionNumber;
  ViewStudents({this.students,this.classes, this.requireAdmissionNumber});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StudentsBloc(viewStudentsRepository: ViewStudentsRequest(), updateProfileRepository: UpdateProfileRequest()),
      child: ViewStudentsPage(students, classes, requireAdmissionNumber),
    );
  }
}

// ignore: must_be_immutable
class ViewStudentsPage extends StatelessWidget {
  List<Students> students;
  final String classes;
  final bool requireAdmissionNumber;
  ViewStudentsPage(this.students, this.classes, this.requireAdmissionNumber);
  static StudentsBloc _studentsBloc;
  static bool _updated=false;

  void _viewStudents() async {
    _studentsBloc.add(ViewStudentsEvent(apiToken: await getApiToken(), localDb: false));
  }

  @override
  Widget build(BuildContext context) {
    _studentsBloc = BlocProvider.of<StudentsBloc>(context);
    getApiToken().then((value){
      if(value!=null){
        _studentsBloc.add(ViewStudentsEvent(apiToken: value , localDb: true));
      }
    });
    _viewStudents();
    final _refreshController = RefreshController();

    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewStudents();
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
                              delegate: CustomSearchDelegate(students));
                        })
                  ],
                  pinned: true,
                  expandedHeight: 250.0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text('Students'),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child:Center(
                            child: SvgPicture.asset("lib/assets/images/students.svg")
                        ),
                      )),
                ),
                _studentsGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "Add record",
          onPressed: () {
            _navigateCreateEditStudentScreen(context: context, type: 'Add', requireAdmissionNumber: requireAdmissionNumber);
          },
          label: Text('Create'),
          icon: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        )
      ),
    );
  }

  Widget _studentsGrid(context) {
    return BlocListener<StudentsBloc, StudentsStates>(
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
        } else if (state is StudentsLoaded) {
          if(classes.isEmpty){
            students = state.students;
          }else{
            students = state.students.where((p) => (p.stClass.contains(classes)))
                .toList();
          }
        }else if (state is StudentsProcessing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if (state is StudentDeleted) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewStudents();
        }

      },
      child: BlocBuilder<StudentsBloc, StudentsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is StudentsInitial) {
            return buildInitialScreen();
          } else if (state is StudentsLoading) {
            try{
              return (students.isNotEmpty)?_buildLoadedScreen(context, students):buildLoadingScreen();
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is StudentsLoaded) {
            return _buildLoadedScreen(context, students);
          } else if (state is ViewError) {
            try{
              return (students.isNotEmpty)?_buildLoadedScreen(context, students):buildNODataScreen();
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return (students.isNotEmpty)?_buildLoadedScreen(context, students):buildNetworkErrorScreen();
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return (students.isNotEmpty)?_buildLoadedScreen(context, students):buildInitialScreen();
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
              onTap: () => _viewStudents(),
            ),
          ),
        ));
  }


  Widget _buildLoadedScreen(BuildContext context, List<Students> students) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, students, index);
      }, childCount: students.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context,List<Students> students, int index, bool fees}) {
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
                    _navigateToViewStudentsDetailScreen(context, students, index, fees);
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
                      _navigateCreateEditStudentScreen(context: context, students: students[index], type: 'Edit', requireAdmissionNumber: false);
                    }),
                ListTile(
                    leading: new Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: new Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      _studentsBloc.add(DeleteStudentEvent(students[index].id));
                    })
              ],
            ),
          );
        });
  }


  static _navigateToViewStudentsDetailScreen(BuildContext context,List<Students> students, int index, bool fees) async {

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              StudentDetails(students: students, index: index, fees: fees, pickUpId: false)),
    );

    if(result!=null){
      _updated=true;
      _studentsBloc.add(ViewStudentsEvent(apiToken: await getApiToken(), localDb: false));
    }
  }

  static _navigateCreateEditStudentScreen({BuildContext context, Students students, String type, bool requireAdmissionNumber}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateStudentProfile(student: students, type: type, requireAdmissionNumber: requireAdmissionNumber)),
    );

    if (result != null) {
      _updated=true;
      _studentsBloc.add(ViewStudentsEvent(apiToken: await getApiToken(), localDb: false));
      //Refresh after update
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

Widget _buildRow(BuildContext context, List<Students> students, int index) {
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
                      tag: "student passport tag $index",
                      transitionOnUserGestures: true,
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
                            image: students[index].passportLink +
                                students[index].passport,
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
                      '${toSentenceCase(students[index].lName)} ${toSentenceCase(students[index].fName)} ${toSentenceCase(students[index].mName)}',
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
                      (students[index].admissionNumber.isEmpty
                          ? '${students[index].sessions.admissionNumberPrefix}${students[index].genAdmissionNumber}'
                          : '${students[index].sessions.admissionNumberPrefix}${students[index].admissionNumber}'),
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
            ViewStudentsPage._navigateToViewStudentsDetailScreen(context, students, index, false);
            // Add 9 lines from here...
          }, // ... to
          onLongPress: (){
            ViewStudentsPage.showOptionsModalBottomSheet(context: context, students: students, index: index, fees: false);
          },// here.// ... to here.
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Students> students;
  CustomSearchDelegate(this.students);

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
          ? students
          : students
          .where((p) =>
      ((p.admissionNumber.isNotEmpty)
          ? p.admissionNumber.toLowerCase().contains(query.toLowerCase())
          : p.genAdmissionNumber.toLowerCase().contains(query.toLowerCase())) ||
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
          return _buildRow(context, suggestionList, index);
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
          ? students
          : students
          .where((p) =>
      ((p.admissionNumber.isNotEmpty)
          ? p.admissionNumber.toLowerCase().contains(query.toLowerCase())
          : p.genAdmissionNumber.toLowerCase().contains(query.toLowerCase())) ||
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
          return _buildRow(context, suggestionList, index);
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
