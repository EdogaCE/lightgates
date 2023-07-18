import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/results/results.dart';
import 'package:school_pal/models/class_results.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_results_requests.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/system.dart';
import 'view_subject_results.dart';

class ViewClassResults extends StatelessWidget {
  final List<ClassResults> classResults;
  final String type;
  final String loggedInAs;
  final String userId;
  ViewClassResults({this.classResults, this.type, this.loggedInAs, this.userId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResultsBloc(viewResultsRepository: ViewResultsRequest()),
      child: ViewClassResultsPage(classResults, type, loggedInAs, userId),
    );
  }
}

// ignore: must_be_immutable
class ViewClassResultsPage extends StatelessWidget {
  List<ClassResults> classResults;
  final String type;
  final String loggedInAs;
  final String userId;
  ViewClassResultsPage(this.classResults, this.type, this.loggedInAs, this.userId);

  ResultsBloc _resultsBloc;

  _viewClassResults() async {
    _resultsBloc.add(ViewClassResultsEvent(
        classResults[0].sessions.id, classResults[0].terms.id,
        classResults[0].classes.id, type));
  }
  @override
  Widget build(BuildContext context) {
    _resultsBloc = BlocProvider.of<ResultsBloc>(context);
    final _refreshController = RefreshController();
    _viewClassResults();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewClassResults();
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
                            delegate: CustomSearchDelegate((loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, _resultsBloc, type, loggedInAs));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('Class Results'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset(
                              "lib/assets/images/assessment1.svg")
                      ),
                    )),
              ),
              _buildSalaryRecord(context)
            ],
          )),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<ResultsBloc, ResultsStates>(
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
        } else if (state is ClassResultLoaded) {
          classResults = state.classResults;

        }
      },
      child: BlocBuilder<ResultsBloc, ResultsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          //Todo: note builder returns widget
          if (state is ResultsInitial) {
            try{
              return ((loggedInAs==MyStrings.teacher)&&classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)
                  ?buildNODataScreen()
                  :_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, type);
            }on NoSuchMethodError{
              return buildInitialScreen();
            }

          } else if (state is Processing) {
            try{
              return ((loggedInAs==MyStrings.teacher)&&classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)
                  ?buildNODataScreen()
                  :_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, type);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is ClassResultLoaded) {
            return ((loggedInAs==MyStrings.teacher)&&state.classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)?buildNODataScreen():_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?state.classResults.where((p) => p.teachers.id==(userId)).toList():state.classResults, type);
          } else if (state is ViewError) {
            try{
              return ((loggedInAs==MyStrings.teacher)&&classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)
                  ?buildNODataScreen()
                  :_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, type);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          } else if (state is NetworkErr) {
            try{
              return ((loggedInAs==MyStrings.teacher)&&classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)
                  ?buildNODataScreen()
                  :_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, type);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return ((loggedInAs==MyStrings.teacher)&&classResults.where((p) => p.teachers.id==(userId)).toList().isEmpty)
                  ?buildNODataScreen()
                  :_buildLoadedScreen(context, (loggedInAs==MyStrings.teacher)?classResults.where((p) => p.teachers.id==(userId)).toList():classResults, type);
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
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          MyColors.primaryColor),
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
              onTap: () => _viewClassResults(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context,
      List<ClassResults> classResults, String type) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, classResults, _resultsBloc, index, type, loggedInAs);
      }, childCount: classResults.length),
    );
  }
}

Widget _buildRow(BuildContext context, List<ClassResults> classResults, ResultsBloc resultsBloc, int index, String type, String loggedInAs) {
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
                borderRadius: BorderRadius.circular(2.0),
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
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(classResults[index].confirmationStatus),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('${classResults[index].classes.label} ${classResults[index].classes.category} ${classResults[index].classes.level}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(classResults[index].subjects.title),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('${toSentenceCase(classResults[index].teachers.lName)} ${toSentenceCase(classResults[index].teachers.fName)} ${toSentenceCase(classResults[index].teachers.mName)}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(classResults[index].terms.term),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: (classResults[index].terms.status=='active')?Colors.green:Colors.black,
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(toSentenceCase(classResults[index].sessions.sessionDate),
                              style: TextStyle(
                                  fontSize: 16,
                                  color:(classResults[index].sessions.status=='active') ?Colors.green:Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            _navigateToViewSubjectResultScreen(context: context, resultsBloc: resultsBloc, classResults: classResults[index], type: type, loggedInAs: loggedInAs);
          }, // ... to here.// ... to here.
        ),
      ),
    ),
  );
}
_navigateToViewSubjectResultScreen({BuildContext context, ResultsBloc resultsBloc, ClassResults classResults, String type, String loggedInAs}) async {

  final bool result = await  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ViewSubjectResults(classResults: classResults, type: type, loggedInAs: loggedInAs,)),
  );

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if(result!=null){
    //Refresh after update
    if(result){
      resultsBloc.add(ViewClassResultsEvent(
          classResults.sessions.id, classResults.terms.id,
          classResults.classes.id, type));
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<ClassResults> classResults;
  final ResultsBloc resultsBloc;
  final String type;
  final String loggedInAs;
  CustomSearchDelegate(this.classResults, this.resultsBloc, this.type, this.loggedInAs);

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
          ? classResults
          : classResults
          .where((p) =>
      (p.subjects.title.contains(query)) || (p.teachers.fName.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, resultsBloc, index, type, loggedInAs);
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
          ? classResults
          : classResults
          .where((p) =>
      (p.subjects.title.contains(query)) || (p.teachers.fName.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, resultsBloc, index, type, loggedInAs);
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
