import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/utils/system.dart';
import 'modals.dart';

class AddFormTeacherDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeachersBloc(updateProfileRepository: UpdateProfileRequest()),
      child: AddFormTeacherDialogPage(),
    );
  }
}

// ignore: must_be_immutable
class AddFormTeacherDialogPage extends StatelessWidget {
  TeachersBloc _teachersBloc;

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
    _teachersBloc.add(GetSessionsEvent(await getApiToken()));
    _teachersBloc.add(GetTermEvent(await getApiToken()));
    _teachersBloc.add(GetClassEvent(await getApiToken()));
  }
  @override
  Widget build(BuildContext context) {
    _teachersBloc = BlocProvider.of<TeachersBloc>(context);
    _viewSpinnerValues();
    return Container(
      height: 350,
      child: Form(
        key: _formKey,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
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
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 30.0,
                                left: 10.0,
                                right: 10.0),
                            child: Text("Add Form Teacher",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          BlocListener<TeachersBloc, TeachersStates>(
                            listener: (BuildContext context, TeachersStates state) {
                              if (state is ClassSelected) {
                                classDropdownValue = state.clas;
                              } else if (state is ClassLoaded) {
                                classSpinnerItems.addAll(state.clas[0]);
                                classSpinnerIds.addAll(state.clas[1]);
                                logPrint(state.clas.toString());
                              }
                            },
                            child: BlocBuilder<TeachersBloc, TeachersStates>(
                              builder: (BuildContext context, TeachersStates state) {
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
                                                  _teachersBloc.add(SelectClassEvent(data));
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
                                    (state is TeachersLoading)
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
                          BlocListener<TeachersBloc, TeachersStates>(
                            listener: (BuildContext context, TeachersStates state) {
                              if (state is SessionSelected) {
                                sessionDropdownValue = state.session;
                              } else if (state is SessionsLoaded) {
                                sessionSpinnerItems.addAll(state.sessions[0]);
                                sessionSpinnerIds.addAll(state.sessions[1]);
                                logPrint(state.sessions.toString());

                                _teachersBloc.add(SelectSessionEvent(state.sessions[2][1]));
                              }
                            },
                            child: BlocBuilder<TeachersBloc, TeachersStates>(
                              builder: (BuildContext context, TeachersStates state) {
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
                                                  _teachersBloc.add(SelectSessionEvent(data));
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
                                    (state is TeachersLoading)
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

                          BlocListener<TeachersBloc, TeachersStates>(
                            listener: (BuildContext context, TeachersStates state) {
                              if (state is TermSelected) {
                                termDropdownValue = state.term;
                              } else if (state is TermsLoaded) {
                                termSpinnerItems.addAll(state.terms[0]);
                                termSpinnerIds.addAll(state.terms[1]);
                                logPrint(state.terms.toString());
                                _teachersBloc.add(SelectTermEvent(state.terms[2][1]));
                              }
                            },
                            child: BlocBuilder<TeachersBloc, TeachersStates>(
                              builder: (BuildContext context, TeachersStates state) {
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
                                                  _teachersBloc.add(SelectTermEvent(data));
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
                                    (state is TeachersLoading)
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
    );
  }

  bool validateSpinner() {
    bool valid = true;
    if (sessionDropdownValue == '---session---') {
      valid = false;
      showToast(message: 'Please select sesssion');
    }
    if (termDropdownValue =='---term---') {
      valid = false;
      showToast(message: 'Please select term');
    }
    if(classDropdownValue == '---class---'){
      valid = false;
      showToast(message: 'Please select class');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: (){
          if(_formKey.currentState.validate()){
            if(validateSpinner()){
              Navigator.pop(context, {'classId':classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)], 'termId':termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)], 'sessionId':sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]});
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
          child:  Text('Done', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
