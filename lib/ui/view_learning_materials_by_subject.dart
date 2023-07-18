import 'package:flutter/material.dart';
import 'package:school_pal/models/learning_materials.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/ui/view_learning_materials.dart';
import 'package:school_pal/res/strings.dart';

class ViewLearningMaterialsBySubject extends StatelessWidget {
  final List<LearningMaterials> _learningMaterials;
  final String loggedInAs;
  final String userId;
  final String classes;
  ViewLearningMaterialsBySubject(this._learningMaterials, this.loggedInAs, this.userId, this.classes);

  List<String> _subject() {
    List<String> subject = List();
    for (var sub in _learningMaterials) {
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
                    title: Text(_learningMaterials.isNotEmpty?_learningMaterials.first.classDetail.toUpperCase():"Learning Materials"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Center(
                            child: SvgPicture.asset(
                                "lib/assets/images/learning1.svg")),
                      ),
                    )),
              ),
              (_subject().isNotEmpty)
                  ?_buildLoadedScreen(context, _subject())
              :buildNODataScreen(),
            ],
          )),
    );
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
      BuildContext context, List<String> subjects) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildClassCategory(context, subjects, index);
      }, childCount: subjects.length),
    );
  }

  Widget _buildClassCategory(
      BuildContext context, List<String> subjects, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: RaisedButton(
            onPressed: () {
              final learningMaterialsList = _learningMaterials
                  .where((p) => (p.subjectDetail.contains(subjects[index])))
                  .toList();
              _navigateToViewAssessmentScreen(context, learningMaterialsList, subjects[index]);
            },
            color:
            (index + 1 < 5) ? Colors.pink[200 * (index + 1 % 9)] : Colors.pink,
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
                  child: Text(subjects[index].toUpperCase(),
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
      BuildContext context, List<LearningMaterials> learningMaterials, String subject) async {
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewLearningMaterials(learningMaterials: learningMaterials, userId: userId, loggedInAs: loggedInAs, classes: classes, subject: subject,)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

}