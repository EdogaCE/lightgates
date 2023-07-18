import 'package:flutter/material.dart';
import 'package:school_pal/blocs/salary/salary.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/create_update_salary_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:intl/intl.dart';
import 'general.dart';

class CreateSalaryRecord extends StatelessWidget {
  final SalaryRecord salaryRecord;
  final String event;
  CreateSalaryRecord({this.salaryRecord, this.event});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SalaryBloc(createSalaryRepository: CreateSalaryRequests()),
      child: CreateSalaryRecordPage(salaryRecord, event),
    );
  }
}

// ignore: must_be_immutable
class CreateSalaryRecordPage extends StatelessWidget {
  final SalaryRecord salaryRecord;
  final String event;
  CreateSalaryRecordPage(this.salaryRecord, this.event);
  SalaryBloc _salaryBloc;
  
  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = ['0'];

  String termDropdownValue = '---term---';
  List<String> termSpinnerItems = ["---term---"];
  List<String> termSpinnerIds = ['0'];

  String frequencyDropdownValue = '---frequency---';
  List<String> frequencySpinnerItems = ["---frequency---", 'Yearly', 'Monthly', 'Weekly', 'Daily'];
  
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final formatDate = DateFormat("yyyy-MM-dd");
  DateTime selectedDateFrom = DateTime.now();
  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year - 5),
        lastDate: DateTime(selectedDateFrom.year + 5));
    if (picked != null && picked != selectedDateFrom)
      _salaryBloc.add(ChangeDateFromEvent(picked));
  }
  DateTime selectedDateTo = DateTime.now();
  Future<Null> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year - 5),
        lastDate: DateTime(selectedDateTo.year + 5));
    if (picked != null && picked != selectedDateTo)
      _salaryBloc.add(ChangeDateToEvent(picked));
  }


  void _viewSpinnerValues() async {
    _salaryBloc.add(GetSessionsEvent(await getApiToken()));
    _salaryBloc.add(GetTermsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _salaryBloc = BlocProvider.of<SalaryBloc>(context);
    _viewSpinnerValues();

    if(event=='Update'){
      titleController.text=salaryRecord.title;
      descriptionController.text=salaryRecord.description;
      frequencyDropdownValue=toSentenceCase(salaryRecord.frequency);
      selectedDateFrom=convertDateFromString(salaryRecord.date.split(' to ')[0]);
      selectedDateTo=convertDateFromString(salaryRecord.date.split(' to ')[1]);
    }

    return Scaffold(
        appBar: AppBar(
          /*actions: <Widget>[
            IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  _loadMultipleImages();
                }),
          ],*/
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Salary Record", style: TextStyle(color: MyColors.primaryColor)),
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
                              BlocListener<SalaryBloc, SalaryStates>(
                                listener: (BuildContext context, SalaryStates state) {
                                  if (state is FrequencySelected) {
                                    frequencyDropdownValue = state.frequency;
                                  }
                                },
                                child: BlocBuilder<SalaryBloc, SalaryStates>(
                                  builder: (BuildContext context, SalaryStates state) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0),
                                          child: Text("Select payment frequency",
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
                                                value: frequencyDropdownValue,
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
                                                  _salaryBloc.add(SelectFrequencyEvent(data));
                                                },
                                                items: frequencySpinnerItems
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
                              BlocListener<SalaryBloc, SalaryStates>(
                                listener: (BuildContext context, SalaryStates state) {
                                  if (state is SessionSelected) {
                                    sessionDropdownValue = state.session;
                                  } else if (state is SessionsLoaded) {
                                    sessionSpinnerItems.addAll(state.sessions[0]);
                                    sessionSpinnerIds.addAll(state.sessions[1]);
                                    if(event=='Update'){
                                      _salaryBloc.add(SelectSessionEvent(salaryRecord.sessions.sessionDate));
                                    }else{
                                      _salaryBloc.add(SelectSessionEvent(state.sessions[2][1]));
                                    }
                                  }
                                },
                                child: BlocBuilder<SalaryBloc, SalaryStates>(
                                  builder: (BuildContext context, SalaryStates state) {
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
                                                      _salaryBloc.add(SelectSessionEvent(data));
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
                                        (state is SalaryLoading)
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

                              BlocListener<SalaryBloc, SalaryStates>(
                                listener: (BuildContext context, SalaryStates state) {
                                  if (state is TermSelected) {
                                    termDropdownValue = state.term;
                                  } else if (state is TermsLoaded) {
                                    termSpinnerItems.addAll(state.terms[0]);
                                    termSpinnerIds.addAll(state.terms[1]);

                                    if(event=='Update'){
                                      _salaryBloc.add(SelectTermEvent(salaryRecord.terms.term));
                                    }else{
                                      _salaryBloc.add(SelectTermEvent(state.terms[2][1]));
                                    }
                                  }
                                },
                                child: BlocBuilder<SalaryBloc, SalaryStates>(
                                  builder: (BuildContext context, SalaryStates state) {
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
                                                      _salaryBloc.add(SelectTermEvent(data));
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
                                        (state is SalaryLoading)
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

                              Row(
                                children: <Widget>[
                                  BlocListener<SalaryBloc, SalaryStates>(
                                    listener: (BuildContext context,
                                        SalaryStates state) {
                                      if (state is DateFromChanged) {
                                        selectedDateFrom = state.from;
                                      }
                                    },
                                    child:
                                    BlocBuilder<SalaryBloc, SalaryStates>(
                                      builder: (BuildContext context,
                                          SalaryStates state) {
                                        return Expanded(
                                          child: GestureDetector(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 30.0),
                                                  child: Text("From",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                          MyColors.primaryColor,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                      bottom: 8.0,
                                                      top: 1.0),
                                                  child: Container(
                                                    width: double.maxFinite,
                                                    padding:
                                                    EdgeInsets.all(15.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                      border: Border.all(
                                                          color: MyColors.primaryColor,
                                                          style:
                                                          BorderStyle.solid,
                                                          width: 0.80),
                                                    ),
                                                    child: Text(
                                                        "${selectedDateFrom.toLocal()}"
                                                            .split(' ')[0],
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                            Colors.black87,
                                                            fontWeight:
                                                            FontWeight
                                                                .normal)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () =>
                                                _selectDateFrom(context),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  BlocListener<SalaryBloc, SalaryStates>(
                                    listener: (BuildContext context,
                                        SalaryStates state) {
                                      if (state is DateToChanged) {
                                        selectedDateTo = state.to;
                                      }
                                    },
                                    child:
                                    BlocBuilder<SalaryBloc, SalaryStates>(
                                      builder: (BuildContext context,
                                          SalaryStates state) {
                                        return Expanded(
                                          child: GestureDetector(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 30.0),
                                                  child: Text("To",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                          MyColors.primaryColor,
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                      bottom: 8.0,
                                                      top: 1.0),
                                                  child: Container(
                                                    width: double.maxFinite,
                                                    padding:
                                                    EdgeInsets.all(15.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                      border: Border.all(
                                                          color: MyColors.primaryColor,
                                                          style:
                                                          BorderStyle.solid,
                                                          width: 0.80),
                                                    ),
                                                    child: Text(
                                                        "${selectedDateTo.toLocal()}"
                                                            .split(' ')[0],
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                            Colors.black87,
                                                            fontWeight:
                                                            FontWeight
                                                                .normal)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () => _selectDateTo(context),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                BlocListener<SalaryBloc, SalaryStates>(
                  listener: (BuildContext context, SalaryStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    } else if (state is SalaryNetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content:
                          Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    } else if (state is SalaryViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content:
                          Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    } else if (state is SalaryRecordCreated) {
                      Navigator.pop(context, state.message);
                    } else if (state is SalaryRecordUpdated) {
                      Navigator.pop(context, state.message);
                    }
                  },
                  child: BlocBuilder<SalaryBloc, SalaryStates>(
                    builder: (BuildContext context, SalaryStates state) {
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
    if (frequencyDropdownValue == '---frequency---') {
      valid = false;
      showToast(message: 'Please select frequency');
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
                _salaryBloc.add(UpdateSalaryRecordEvent(
                    salaryRecord.id,
                    frequencyDropdownValue.toLowerCase(),
                    sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
                    termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                    formatDate.format(selectedDateFrom.toLocal()),
                    formatDate.format(selectedDateTo.toLocal()),
                    titleController.text,
                    descriptionController.text
                ));
              }else{
                _salaryBloc.add(CreateSalaryRecordEvent(
                    frequencyDropdownValue.toLowerCase(),
                    sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
                    termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
                    formatDate.format(selectedDateFrom.toLocal()),
                    formatDate.format(selectedDateTo.toLocal()),
                    titleController.text,
                    descriptionController.text
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
