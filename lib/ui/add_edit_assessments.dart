import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/assessments/assessments.dart';
import 'package:school_pal/blocs/assessments/assessments_bloc.dart';
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/add_edit_assessment_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:school_pal/utils/file_picker.dart';

class AddEditAssessments extends StatelessWidget {
  final String type;
  final List<Assessments> assessments;
  final int index;
  final String loggedInAs;
  AddEditAssessments({this.assessments, this.index, this.type, this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AssessmentsBloc(assessmentRepository: AssessmentRequests()),
      child: AddEditAssessmentsPage(assessments, index, type, loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class AddEditAssessmentsPage extends StatelessWidget {
  final String type;
  final int index;
  final List<Assessments> assessments;
  final String loggedInAs;
  AddEditAssessmentsPage(this.assessments, this.index, this.type, this.loggedInAs);
  AssessmentsBloc _assessmentsBloc;

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final instructionController = TextEditingController();
  final contentController = TextEditingController();

  String classDropdownValue = '---class---';
  List<String> classSpinnerItems = ["---class---"];
  List<String> classSpinnerIds = ['0'];

  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = ['0'];

  String termDropdownValue = '---term---';
  List<String> termSpinnerItems = ["---term---"];
  List<String> termSpinnerIds = ['0'];

  String subjectDropdownValue = '---subject---';
  List<String> subjectSpinnerItems = ["---subject---"];
  List<String> subjectSpinnerIds = ['0'];

  String typeDropdownValue = '---type---';
  List<String> typeSpinnerItems = ["---type---", 'project', 'assessment'];

  String submissionModeDropdownValue = '---submission mode---';
  List<String> submissionModeSpinnerItems = ["---submission mode---", 'offline']; //'online'

  final formatDate = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime selectedSubmissionDate = DateTime.now();
  Future<Null> _selectedSubmissionDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedSubmissionDate,
        firstDate: DateTime(selectedSubmissionDate.year - 500),
        lastDate: DateTime(selectedSubmissionDate.year + 500));
    if (picked != null && picked != selectedSubmissionDate)
      _assessmentsBloc.add(ChangeSubmissionDateEvent(picked));
  }

  List<File> files=List();
  List<String> fileName=List();
  List<String> existingFiles=List();
  List<String> filesToDelete=List();

  void _viewSpinnerValues() async {
    _assessmentsBloc.add(GetSessionsEvent(await getApiToken()));
    _assessmentsBloc.add(GetTermsEvent(await getApiToken()));
    if(loggedInAs==MyStrings.teacher){
      _assessmentsBloc.add(GetTeacherClassesEvent(await getApiToken(), await getUserId()));
      _assessmentsBloc.add(GetTeacherSubjectsEvent(await getApiToken(), await getUserId()));
    }else{
      _assessmentsBloc.add(GetClassesEvent(await getApiToken()));
      _assessmentsBloc.add(GetSubjectsEvent(await getApiToken()));
    }

  }

  void _populateForm(){
    if(type=='Edit'){
      print(assessments[index].date.split('=>').last);
      selectedSubmissionDate=convertDateFromString(assessments[index].date.split('=>').last.trim().split(' ').first);
      typeDropdownValue=assessments[index].type;
      submissionModeDropdownValue=assessments[index].submissionMode;
      titleController.text=assessments[index].title;
      instructionController.text=assessments[index].instructions;
      contentController.text=assessments[index].content;
      if(assessments[index].file.isNotEmpty)
        existingFiles=assessments[index].file.split(',');

      if(typeSpinnerItems.contains(assessments[index].type.toLowerCase()))
        typeDropdownValue=assessments[index].type.toLowerCase();

      if(subjectSpinnerItems.contains(assessments[index].sessionMode.toLowerCase()))
        sessionDropdownValue=assessments[index].sessionMode.toLowerCase();

    }
  }

  @override
  Widget build(BuildContext context) {

    _assessmentsBloc = BlocProvider.of<AssessmentsBloc>(context);
    _populateForm();
    _viewSpinnerValues();

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () async {
                  _assessmentsBloc.add(SelectFilesEvent(await pickMultiFiles(context)));
                }),
          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text('${toSentenceCase(type)} Assessment', style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
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
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener:
                                    (BuildContext context, AssessmentsStates state) {
                                  if (state is FilesSelected) {
                                    files.clear();
                                    files.addAll(state.files);
                                  }else  if (state is FileRemoved) {
                                    files.remove(state.file);
                                  } else  if (state is ExistingFileRemoved) {
                                    existingFiles.remove(state.file);
                                    filesToDelete.add(state.file);
                                  } else  if (state is AssessmentAdded) {
                                    Navigator.pop(context, state.message);
                                  } else  if (state is AssessmentUpdated) {
                                    Navigator.pop(context, state.message);
                                  } else  if (state is AssessmentFileAdded) {
                                    fileName.add(state.fileName);
                                    print(state.fileName);
                                  } else  if (state is Processing) {
                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
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
                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder:
                                      (BuildContext context, AssessmentsStates state) {
                                    return Column(
                                      children: [
                                        Wrap(
                                          children:
                                          _buildExistingFilesList(existingFiles),
                                        ),
                                        Wrap(
                                          children:
                                          _buildFilesList(files),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is ClassSelected) {
                                    classDropdownValue = state.clas;
                                  } else if (state is ClassesLoaded) {
                                    classSpinnerItems.addAll(state.classes[0]);
                                    classSpinnerIds.addAll(state.classes[1]);

                                    try{
                                      if(type=='Edit')
                                        _assessmentsBloc.add(SelectClassEvent(assessments[index].classDetail));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
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
                                                    value: classDropdownValue,
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
                                                      _assessmentsBloc.add(SelectClassEvent(data));
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
                                        (state is AssessmentsLoading)
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

                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is SubjectSelected) {
                                    subjectDropdownValue = state.subject;
                                  } else if (state is SubjectsLoaded) {
                                    subjectSpinnerItems.addAll(state.subjects[0]);
                                    subjectSpinnerIds.addAll(state.subjects[1]);

                                    try{
                                      if(type=='Edit')
                                        _assessmentsBloc.add(SelectSubjectEvent(assessments[index].subjectDetail));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
                                    return Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Text("Select subject",
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
                                                    value: subjectDropdownValue,
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
                                                      _assessmentsBloc.add(SelectSubjectEvent(data));
                                                    },
                                                    items: subjectSpinnerItems.map<DropdownMenuItem<
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
                                        (state is AssessmentsLoading)
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
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is SessionSelected) {
                                    sessionDropdownValue = state.session;
                                  } else if (state is SessionsLoaded) {
                                    sessionSpinnerItems.addAll(state.sessions[0]);
                                    sessionSpinnerIds.addAll(state.sessions[1]);

                                    try{
                                      if(sessionSpinnerItems.contains(state.sessions[2][1]))
                                      _assessmentsBloc.add(SelectSessionEvent(state.sessions[2][1]));
                                      if(type=='Edit')
                                        if(sessionSpinnerItems.contains(assessments[index].session))
                                        _assessmentsBloc.add(SelectSessionEvent(assessments[index].session));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
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
                                                      _assessmentsBloc.add(SelectSessionEvent(data));
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
                                        (state is AssessmentsLoading)
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

                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is TermSelected) {
                                    termDropdownValue = state.term;
                                  } else if (state is TermsLoaded) {
                                    termSpinnerItems.addAll(state.terms[0]);
                                    termSpinnerIds.addAll(state.terms[1]);

                                    try{
                                      _assessmentsBloc.add(SelectTermEvent(state.terms[2][1]));
                                      if(type=='Edit')
                                        _assessmentsBloc.add(SelectTermEvent(assessments[index].term));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
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
                                                      _assessmentsBloc.add(SelectTermEvent(data));
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
                                        (state is AssessmentsLoading)
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
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is TypeSelected) {
                                    typeDropdownValue = state.type;
                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
                                    return Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Text("Select type",
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
                                                      _assessmentsBloc.add(SelectTypeEvent(data));
                                                    },
                                                    items: typeSpinnerItems.map<DropdownMenuItem<
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
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener: (BuildContext context, AssessmentsStates state) {
                                  if (state is SubmissionModeSelected) {
                                    submissionModeDropdownValue = state.mode;
                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder: (BuildContext context, AssessmentsStates state) {
                                    return Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Text("Select submission mode",
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
                                                    value: submissionModeDropdownValue,
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
                                                      _assessmentsBloc.add(SelectSubmissionModeEvent(data));
                                                    },
                                                    items: submissionModeSpinnerItems.map<DropdownMenuItem<
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
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              BlocListener<AssessmentsBloc, AssessmentsStates>(
                                listener:
                                    (BuildContext context, AssessmentsStates state) {
                                  if (state is SubmissionDateChanged) {
                                    selectedSubmissionDate = state.date;
                                  }
                                },
                                child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
                                  builder:
                                      (BuildContext context, AssessmentsStates state) {
                                    return GestureDetector(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 30.0),
                                            child: Text("Submission Date",
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
                                              width: double.maxFinite,
                                              padding: EdgeInsets.all(15.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                BorderRadius.circular(25.0),
                                                border: Border.all(
                                                    color:
                                                    MyColors.primaryColor,
                                                    style: BorderStyle.solid,
                                                    width: 0.80),
                                              ),
                                              child: Text(
                                                  "${selectedSubmissionDate.toLocal()}"
                                                      .split(' ')[0],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                      FontWeight.normal)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _selectedSubmissionDate(context),
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
                                      return 'Please enter assessment title.';
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: instructionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter your instrictions.';
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
                                      labelText: 'Instructions',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: contentController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(25.0),
                                        ),
                                      ),
                                      //icon: Icon(Icons.email),
                                      prefixIcon: Icon(Icons.description,
                                          color: Colors.blue),
                                      labelText: 'Content',
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
                    child: _sendButtonFill(context),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _buildFilesList(List<File> files) {
    List<Widget> choices = List();
    files.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item.path.split('/').last),
              Icon(
                Icons.cancel,
                size: 15,
              )
            ],
          ),
          selected: false,
          onSelected: (selected) {
            print(item.path);
            _assessmentsBloc.add(RemoveFileEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  _buildExistingFilesList(List<String> files) {
    List<Widget> choices = List();
    files.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item),
              Icon(
                Icons.cancel,
                size: 15,
              )
            ],
          ),
          selected: false,
          onSelected: (selected) {
            _assessmentsBloc.add(RemoveExitingFileEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  bool validateSpinner() {
    bool valid = true;
    if (sessionDropdownValue == '---session---') {
      valid = false;
      showToast(message: 'Please select session');
    }
    if (termDropdownValue =='---term---') {
      valid = false;
      showToast(message: 'Please select term');
    }
    if(classDropdownValue == '---class---'){
      valid = false;
      showToast(message: 'Please select class');
    }
    if(subjectDropdownValue == '---subject---'){
      valid = false;
      showToast(message: 'Please select subject');
    }
    if(typeDropdownValue == '---type---'){
      valid = false;
      showToast(message: 'Please select type');
    }
    if(submissionModeDropdownValue == '---submission mode---'){
      valid = false;
      showToast(message: 'Please select submission mode');
    }
    return valid;
  }

  void _upLoadFiles() async{
    fileName.clear();
    for (File file in files){
      print(file);
      String fileExtension=file.path.split('.').last;
      String mainFile;
      if(fileExtension=='jpg'|| fileExtension=='png' || fileExtension=='gif' || fileExtension=='jpeg'){
        mainFile='data:image/jpeg;base64,${base64Encode(await compressFile(file))}';
      }else{
        mainFile='data:image/jpeg;base64,${base64Encode(file.readAsBytesSync())}';
      }
      _assessmentsBloc.add(AddAssessmentFilesEvent((type=='Edit')?assessments[index].id:'',mainFile, fileExtension));
      print(file.path.split('.').last);
    }

    if(type=='Edit'){
      print(filesToDelete);
      _assessmentsBloc.add(UpdateAssessmentEvent(assessments[index].id,
          termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
          sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
          subjectSpinnerIds[subjectSpinnerItems.indexOf(subjectDropdownValue)],
          await getUserId(), titleController.text, typeDropdownValue,
          submissionModeDropdownValue, instructionController.text,
          fileName, contentController.text, formatDate.format(selectedSubmissionDate.toLocal()), filesToDelete));
    }else{
      _assessmentsBloc.add(AddAssessmentEvent(termSpinnerIds[termSpinnerItems.indexOf(termDropdownValue)],
          sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)],
          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
          subjectSpinnerIds[subjectSpinnerItems.indexOf(subjectDropdownValue)],
          await getUserId(), titleController.text, typeDropdownValue, submissionModeDropdownValue,
          instructionController.text, fileName, contentController.text, formatDate.format(selectedSubmissionDate.toLocal())));
    }

  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              _upLoadFiles();
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
          child:  Text('Done', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}


