import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/learning_materials/learning_materials.dart';
import 'package:school_pal/models/learning_materials.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_learning_materials_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_learning_materials.dart';
import 'package:school_pal/ui/view_learning_materials_by_subject.dart';
import 'package:school_pal/utils/system.dart';

class ViewLearningMaterialsByClass extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewLearningMaterialsByClass({this.loggedInAs, this.classes});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LearningMaterialsBloc(viewLearningMaterialsRepository: ViewLearningMaterialsRequest()),
      child: ViewLearningMaterialsByClassPage(loggedInAs, classes),
    );
  }
}

// ignore: must_be_immutable
class ViewLearningMaterialsByClassPage extends StatelessWidget {
  final String loggedInAs;
  final String classes;
  ViewLearningMaterialsByClassPage(this.loggedInAs, this.classes);
  LearningMaterialsBloc _learningMaterialsBloc;
  List<LearningMaterials> _learningMaterials;
  List<String> _class = new List();
  String userId;

  void _viewLearningMaterials() async {
    userId=await getUserId();
    _learningMaterialsBloc.add(ViewLearningMaterialsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _learningMaterialsBloc = BlocProvider.of<LearningMaterialsBloc>(context);
    _viewLearningMaterials();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewLearningMaterials();
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
                    title: Text("Learning Materials"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset((loggedInAs!=MyStrings.student)
                              ?"lib/assets/images/classes.svg"
                              :"lib/assets/images/learning1.svg")
                      ),
                    )),
              ),
              _classGrid(context)
            ],
          )),
      floatingActionButton: (loggedInAs!=MyStrings.student)?FloatingActionButton(
        heroTag: "Add material",
        onPressed: () {
          _navigateToAddEditLearningMaterialScreen(context: context, learningMaterials: _learningMaterials, type: "Add", loggedInAs: loggedInAs);
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ):Container(),
    );
  }

  Widget _classGrid(context) {
    return BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
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
        } else if (state is LearningMaterialsLoaded) {
          _learningMaterials = state.learningMaterials;
          if(loggedInAs==MyStrings.teacher){
            for (var classes in state.learningMaterials){
              if ((!_class.contains(classes.classDetail))&& userId==classes.teacherId) {
                _class.add(classes.classDetail);
              }
            }
          }else if(loggedInAs==MyStrings.school){
            for (var classes in state.learningMaterials) {
              if (!_class.contains(classes.classDetail)) {
                _class.add(classes.classDetail);
              }
            }
          }else{
           final learningMaterialsList =_learningMaterials
                .where((p) => (p.classDetail.contains(classes)))
                .toList();
           Navigator.pop(context);
            _navigateToMaterialsBySubjectScreen(context, learningMaterialsList, classes);
          }
        }
      },
      child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is LearningMaterialsInitial) {
            return buildInitialScreen();
          } else if (state is LearningMaterialsLoading) {
            return (_class.isNotEmpty) ?_buildLoadedScreen(context, _class) :buildLoadingScreen();
          } else if (state is LearningMaterialsLoaded) {
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
              onTap: () => _viewLearningMaterials(),
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
              final learningMaterialsList = (loggedInAs==MyStrings.teacher)?_learningMaterials
                  .where((p) => (p.classDetail.contains(classes[index]))&&(p.teacherId==userId))
                  .toList():_learningMaterials
                  .where((p) => (p.classDetail.contains(classes[index])))
                  .toList();
              _navigateToMaterialsBySubjectScreen(context, learningMaterialsList, classes[index]);
            },
            color:
            (index + 1 < 5) ? Colors.lightBlue[200 * (index + 1 % 9)] : Colors.lightBlue,
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

  _navigateToAddEditLearningMaterialScreen(
      {BuildContext context, List<LearningMaterials> learningMaterials, String type, int index, String loggedInAs}) async {
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AddEditLearningMaterials(learningMaterials: learningMaterials, type: type, index: index, loggedInAs: loggedInAs)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _viewLearningMaterials();
    }
  }

  _navigateToMaterialsBySubjectScreen(
      BuildContext context, List<LearningMaterials> learningMaterials, String classes) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewLearningMaterialsBySubject(learningMaterials, loggedInAs, userId, classes)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _viewLearningMaterials();
    }
  }
}

