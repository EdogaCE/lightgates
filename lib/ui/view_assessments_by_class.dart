import 'package:flutter/material.dart';
import 'package:school_pal/blocs/assessments/assessments.dart';
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_assessments_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_assessments.dart';
import 'package:school_pal/ui/view_assessments_by_subject.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewAssessmentsByClass extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewAssessmentsByClass({this.loggedInAs, this.classes});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AssessmentsBloc(viewAssessmentsRepository: ViewAssessmentsRequest()),
      child: ViewAssessmentsByClassPage(loggedInAs, classes),
    );
  }
}

// ignore: must_be_immutable
class ViewAssessmentsByClassPage extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewAssessmentsByClassPage(this.loggedInAs, this.classes);
  AssessmentsBloc _assessmentsBloc;
  List<Assessments> _assessments;
  List<String> _class = new List();
  String userId;

  void _viewAssessments() async {
    userId=await getUserId();
    _assessmentsBloc.add(ViewAssessmentsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _assessmentsBloc = BlocProvider.of<AssessmentsBloc>(context);
    _viewAssessments();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewAssessments();
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
                    title: Text("Assignments"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset((loggedInAs!=MyStrings.student)
                              ?"lib/assets/images/classes.svg"
                              :"lib/assets/images/assessment1.svg")
                      ),
                    )),
              ),
              _classGrid(context)
            ],
          )),
      floatingActionButton: (loggedInAs==MyStrings.teacher)?FloatingActionButton(
        heroTag: "Add Assessment",
        onPressed: () {
          _navigateToAddEditAssessmentScreen(context: context, type: 'Add', loggedInAs: loggedInAs);
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ):Container(),
    );
  }

  Widget _classGrid(context) {
    return BlocListener<AssessmentsBloc, AssessmentsStates>(
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
        } else if (state is AssessmentsLoaded) {
          _assessments = state.assessments;
          if(loggedInAs==MyStrings.teacher){
            for (var classes in state.assessments){
              if ((!_class.contains(classes.classDetail))&& userId==classes.teacherId) {
                _class.add(classes.classDetail);
              }
            }
          }else if(loggedInAs==MyStrings.school){
            for (var classes in state.assessments) {
              if (!_class.contains(classes.classDetail)) {
                _class.add(classes.classDetail);
              }
            }
          }else{
            final categoryAssessmentsList =_assessments
                .where((p) => (p.classDetail.contains(classes)))
                .toList();
            Navigator.pop(context);
            _navigateToAssessmentBySubjectScreen(context, categoryAssessmentsList, classes);
          }
        }
      },
      child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is AssessmentsInitial) {
            return buildInitialScreen();
          } else if (state is AssessmentsLoading) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildLoadingScreen();
          } else if (state is AssessmentsLoaded) {
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
              onTap: () => _viewAssessments(),
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
              final categoryAssessmentsList = (loggedInAs==MyStrings.teacher)?_assessments
                  .where((p) => (p.classDetail.contains(classes[index]))&&(p.teacherId==userId))
                  .toList():_assessments
                  .where((p) => (p.classDetail.contains(classes[index])))
                  .toList();
              _navigateToAssessmentBySubjectScreen(context, categoryAssessmentsList, classes[index]);
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

  _navigateToAddEditAssessmentScreen({BuildContext context, List<Assessments> assessments, int index, String type, String loggedInAs}) async {
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AddEditAssessments(assessments: assessments, index: index, type: type, loggedInAs: loggedInAs)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _viewAssessments();
    }
  }

  _navigateToAssessmentBySubjectScreen(
      BuildContext context, List<Assessments> assessments, String classes) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewAssessmentsBySubject(assessments, loggedInAs, userId, classes)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _viewAssessments();
    }
  }
}
