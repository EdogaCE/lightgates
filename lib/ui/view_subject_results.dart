import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/results/results.dart';
import 'package:school_pal/models/class_results.dart';
import 'package:school_pal/models/grade.dart';
import 'package:school_pal/models/subject_results.dart';
import 'package:school_pal/requests/get/view_results_requests.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/posts/result_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ViewSubjectResults extends StatelessWidget {
  final ClassResults classResults;
  final String type;
  final String loggedInAs;
  ViewSubjectResults({this.classResults, this.type, this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResultsBloc(viewResultsRepository: ViewResultsRequest(), resultRepository: ResultRequests()),
      child: ViewSubjectResultsPage(classResults, type, loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class ViewSubjectResultsPage extends StatelessWidget {
  final ClassResults classResults;
  final String type;
  final String loggedInAs;
  ViewSubjectResultsPage(this.classResults, this.type, this.loggedInAs);
  bool _updated=false;
  ResultsBloc _resultsBloc;
  SubjectResult subjectResults;

  _viewSubjectResults() async {
    _resultsBloc.add(ViewSubjectResultsEvent(
        classResults.id, classResults.subjects.id, classResults.sessions.id,
        classResults.terms.id, classResults.classes.id, type));
  }

  List<String> resultHeader=List();
  Map resultData=Map();

  List<String> studentsUniqueIds=List();
  List<String> studentsResults=List();

  @override
  Widget build(BuildContext context) {
    _resultsBloc = BlocProvider.of<ResultsBloc>(context);
    final _refreshController = RefreshController();
    _viewSubjectResults();
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewSubjectResults();
              _refreshController.refreshCompleted();
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    (type=='pending' && loggedInAs=='school')?Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: DropdownButton<String>(
                        icon: Icon( Icons.more_vert, color: Colors.white,),
                        items: <String>['Approve', 'Decline'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          switch(value){
                            case 'Approve':{
                              //logPrint(resultData.toString());
                              //logPrint(resultHeader.toString());
                              _resultsBloc.add(ApproveResultsEvent(subjectResults.classResults.id, subjectResults.classResults.sessions.id, subjectResults.classResults.terms.id, subjectResults.classResults.classes.id, subjectResults.classResults.subjects.id, subjectResults.classResults.teachers.id, resultHeader, resultData, studentsUniqueIds, studentsResults));
                              break;
                            }
                            case 'Decline':{
                              _showDeclineModalDialog(context: context, resultBloc: _resultsBloc, subjectResults: subjectResults);
                              break;
                            }
                          }
                        },
                      ),
                    ):Container()
                  ],
                  pinned: true,
                  expandedHeight: 250.0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text('${toSentenceCase(classResults.subjects.title)} Result'),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: Center(
                          child: SvgPicture.asset(
                              "lib/assets/images/assessment1.svg")
                      )),
                ),
                _buildSalaryRecord(context)
              ],
            )),
      ),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<ResultsBloc, ResultsStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is Loading) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if (state is NetworkErr) {
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
        } else if (state is SubjectResultLoaded) {
          Scaffold.of(context).removeCurrentSnackBar();
          subjectResults = state.subjectResults;
        } else if (state is ResultApproved) {
          _updated=true;
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is ResultDeclined) {
          _updated=true;
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }
      },
      child: BlocBuilder<ResultsBloc, ResultsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          //Todo: note builder returns widget
          if (state is ResultsInitial) {
            return buildInitialScreen();
          } else if (state is Processing) {
            try{
              return _buildLoadedScreen(context, subjectResults);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is SubjectResultLoaded) {
            return _buildLoadedScreen(context, state.subjectResults);
          }else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, subjectResults);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          } else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, subjectResults);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, subjectResults);
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
              onTap: () => _viewSubjectResults(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context,
      SubjectResult subjectResults) {
    return SliverList(
      delegate: SliverChildListDelegate([
          SingleChildScrollView(
            child: Card(
              // margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              elevation: 1,
              color: MyColors.primaryColorShade500,
              child: _buildRow(context, subjectResults),
            ),
          ),
        ])
    );
  }

  Widget _buildRow(BuildContext context, SubjectResult subjectResult) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildCells(context, []..addAll(subjectResult.resultDetail[0]), [], '',  subjectResult.resultDetail[0].length, 0, true),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRows(context, []..addAll(subjectResult.resultDetail)..removeAt(0), subjectResult.grade, subjectResult.resultDetail.length-1),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildRows(BuildContext context, List<List<String>> resultDetail, List<Grade> grade,  int count) {
    List<String> totalScore=totalScores(resultDetail);
    return List.generate(
      count,
          (index) => Column(
        children:(type=='pending')?_buildCells(context, resultDetail[index], summary(resultDetail[index][resultDetail[index].length-4], grade), position(resultDetail[index][resultDetail[index].length-4], totalScore), resultDetail[index].length, index, false):_buildConfirmCells(context, resultDetail[index], resultDetail[index].length, index, false),
      ),
    );
  }

  List<Widget> _buildCells(BuildContext context, List<String> result, List<String> gradeScore, String position,  int count, int rowIndex, bool title) {
    if(title){
      resultHeader.clear();
      for(int i=4; i<result.length; i++){
        resultHeader.add(result[i]);
      }
    }else{
      List<String> data=List();
      for(int i=4; i<result.length; i++){
        if(i==result.length-3)
         data.add( gradeScore[0]);
          else if(i==result.length-2)
            data.add( gradeScore[1]);
            else if(i==result.length-1)
              data.add(position);
            else
          data.add(result[i]);
      }
      resultData[result[2]]=data;
      /// for mobile upload
      studentsUniqueIds.add(result[2]);
      studentsResults.add(data.join(','));
    }
    return List.generate(
      count,
          (index) => Container(
        alignment: Alignment.center,
        width: 150.0,
        height: 60.0,
        color: (rowIndex<=0&&title)?MyColors.primaryColorShade500:(rowIndex%2!=0)?Colors.white70:Colors.white,
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.all(5.0),
        child: Text("${(!title&&(index==count-3))?gradeScore[0]:(!title&&(index==count-2))?gradeScore[1]:(!title&&(index==count-1))?position:result[index]}",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: (!title)?Colors.black87:Colors.white,
                fontWeight: (!title)?FontWeight.normal:FontWeight.bold)),
      ),
    );
  }

  List<Widget> _buildConfirmCells(BuildContext context, List<String> result, int count, int rowIndex, bool title) {
    return List.generate(
      count,
          (index) => Container(
        alignment: Alignment.center,
        width: 150.0,
        height: 60.0,
        color: (rowIndex%2!=0)?Colors.white70:Colors.white,
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.all(5.0),
        child: Text(result[index],
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: (!title)?Colors.black87:Colors.white,
                fontWeight: (!title)?FontWeight.normal:FontWeight.bold)),
      ),
    );
  }

  List<String> summary(String total, List<Grade> grade){
    List<String> rntData=List();
    for(int i=0; i<grade.length; i++){
      if((int.parse(total)>=int.parse(grade[i].startLimit))&&(int.parse(total)<=int.parse(grade[i].endLimit)))
        rntData=[grade[i].grade, grade[i].remark];
    }
    if(rntData.isEmpty)
      rntData=['Out of range', 'Out of range'];

    return rntData;
  }

  List<String> totalScores(List<List<String>> resultDetail){
    List<String> rntData=List();
    for(List<String> score in resultDetail){
      rntData.add(score[score.length-4]);
    }
    return rntData;
  }

  String position(String totalScore, List<String> totalScores){
    int count=0;
    for(String total in totalScores){
      if(int.parse(totalScore)>int.parse(total)){
        count++;
      }
    }
    return ordinal(totalScores.length-count);
  }

  void _showDeclineModalDialog({BuildContext context, ResultsBloc resultBloc, SubjectResult subjectResults}) async {
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final data = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return  Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child:Container(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Reason For Decline',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your reason.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ),
                                ),
                                //icon: Icon(Icons.email),
                                prefixIcon:
                                Icon(Icons.label, color: MyColors.primaryColor),
                                labelText: "Reason for decline",
                                hintText: 'Reason for decline',
                                labelStyle: new TextStyle(color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.maxFinite,
                          //height: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () async {
                              if(_formKey.currentState.validate()){
                                Navigator.pop(context, _textController.text);
                              }
                            },
                            textColor: Colors.white,
                            color: MyColors.primaryColor,
                            padding: const EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
                              child: const Text("Decline",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
          );
        });
    if (data != null) {
      print(data.toString());
      resultBloc.add(DeclineResultsEvent(subjectResults.classResults.id, await getUserId(), await getLoggedInAs(), data.toString()));
    }
  }
/*List<String> getRank(List<String> totalScores) {
  List<String> position=List();
  List<String> sortTotalScores = totalScores..sort();
  for (int i = 0; i < totalScores.length; i++) {
    for (int j = 0; i < sortTotalScores.length; j++) {
      if (totalScores[i] == sortTotalScores[j]) {
        i = j;
        break;
      }
    }
    position.add(ordinal(i + 1));
  }
  return position;
}*/

  Future<bool> _popNavigator(BuildContext context) async {
    if (_updated) {
      print("onwill goback");
      Navigator.pop(context, _updated);
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}

