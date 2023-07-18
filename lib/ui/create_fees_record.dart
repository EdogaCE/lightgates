import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/blocs/fees/fees_bloc.dart';
import 'package:school_pal/blocs/fees/fees_events.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class CreateFeesRecord extends StatelessWidget {
  final FeesRecord feesRecord;
  final String event;
  CreateFeesRecord({this.feesRecord, this.event});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FeesBloc(createFeesRepository: CreateFeesRequests()),
      child: CreateFeesRecordPage(feesRecord, event),
    );
  }
}

// ignore: must_be_immutable
class CreateFeesRecordPage extends StatelessWidget {
  final FeesRecord feesRecord;
  final String event;
  CreateFeesRecordPage(this.feesRecord, this.event);
  FeesBloc _feesBloc;

  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = ['0'];

  String termDropdownValue = '---term---';
  List<String> termSpinnerItems = ["---term---"];
  List<String> termSpinnerIds = ['0'];

  String typeDropdownValue = '---type---';
  List<String> typeSpinnerItems = ["---type---", 'Term', 'Session'];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  void _viewSpinnerValues() async {
    _feesBloc.add(GetSessionsEvent(await getApiToken()));
    _feesBloc.add(GetTermsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _viewSpinnerValues();

    if(event=='Update'){
      titleController.text=feesRecord.title;
      descriptionController.text=feesRecord.description;
      if(typeSpinnerItems.contains(feesRecord.type))
      typeDropdownValue=toSentenceCase(feesRecord.type);
    }

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("${toSentenceCase(event)} Fees Record", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
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
                              BlocListener<FeesBloc, FeesStates>(
                                listener: (BuildContext context, FeesStates state) {
                                  if (state is TypeSelected) {
                                    typeDropdownValue = state.type;
                                  }
                                },
                                child: BlocBuilder<FeesBloc, FeesStates>(
                                  builder: (BuildContext context, FeesStates state) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0),
                                          child: Text("Select fee type",
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
                                                  color: MyColors.primaryColor,
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
                                                value: typeDropdownValue,
                                                icon: Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 24,
                                                elevation: 16,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                                underline: Container(
                                                  height: 0,
                                                  color: MyColors.primaryColor,
                                                ),
                                                onChanged: (String data) {
                                                  _feesBloc.add(SelectTypeEvent(data));
                                                },
                                                items: typeSpinnerItems
                                                    .map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<
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
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: titleController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter title.';
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
                                      Icon(Icons.title, color: Colors.blue),
                                      labelText: 'Title',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              BlocListener<FeesBloc, FeesStates>(
                                listener: (BuildContext context, FeesStates state) {
                                  if (state is SessionSelected) {
                                    sessionDropdownValue = state.session;
                                  } else if (state is SessionsLoaded) {
                                    sessionSpinnerItems.addAll(state.sessions[0]);
                                    sessionSpinnerIds.addAll(state.sessions[1]);
                                    if(event=='Update'){
                                      try{
                                        _feesBloc.add(SelectSessionEvent(sessionSpinnerItems[sessionSpinnerIds.indexOf(feesRecord.sessionId)]));
                                      } on NoSuchMethodError{}
                                    }else{
                                      _feesBloc.add(SelectSessionEvent(state.sessions[2][1]));
                                    }
                                  }
                                },
                                child: BlocBuilder<FeesBloc, FeesStates>(
                                  builder: (BuildContext context, FeesStates state) {
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(
                                                      color: MyColors.primaryColor,
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
                                                    icon: Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18),
                                                    underline: Container(
                                                      height: 0,
                                                      color: MyColors.primaryColor,
                                                    ),
                                                    onChanged: (String data) {
                                                      _feesBloc.add(SelectSessionEvent(data));
                                                    },
                                                    items: sessionSpinnerItems
                                                        .map<
                                                        DropdownMenuItem<
                                                            String>>((String
                                                    value) {
                                                      return DropdownMenuItem<
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

                              BlocListener<FeesBloc, FeesStates>(
                                listener: (BuildContext context, FeesStates state) {
                                  if (state is TermSelected) {
                                    termDropdownValue = state.term;
                                  } else if (state is TermsLoaded) {
                                    termSpinnerItems.addAll(state.terms[0]);
                                    termSpinnerIds.addAll(state.terms[1]);

                                    if(event=='Update'){
                                      try{
                                        _feesBloc.add(SelectTermEvent(termSpinnerItems[termSpinnerIds.indexOf(feesRecord.termId)]));
                                      } on NoSuchMethodError{}
                                    }else{
                                      _feesBloc.add(SelectTermEvent(state.terms[2][1]));
                                    }
                                  }
                                },
                                child: BlocBuilder<FeesBloc, FeesStates>(
                                  builder: (BuildContext context, FeesStates state) {
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(
                                                      color: MyColors.primaryColor,
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
                                                      color: MyColors.primaryColor,
                                                    ),
                                                    onChanged: (String data) {
                                                      _feesBloc.add(SelectTermEvent(data));
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter description.';
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
                                      prefixIcon: Icon(Icons.description,
                                          color: Colors.blue),
                                      labelText: 'Description',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
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
                    child: _sendButtonFill(context, event),
                  ),
                ),
                BlocListener<FeesBloc, FeesStates>(
                  listener: (BuildContext context, FeesStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    } else if (state is FeesNetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is FeesViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is FeeRecordCreated) {
                      Navigator.pop(context, state.message);
                    } else if (state is FeeRecordUpdated) {
                      Navigator.pop(context, state.message);
                    }
                  },
                  child: BlocBuilder<FeesBloc, FeesStates>(
                    builder: (BuildContext context, FeesStates state) {
                      return Container();
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
    if (typeDropdownValue == '---type---') {
      valid = false;
      showToast(message: 'Please select type');
    }
    if (sessionDropdownValue == '---session---') {
      valid = false;
      showToast(message: 'Please select session');
    }
    if (termDropdownValue =='---term---') {
      valid = false;
      showToast(message: 'Please select term');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context, String eventTitle) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              if(event=='Update'){
                _feesBloc.add(UpdateFeeRecordEvent(
                    feesRecord.id,
                    titleController.text,
                    typeDropdownValue.toLowerCase(),
                    descriptionController.text,
                    termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                    sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]
                ));
              }else{
                _feesBloc.add(CreateFeeRecordEvent(
                    titleController.text,
                    typeDropdownValue.toLowerCase(),
                    descriptionController.text,
                    termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                    sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)]
                ));
              }
            }
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
          child:  Text(eventTitle, style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
