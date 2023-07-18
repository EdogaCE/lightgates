import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/learning_materials/learning_materials.dart';
import 'package:school_pal/models/learning_materials.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/add_edit_learning_material_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/file_picker.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class AddEditLearningMaterials extends StatelessWidget {
  final String type;
  final int index;
  final List<LearningMaterials> learningMaterials;
  final String loggedInAs;
  AddEditLearningMaterials({this.learningMaterials, this.index, this.type, this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LearningMaterialsBloc(learningMaterialRepository: LearningMaterialRequests()),
      child: AddEditLearningMaterialsPage(learningMaterials, index, type, loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class AddEditLearningMaterialsPage extends StatelessWidget {
  final String type;
  final int index;
  final List<LearningMaterials> learningMaterials;
  final String loggedInAs;
  AddEditLearningMaterialsPage(this.learningMaterials, this.index, this.type, this.loggedInAs);
  LearningMaterialsBloc _learningMaterialsBloc;

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final youtubeLinkController = TextEditingController();
  final descriptionController = TextEditingController();

  List<String> youtubeLinkList = List();
  List<File> files=List();
  List<String> fileName=List();
  List<String> exitingFileName=List();
  List<String> filesToDelete=List();


  String classDropdownValue = '---class---';
  List<String> classSpinnerItems = ["---class---"];
  List<String> classSpinnerIds = ['0'];

  String subjectDropdownValue = '---subject---';
  List<String> subjectSpinnerItems = ["---subject---"];
  List<String> subjectSpinnerIds = ['0'];

  void _viewSpinnerValues() async {
    if(loggedInAs==MyStrings.teacher){
      _learningMaterialsBloc.add(GetTeacherClassesEvent(await getApiToken(), await getUserId()));
      _learningMaterialsBloc.add(GetTeacherSubjectsEvent(await getApiToken(), await getUserId()));
    }else{
      _learningMaterialsBloc.add(GetClassesEvent(await getApiToken()));
      _learningMaterialsBloc.add(GetSubjectsEvent(await getApiToken()));
    }
  }

  void _populateForm(){
    if(type=='Edit'){
      titleController.text=learningMaterials[index].title;
      descriptionController.text=learningMaterials[index].description;
      if(learningMaterials[index].video.isNotEmpty){
        youtubeLinkList=learningMaterials[index].video.split(',');
      }
      if(learningMaterials[index].file.isNotEmpty){
        exitingFileName=learningMaterials[index].file.split(',');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    _learningMaterialsBloc = BlocProvider.of<LearningMaterialsBloc>(context);
    _populateForm();
    _viewSpinnerValues();
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () async {
                  _learningMaterialsBloc.add(SelectFilesEvent(await pickMultiFiles(context)));
                }),
          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text('${toSentenceCase(type)} Learning Material', style: TextStyle(color: MyColors.primaryColor)),
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
                              BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
                                listener: (BuildContext context, LearningMaterialsStates state) {
                                  if (state is FilesSelected) {
                                    files.clear();
                                    files.addAll(state.files);
                                    print(files);
                                  } else  if (state is FileRemoved) {
                                    files.remove(state.file);
                                  } else  if (state is ExitingFileRemoved) {
                                    exitingFileName.remove(state.file);
                                    filesToDelete.add(state.file);
                                  } else if (state is Processing) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(minutes: 30),
                                        content: General.progressIndicator("Processing..."),
                                      ),
                                    );
                                  }else if (state is LearningMaterialAdded) {
                                    Navigator.pop(context, state.message);
                                  }else if (state is LearningMaterialUpdated) {
                                    Navigator.pop(context, state.message);
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
                                  }else if (state is LearningMaterialFileAdded) {
                                    print(state.fileName);
                                    fileName.add(state.fileName);
                                  }
                                },
                                child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
                                  builder: (BuildContext context, LearningMaterialsStates state) {
                                    return Column(
                                      children: [
                                        Wrap(
                                          children:
                                          _buildExitingFilesList(exitingFileName),
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
                              BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
                                listener: (BuildContext context, LearningMaterialsStates state) {
                                  if (state is ClassSelected) {
                                    classDropdownValue = state.clas;
                                  } else if (state is ClassesLoaded) {
                                    classSpinnerItems.addAll(state.classes[0]);
                                    classSpinnerIds.addAll(state.classes[1]);

                                    try{
                                      if(type=='Edit'&&classSpinnerItems.contains(learningMaterials[index].classDetail))
                                        _learningMaterialsBloc.add(SelectClassEvent(learningMaterials[index].classDetail));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
                                  builder: (BuildContext context, LearningMaterialsStates state) {
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
                                                      _learningMaterialsBloc.add(SelectClassEvent(data));
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
                                        (state is LearningMaterialsLoading)
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

                              BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
                                listener: (BuildContext context, LearningMaterialsStates state) {
                                  if (state is SubjectSelected) {
                                    subjectDropdownValue = state.subject;
                                  } else if (state is SubjectsLoaded) {
                                    subjectSpinnerItems.addAll(state.subjects[0]);
                                    subjectSpinnerIds.addAll(state.subjects[1]);

                                    try{
                                      if(type=='Edit'&& subjectDropdownValue.contains(learningMaterials[index].subjectDetail))
                                        _learningMaterialsBloc.add(SelectSubjectEvent(learningMaterials[index].subjectDetail));
                                    }on NoSuchMethodError{}

                                  }
                                },
                                child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
                                  builder: (BuildContext context, LearningMaterialsStates state) {
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
                                                    value: subjectDropdownValue,
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
                                                      _learningMaterialsBloc.add(SelectSubjectEvent(data));
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
                                        (state is LearningMaterialsLoading)
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
                                child: Column(
                                  children: <Widget>[
                                    BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
                                      listener: (BuildContext context, LearningMaterialsStates state) {
                                        if (state is LinkAddedToList) {
                                          if (state.link.isNotEmpty)
                                            youtubeLinkList.add(state.link);
                                        } else if (state
                                        is LinkRemovedFromList) {
                                          youtubeLinkList.remove(state.link);
                                        }
                                      },
                                      child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
                                        builder: (BuildContext context, LearningMaterialsStates state) {
                                          return Wrap(
                                            children:
                                            _buildLinkList(youtubeLinkList),
                                          );
                                        },
                                      ),
                                    ),
                                    TextFormField(
                                      controller: youtubeLinkController,
                                      keyboardType: TextInputType.url,
                                      validator: (value) {
                                        /* if (value.isEmpty) {
                                          return 'Please enter video link.';
                                        }*/
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            const BorderRadius.all(
                                              const Radius.circular(25.0),
                                            ),
                                          ),
                                          //icon: Icon(Icons.email),
                                          prefixIcon: Icon(Icons.video_library,
                                              color: Colors.red),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              _learningMaterialsBloc.add(
                                                  AddLinkToListEvent(
                                                      youtubeLinkController
                                                          .text));
                                              youtubeLinkController.clear();
                                            },
                                            icon: Icon(
                                              Icons.add_circle,
                                              color: MyColors.primaryColor,
                                            ),
                                          ),
                                          labelText: 'Youtube Link',
                                          labelStyle: new TextStyle(
                                              color: Colors.grey[800]),
                                          filled: true,
                                          fillColor: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: titleController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter event title.';
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
                                  controller: descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter your description.';
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
            _learningMaterialsBloc.add(RemoveFileEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  _buildExitingFilesList(List<String> files) {
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
            _learningMaterialsBloc.add(RemoveExitingFileEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  _buildLinkList(List<String> youtubeLinkList) {
    List<Widget> choices = List();
    youtubeLinkList.forEach((item) {
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
            _learningMaterialsBloc.add(RemoveLinkToListEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  bool validateSpinner() {
    bool valid = true;
    if(classDropdownValue == '---class---'){
      valid = false;
      showToast(message: 'Please select class');
    }
    if(subjectDropdownValue == '---subject---'){
      valid = false;
      showToast(message: 'Please select subject');
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
      _learningMaterialsBloc.add(AddLearningMaterialFileEvent((type=='Edit')?learningMaterials[index].id:'', mainFile, fileExtension));
      print(file.path.split('.').last);
    }

    if(type=='Edit'){
      print(filesToDelete);
      _learningMaterialsBloc.add(UpdateLearningMaterialEvent(learningMaterials[index].id,
          classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
          fileName, descriptionController.text, youtubeLinkList, titleController.text, await getUserId(),
          subjectSpinnerIds[subjectSpinnerItems.indexOf(subjectDropdownValue)], filesToDelete));
    }else{
      _learningMaterialsBloc.add(AddLearningMaterialEvent(classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)],
          fileName, descriptionController.text, youtubeLinkList, titleController.text, await getUserId(),
          subjectSpinnerIds[subjectSpinnerItems.indexOf(subjectDropdownValue)]));
    }

  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              if(youtubeLinkController.text.isNotEmpty){
                youtubeLinkList.add(youtubeLinkController.text);
                youtubeLinkController.clear();
              }
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



