import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/results/results.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_results_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_attendance.dart';
import 'package:school_pal/ui/add_behavioural_skills.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/view_class_results.dart';
import 'package:school_pal/ui/view_result_comments.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ResultViewOption extends StatelessWidget {
  final String title;
  final String type;
  final String loggedInAs;
  final bool cumulative;
  ResultViewOption({this.title, this.type, this.loggedInAs, this.cumulative});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResultsBloc(viewResultsRepository: ViewResultsRequest()),
      child: ResultViewOptionPage(title, type, loggedInAs, cumulative),
    );
  }
}

// ignore: must_be_immutable
class ResultViewOptionPage extends StatelessWidget {
  final String title;
  final String type;
  final String loggedInAs;
  final bool cumulative;
  ResultViewOptionPage(this.title, this.type, this.loggedInAs, this.cumulative);

  ResultsBloc _resultsBloc;

  String classDropdownValue = '---class---';
  List<String> classSpinnerItems = ["---class---"];
  List<String> classSpinnerIds = ['0'];

  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = ['0'];

  String termDropdownValue = '---term---';
  List<String> termSpinnerItems = ["---term---"];
  List<String> termSpinnerIds = ['0'];

  final _formKey = GlobalKey<FormState>();

  void _viewSpinnerValues() async {
    _resultsBloc.add(GetSessionsEvent(await getApiToken()));
    _resultsBloc.add(GetTermEvent(await getApiToken()));
    if((loggedInAs==MyStrings.teacher)&&(type=='behavioural skills' || type=='attendance')){
      _resultsBloc.add(GetFormTeacherClassEvent(await getApiToken(), await getUserId()));
    }else{
      if(loggedInAs!=MyStrings.teacher){
        _resultsBloc.add(GetClassEvent(await getApiToken()));
      }else{
        _resultsBloc.add(GetTeacherClassEvent(await getApiToken(), await getUserId()));
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    _resultsBloc = BlocProvider.of<ResultsBloc>(context);
    _viewSpinnerValues();
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text((loggedInAs!=MyStrings.student)?'View ${toSentenceCase(title)}'
              :'Check Result'
              , style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Animator(
                    repeats: 1,
                    duration: Duration(seconds: 2),
                    builder: (context, anim, child) => Opacity(
                      opacity: anim.value,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                          SvgPicture.asset((loggedInAs!=MyStrings.student)
                              ?"lib/assets/images/result1.svg"
                              :"lib/assets/images/result2.svg",
                            alignment: Alignment.topCenter,
                          )
                      ),
                    ),
                  ),
                ),
                BlocListener<ResultsBloc, ResultsStates>(
                  listener: (BuildContext context, ResultsStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if (state is ClassResultLoaded) {
                      getUserId().then((userId) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewClassResults(classResults: state.classResults, type: type, loggedInAs: loggedInAs, userId: userId)),
                        );
                      });
                    } else if (state is NetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is ViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    }else if (state is StudentResultLoaded) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewLoader(
                              url: 'https://docs.google.com/viewer?url=${state.studentResult.downloadLink}',
                              downloadLink: state.studentResult.downloadLink,
                              title: state.studentResult.fileName,
                            )),
                      );
                    }else if (state is StudentsAttendanceInterfaceLoaded) {
                      getUserId().then((userId){
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddAttendance(values: {'userId':userId,
                            'classId':classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                            'termId':termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                            'sessionId':sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]},
                              attendanceHeader: state.attendanceInterface[0],
                              attendance: state.attendanceInterface..removeAt(0))),
                        );
                      });
                    }else if (state is StudentsBehaviouralSkillsInterfaceLoaded) {
                      getUserId().then((userId){
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddBehaviouralSkills(values: {'userId':userId,
                            'classId':classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                            'termId':termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                            'sessionId':sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]},
                              behaviouralSkillsHeader: state.behaviouralSkillsInterface[0],
                              behaviouralSkills: state.behaviouralSkillsInterface..removeAt(0))),
                        );
                      });
                    }
                  },
                  child: BlocBuilder<ResultsBloc, ResultsStates>(
                    builder: (BuildContext context, ResultsStates state) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0, bottom: 55.0),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    (loggedInAs==MyStrings.school&&type=='behavioural skills')
                                        ?Container():BlocListener<ResultsBloc, ResultsStates>(
                                      listener: (BuildContext context, ResultsStates state) {
                                        if (state is ClassSelected) {
                                          classDropdownValue = state.clas;
                                        } else if (state is ClassLoaded) {
                                          classSpinnerItems.addAll(state.clas[0]);
                                          classSpinnerIds.addAll(state.clas[1]);
                                          logPrint(state.clas.toString());
                                        }
                                      },
                                      child: BlocBuilder<ResultsBloc, ResultsStates>(
                                        builder: (BuildContext context, ResultsStates state) {
                                          return Stack(
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 30.0),
                                                    child: Text("Select class",
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: MyColors.primaryColor,
                                                            fontWeight:
                                                            FontWeight.normal)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 8.0,
                                                        right: 8.0,
                                                        bottom: 8.0,
                                                        top: 1.0),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.5),
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        border: Border.all(
                                                            color: Colors.deepPurpleAccent,
                                                            style: BorderStyle.solid,
                                                            width: 0.80),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 20.0),
                                                        child: DropdownButton<String>(
                                                          isExpanded: true,
                                                          value: classDropdownValue,
                                                          icon: Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18),
                                                          underline: Container(
                                                            height: 0,
                                                            color: Colors.deepPurpleAccent,
                                                          ),
                                                          onChanged: (String data) {
                                                            _resultsBloc.add(SelectClassEvent(data));
                                                          },
                                                          items: classSpinnerItems.map<DropdownMenuItem<
                                                              String>>((String value) {return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              (state is Loading)
                                                  ? Align(
                                                alignment: Alignment.center,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      100.0),
                                                  child: Container(
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(20.0),
                                                        child:
                                                        CircularProgressIndicator(
                                                          valueColor:
                                                          new AlwaysStoppedAnimation<
                                                              Color>(
                                                              Colors
                                                                  .deepPurple),
                                                          backgroundColor:
                                                          Colors.pink,
                                                        ),
                                                      )),
                                                ),
                                              ) : Container(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    BlocListener<ResultsBloc, ResultsStates>(
                                      listener: (BuildContext context, ResultsStates state) {
                                        if (state is SessionSelected) {
                                          sessionDropdownValue = state.session;
                                        } else if (state is SessionsLoaded) {
                                          sessionSpinnerItems.addAll(state.sessions[0]);
                                          sessionSpinnerIds.addAll(state.sessions[1]);
                                          logPrint(state.sessions.toString());

                                          _resultsBloc.add(SelectSessionEvent(state.sessions[2][1]));
                                        }
                                      },
                                      child: BlocBuilder<ResultsBloc, ResultsStates>(
                                        builder: (BuildContext context, ResultsStates state) {
                                          return Stack(
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 30.0),
                                                    child: Text("Select session",
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: MyColors.primaryColor,
                                                            fontWeight:
                                                            FontWeight.normal)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 8.0,
                                                        right: 8.0,
                                                        bottom: 8.0,
                                                        top: 1.0),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.5),
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        border: Border.all(
                                                            color: Colors.deepPurpleAccent,
                                                            style: BorderStyle.solid,
                                                            width: 0.80),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 20.0),
                                                        child: DropdownButton<String>(
                                                          isExpanded: true,
                                                          value: sessionDropdownValue,
                                                          icon: Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18),
                                                          underline: Container(
                                                            height: 0,
                                                            color: Colors.deepPurpleAccent,
                                                          ),
                                                          onChanged: (String data) {
                                                            _resultsBloc.add(SelectSessionEvent(data));
                                                          },
                                                          items: sessionSpinnerItems.map<DropdownMenuItem<
                                                              String>>((String value) {return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              (state is Loading)
                                                  ? Align(
                                                alignment: Alignment.center,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      100.0),
                                                  child: Container(
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(20.0),
                                                        child:
                                                        CircularProgressIndicator(
                                                          valueColor:
                                                          new AlwaysStoppedAnimation<
                                                              Color>(
                                                              Colors
                                                                  .deepPurple),
                                                          backgroundColor:
                                                          Colors.pink,
                                                        ),
                                                      )),
                                                ),
                                              )
                                                  : Container(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),

                                    !cumulative?BlocListener<ResultsBloc, ResultsStates>(
                                      listener: (BuildContext context, ResultsStates state) {
                                        if (state is TermSelected) {
                                          termDropdownValue = state.term;
                                        } else if (state is TermsLoaded) {
                                          termSpinnerItems.addAll(state.terms[0]);
                                          termSpinnerIds.addAll(state.terms[1]);
                                          logPrint(state.terms.toString());
                                          _resultsBloc.add(SelectTermEvent(state.terms[2][1]));
                                        }
                                      },
                                      child: BlocBuilder<ResultsBloc, ResultsStates>(
                                        builder: (BuildContext context, ResultsStates state) {
                                          return Stack(
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 30.0),
                                                    child: Text("Select term",
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: MyColors.primaryColor,
                                                            fontWeight:
                                                            FontWeight.normal)),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 8.0,
                                                        right: 8.0,
                                                        bottom: 8.0,
                                                        top: 1.0),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.5),
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        border: Border.all(
                                                            color: Colors.deepPurpleAccent,
                                                            style: BorderStyle.solid,
                                                            width: 0.80),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 20.0),
                                                        child: DropdownButton<String>(
                                                          isExpanded: true,
                                                          value: termDropdownValue,
                                                          icon: Icon(Icons.arrow_drop_down),
                                                          iconSize: 24,
                                                          elevation: 16,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18),
                                                          underline: Container(
                                                            height: 0,
                                                            color: Colors.deepPurpleAccent,
                                                          ),
                                                          onChanged: (String data) {
                                                            _resultsBloc.add(SelectTermEvent(data));
                                                          },
                                                          items: termSpinnerItems.map<DropdownMenuItem<
                                                              String>>((String value) {return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              (state is Loading)
                                                  ? Align(
                                                alignment: Alignment.center,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      100.0),
                                                  child: Container(
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(20.0),
                                                        child:
                                                        CircularProgressIndicator(
                                                          valueColor:
                                                          new AlwaysStoppedAnimation<
                                                              Color>(
                                                              Colors
                                                                  .deepPurple),
                                                          backgroundColor:
                                                          Colors.pink,
                                                        ),
                                                      )),
                                                ),
                                              )
                                                  : Container(),
                                            ],
                                          );
                                        },
                                      ),
                                    ):Container(),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _sendButtonFill(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  bool validateSpinner() {
    bool valid = true;
    if (sessionDropdownValue == '---session---') {
      valid = false;
      showToast(message: 'Please select sesssion');
    }
    if (!cumulative && termDropdownValue =='---term---') {
      valid = false;
      showToast(message: 'Please select term');
    }
    if(classDropdownValue == '---class---'&&
        !(loggedInAs==MyStrings.school&&type=='behavioural skills')){
      valid = false;
      showToast(message: 'Please select class');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () async{
          switch (loggedInAs){
            case MyStrings.student:
              {
                if (_formKey.currentState.validate()) {
                  if (validateSpinner()) {
                    if(cumulative){
                      _resultsBloc.add(ViewStudentCumulativeResultEvent(await getUserId(),
                          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                          sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
                          'save'));
                    }else{
                      _resultsBloc.add(ViewStudentResultEvent(await getUserId(),
                          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                          termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                          sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
                          'save'));
                    }
                  }
                }
                break;
              }
            case MyStrings.teacher :
              {
                if (validateSpinner()) {
                  if(type=='behavioural skills'){
                    getResultCommentSwitch().then((commentSwitch){
                      if(commentSwitch=='average'){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewResultComments(
                            loggedInAs: loggedInAs,
                            pageIds: {'classId':classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                              'termId':termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                              'sessionId':sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]},)),
                        );
                      }else{
                        getUserId().then((userId){
                          _resultsBloc.add(ViewStudentsBehaviouralSkillsInterfaceEvent(userId,
                              classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                              termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                              sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]));
                        });
                      }
                    });
                  }else if(type=='attendance'){
                    getUserId().then((userId){
                      _resultsBloc.add(ViewStudentsAttendanceInterfaceEvent(userId,
                          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                          termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                          sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]));
                    });
                  }else{
                    _resultsBloc.add(ViewClassResultsEvent(sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
                        termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                        classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)], type));
                  }

                }
                break;
              }
            case MyStrings.school :
              {
                if (_formKey.currentState.validate()) {
                  if (validateSpinner()) {
                    if(type=='behavioural skills'){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewResultComments(
                          loggedInAs: loggedInAs,
                          pageIds: {'classId':classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
                          'termId':termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                          'sessionId':sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]},)),
                      );
                    }else{
                      _resultsBloc.add(ViewClassResultsEvent(sessionSpinnerIds[
                      sessionSpinnerItems.indexOf(sessionDropdownValue)],
                          termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)], type));
                    }
                  }
                }
                break;
              }
          }
          print(classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)]);
          print(termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)]);
          print(sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]);
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
          child:  Text((loggedInAs!=MyStrings.student)? 'Continue'
              :'Check Result', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

