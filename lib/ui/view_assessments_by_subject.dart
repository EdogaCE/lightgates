import 'package:flutter/material.dart';
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/view_assessments.dart';
import 'package:school_pal/res/strings.dart';

class ViewAssessmentsBySubject extends StatelessWidget {
  final List<Assessments> _assessments;
  final String loggedInAs;
  final String userId;
  final String classes;
  ViewAssessmentsBySubject(this._assessments, this.loggedInAs, this.userId, this.classes);

  List<String> _subject() {
    List<String> subject = List();
    for (var sub in _assessments) {
      if (!subject.contains(sub.subjectDetail)) {
        subject.add(sub.subjectDetail);
      }
    }
    return subject;
  }

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text(_classes[0].label.toUpperCase())),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(_assessments.isNotEmpty?_assessments.first.classDetail.toUpperCase():'Assignments'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/assessment1.svg")),
                    )),
              ),
              (_subject().isNotEmpty)
                  ?_buildLoadedScreen(context, _subject())
                  :buildNODataScreen(),
            ],
          )),
      /*floatingActionButton: FloatingActionButton(
        heroTag: "Add classd",
        onPressed: () {
          showCreateOrEditClassModalDialog(context: context, type: "Add");
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),*/
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

  Widget _buildLoadedScreen(
      BuildContext context, List<String> subject) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildClassCategory(context, subject, index);
      }, childCount: subject.length),
    );
  }

  Widget _buildClassCategory(
      BuildContext context, List<String> subject, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: RaisedButton(
            onPressed: () {
              final categoryAssessmentsList = _assessments
                  .where((p) => (p.subjectDetail.contains(subject[index])))
                  .toList();
              _navigateToViewAssessmentScreen(context, categoryAssessmentsList, subject[index]);
            },
            color:
            (index + 1 < 5) ? Colors.red[200 * (index + 1 % 9)] : Colors.red,
            padding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                  width: 2.0, style: BorderStyle.solid, color: Colors.white),
              // borderRadius: new BorderRadius.circular(50.0),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subject[index].toUpperCase(),
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

  _navigateToViewAssessmentScreen(
      BuildContext context, List<Assessments> assessments, String subject) async {
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewAssessments(assessments: assessments, classes: classes, loggedInAs: loggedInAs, userId: userId, subject: subject)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
     Navigator.pop(context, result);
    }
  }
}