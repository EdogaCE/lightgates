import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_students/students.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_students_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/view_students.dart';
import 'package:school_pal/utils/system.dart';

class ViewStudentsByClass extends StatelessWidget {
  final bool requireAdmissionNumber;
  ViewStudentsByClass({this.requireAdmissionNumber});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StudentsBloc(viewStudentsRepository: ViewStudentsRequest()),
      child: ViewStudentsByClassPage(this.requireAdmissionNumber),
    );
  }
}

// ignore: must_be_immutable
class ViewStudentsByClassPage extends StatelessWidget {
  final bool requireAdmissionNumber;
  ViewStudentsByClassPage(this.requireAdmissionNumber);

  List<Students> students;
  StudentsBloc _studentsBloc;
  List<String> _class = new List();

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
    return Scaffold(
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
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text("Classes Categorized")),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text("Students In A Class"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/classes.svg")
                      ),
                    )),
              ),
              _classGrid(context)
            ],
          )),
    );
  }

  Widget _classGrid(context) {
    return BlocListener<StudentsBloc, StudentsStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is ViewError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is StudentsLoaded) {
          students = state.students;
            for (var classes in state.students) {
              if (!_class.contains(classes.stClass)) {
                _class.add(classes.stClass);
              }
            }
        }
      },
      child: BlocBuilder<StudentsBloc, StudentsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is StudentsInitial) {
            return buildInitialScreen();
          } else if (state is StudentsLoading) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildLoadingScreen();
          } else if (state is StudentsLoaded) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildNODataScreen();
          }  else if (state is ViewError) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildNODataScreen();
          }else if (state is NetworkErr) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildNetworkErrorScreen();
          } else {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildInitialScreen();
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
              onTap: () => _viewStudents(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<String> classes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildClassCategory(context, classes, index);
      }, childCount: classes.length),
    );
  }

  Widget _buildClassCategory(
      BuildContext context, List<String> classes, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: RaisedButton(
            onPressed: () {
              final categoryStudentsList = students
                  .where((p) => (p.stClass.contains(classes[index])))
                  .toList();
              _navigateToViewStudentsScreen(context, categoryStudentsList,  classes[index], requireAdmissionNumber);
            },
            color:
            (index + 1 < 5) ? Colors.teal[200 * (index + 1 % 9)] : Colors.teal,
            padding: const EdgeInsets.all(0.0),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(width: 2.0, style: BorderStyle.solid, color: Colors.white),
              // borderRadius: new BorderRadius.circular(50.0),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(classes[index].toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )),
    );
  }

  _navigateToViewStudentsScreen(BuildContext context,List<Students> students, String classes, bool requireAdmissionNumber) async {

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewStudents(students: students, classes: classes, requireAdmissionNumber: requireAdmissionNumber)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      _viewStudents();
    }
  }
}

