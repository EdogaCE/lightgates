import 'package:flutter/material.dart';
import 'package:school_pal/blocs/assessments/assessments.dart';
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/get/view_assessments_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_assessments.dart';
import 'package:school_pal/ui/assessment_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewAssessments extends StatelessWidget {
  final List<Assessments> assessments;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  ViewAssessments({this.assessments, this.loggedInAs, this.classes, this.subject, this.userId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AssessmentsBloc(viewAssessmentsRepository: ViewAssessmentsRequest()),
      child: ViewAssessmentsPage(assessments, loggedInAs, classes, subject, userId),
    );
  }
}

// ignore: must_be_immutable
class ViewAssessmentsPage extends StatelessWidget {
  List<Assessments> _assessments;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  ViewAssessmentsPage(this._assessments, this.loggedInAs, this.classes, this.subject, this.userId);

  static AssessmentsBloc _assessmentsBloc;
  static void _viewAssessments() async {
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
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(_assessments, loggedInAs, userId, classes, subject));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text(_classes[0].label.toUpperCase())),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(_assessments[0].classDetail.toUpperCase()),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/assessment2.svg")
                      ),
                    )),
              ),
              BlocListener<AssessmentsBloc, AssessmentsStates>(
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
                    _assessments = (loggedInAs==MyStrings.teacher)?state.assessments
                        .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject)&&(p.teacherId==userId))
                        .toList():state.assessments
                        .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject))
                        .toList();

                  }
                },
                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                  builder: (context, state) {
                    //Todo: note builder returns widget
                    return  _buildLoadedScreen(context, _assessments);
                  },
                ),
              )
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

  Widget _buildLoadedScreen(BuildContext context, List<Assessments> assessments) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, assessments, index, loggedInAs, userId, classes, subject);
      }, childCount: assessments.length),
    );
  }
}

Widget _buildRow(BuildContext context, List<Assessments> assessments, int index, String loggedInAs, String userId, String classes, String subject) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 1,
        child: ListTile(
          title: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(assessments[index].type),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('By: ${assessments[index].teacherDetail}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: Icon(Icons.date_range, color: Colors.green, size: 15.0),
                            ),
                            Text(assessments[index].date.split("=>")[0],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0, left: 5.0),
                              child: Icon(Icons.date_range, color: Colors.red, size: 15.0),
                            ),
                            Text(assessments[index].date.split("=>")[1],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          ],)
                    ),
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            _navigateToAssessmentDetailScreen(context: context, assessments: assessments, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
          },
          onLongPress: (){
            if(loggedInAs==MyStrings.teacher)
              _showOptionsModalBottomSheet(context: context, assessments: assessments, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
          },
        ),
      ),
    ),
  );
}

void _showOptionsModalBottomSheet({BuildContext context, List<Assessments> assessments, int index, String loggedInAs, String userId, String classes, String subject}) {
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
                  _navigateToAssessmentDetailScreen(context: context, assessments: assessments, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
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
                    _navigateToAddEditAssessmentScreen(context: context, assessments: assessments, index: index, type: 'Edit', loggedInAs: loggedInAs);
                  }),
            ],
          ),
        );
      });
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
    ViewAssessmentsPage._viewAssessments();
  }
}

_navigateToAssessmentDetailScreen(
    {BuildContext context, List<Assessments> assessments, int index, String loggedInAs, String userId, String classes, String subject}) async {
  final result = await  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            AssessmentsDetails(assessments: assessments, index: index, loggedInAs: loggedInAs, userId: userId, subject: subject, classes: classes)),
  );

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if (result != null) {
    ViewAssessmentsPage._viewAssessments();
  }
}


class CustomSearchDelegate extends SearchDelegate {
  final List<Assessments> assessments;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  CustomSearchDelegate(this.assessments, this.loggedInAs, this.userId, this.classes, this.subject);

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
          ? assessments
          : assessments
          .where((p) =>
      (p.title.contains(query)) || (p.teacherDetail.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, index, loggedInAs, userId, classes, subject);
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
          ? assessments
          : assessments
          .where((p) =>
      (p.title.contains(query)) || (p.teacherDetail.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, index, loggedInAs, userId, classes, subject);
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
