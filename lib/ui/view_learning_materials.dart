import 'package:flutter/material.dart';
import 'package:school_pal/blocs/learning_materials/learning_materials.dart';
import 'package:school_pal/models/learning_materials.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/get/view_learning_materials_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_learning_materials.dart';
import 'package:school_pal/ui/learning_materials_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewLearningMaterials extends StatelessWidget {
  final List<LearningMaterials> learningMaterials;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  ViewLearningMaterials({this.learningMaterials, this.loggedInAs, this.userId, this.classes, this.subject});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LearningMaterialsBloc(viewLearningMaterialsRepository: ViewLearningMaterialsRequest()),
      child: ViewLearningMaterialsPage(learningMaterials, loggedInAs, userId, classes, subject),
    );
  }
}

// ignore: must_be_immutable
class ViewLearningMaterialsPage extends StatelessWidget {
  List<LearningMaterials> _learningMaterials;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  ViewLearningMaterialsPage(this._learningMaterials, this.loggedInAs, this.userId, this.classes, this.subject);

  static LearningMaterialsBloc _learningMaterialsBloc;
  static void _viewLearningMaterials() async {
    _learningMaterialsBloc.add(ViewLearningMaterialsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _learningMaterialsBloc = BlocProvider.of<LearningMaterialsBloc>(context);
    final RefreshController _refreshController = RefreshController();
    _viewLearningMaterials();
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
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(_learningMaterials, loggedInAs, userId, classes, subject));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text(_classes[0].label.toUpperCase())),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(_learningMaterials[0].classDetail.toUpperCase()),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/learning2.svg")
                      ),
                    )),
              ),
              BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
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
                    _learningMaterials = (loggedInAs==MyStrings.teacher)?state.learningMaterials
                        .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject)&&(p.teacherId==userId))
                        .toList():state.learningMaterials
                        .where((p) => (p.classDetail.contains(classes)&&(p.subjectDetail==subject)))
                        .toList();
                  }
                },
                child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
                  builder: (context, state) {
                    //Todo: note builder returns widget
                    return _buildLoadedScreen(context, _learningMaterials);
                  },
                ),
              )
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

  Widget _buildLoadedScreen(BuildContext context, List<LearningMaterials> learningMaterials) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, learningMaterials, index, loggedInAs, userId, classes, subject);
      }, childCount: learningMaterials.length),
    );
  }
}

Widget _buildRow(BuildContext context, List<LearningMaterials> learningMaterials, int index, String loggedInAs, String userId, String classes, String subject) {
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
                      child: Text(toSentenceCase(learningMaterials[index].title),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    (learningMaterials[index].teacherDetail!='general')?Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('By: ${learningMaterials[index].teacherDetail}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ):Container(),
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            _navigateToLearningMaterialDetailsScreen(context: context, learningMaterials: learningMaterials, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
          },
          onLongPress: (){
            if(loggedInAs==MyStrings.teacher)
              _showOptionsModalBottomSheet(context: context, learningMaterials: learningMaterials, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
          },
        ),
      ),
    ),
  );
}

void _showOptionsModalBottomSheet({BuildContext context, List<LearningMaterials> learningMaterials, int index, String loggedInAs, String userId, String classes, String subject}) {
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
                  _navigateToLearningMaterialDetailsScreen(context: context, learningMaterials: learningMaterials, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject);
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
                    _navigateToAddEditLearningMaterialScreen(context: context, learningMaterials: learningMaterials, index: index, type: 'Edit', loggedInAs: loggedInAs);
                  }),
            ],
          ),
        );
      });
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
    ViewLearningMaterialsPage._viewLearningMaterials();
  }
}

_navigateToLearningMaterialDetailsScreen(
    {BuildContext context, List<LearningMaterials> learningMaterials, int index, String loggedInAs, String userId, String classes, String subject}) async {
  final result = await  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            LearningMaterialsDetails(learningMaterials: learningMaterials, index: index, loggedInAs: loggedInAs, userId: userId, classes: classes, subject: subject)),
  );

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if (result != null) {
    ViewLearningMaterialsPage._viewLearningMaterials();
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<LearningMaterials> learningMaterials;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  CustomSearchDelegate(this.learningMaterials, this.loggedInAs, this.userId, this.classes, this.subject);

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
          ? learningMaterials
          : learningMaterials
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
          ? learningMaterials
          : learningMaterials
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
