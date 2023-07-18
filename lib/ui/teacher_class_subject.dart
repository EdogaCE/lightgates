import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/blocs/view_teachers/teachers_bloc.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/add_teacher_class_subject_dialog.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherClassSubject extends StatelessWidget {
  final Teachers teachers;
  final String teacher;
  TeacherClassSubject({this.teacher, this.teachers});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeachersBloc(updateProfileRepository: UpdateProfileRequest()),
      child: TeacherClassSubjectPage(teachers, teacher),
    );
  }
}
// ignore: must_be_immutable
class TeacherClassSubjectPage extends StatelessWidget {
  final Teachers teachers;
  final String teacher;
  TeacherClassSubjectPage(this.teachers, this.teacher);
  TeachersBloc _teachersBloc;
  bool pup=true;
  @override
  Widget build(BuildContext context) {
    _teachersBloc = BlocProvider.of<TeachersBloc>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(
          color: MyColors.primaryColor
        ),
          /*leading: IconButton(
            icon: Icon(Icons.library_books, color: MyColors.primaryColor,),
            onPressed: (){

            },
          ),*/
          title: Text(teacher, style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: teachers.classes.length,
            itemBuilder: (BuildContext context, int listIndex) {
              return BlocListener<TeachersBloc, TeachersStates>(
                listener: (context, state) {
                  //Todo: note listener returns void
                  if (state is NetworkErr) {
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
                    if (state.message == "Please Login to continue") {
                      reLogUserOut(context);
                    }
                  }else if (state is TeachersProcessing) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Processing..."),
                      ),
                    );
                  }else if (state is TeacherClassSubjectRemoved) {
                    if(pup){
                      Navigator.pop(context, state.message);
                      pup=false;
                    }
                  }else if (state is TeacherClassSubjectUpdated) {
                    if(pup){
                      Navigator.pop(context, state.message);
                      pup=false;
                    }
                  }
                },
                child: BlocBuilder<TeachersBloc, TeachersStates>(
                  builder: (context, state) {
                    //Todo: note builder returns widget
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Container(
                              color:MyColors.primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(toSentenceCase(teachers.classes[listIndex]),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(toSentenceCase(teachers.subjects[listIndex]),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                      onTap: () {
                        if(teacher!='Your classes and subjects')
                          showOptionsModalBottomSheet(context: context, index: listIndex);
                      },
                      onLongPress: (){
                        if(teacher!='Your classes and subjects')
                          showOptionsModalBottomSheet(context: context, index: listIndex);
                      },
                    );
                  },
                ),
              );
            }),
    );
  }

  void showOptionsModalBottomSheet({BuildContext context, int index}) {
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
                    Icons.edit,
                    color: Colors.green,
                  ),
                  title: new Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditTeacherClassSubjectModalDialog(context: context, teachers: teachers, index: index);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  title: new Text('Remove'),
                  onTap: () {
                    Navigator.pop(context);
                    _teachersBloc.add(DeleteTeacherClassSubjectEvent(teachers.classSubjectId[index]));
                  },
                ),
              ],
            ),
          );
        });
  }

   void _showEditTeacherClassSubjectModalDialog({BuildContext context, Teachers teachers, int index}) async {
    final data = await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: AddTeacherClassSubjectDialog(edit: true, classId: teachers.classesDetail[index].id, subjectId: teachers.subjectsDetail[index].id,),
          );
        });
    if (data != null) {
//TODO: Activate term here
      print(data.toString());
      _teachersBloc.add(UpdateTeacherClassSubjectEvent(teachers.classSubjectId[index], data['classId'], data['subjectId'], teachers.id));
    }
  }
}
