import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/blocs/view_teachers/teachers_bloc.dart';
import 'package:school_pal/blocs/view_teachers/teachers_events.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormTeacherClass extends StatelessWidget {
  final Teachers teachers;
  final String teacher;
  FormTeacherClass({this.teachers, this.teacher});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeachersBloc(updateProfileRepository: UpdateProfileRequest()),
      child: FormTeacherClassPage(teachers, teacher),
    );
  }
}

// ignore: must_be_immutable
class FormTeacherClassPage extends StatelessWidget {
  final Teachers teachers;
  final String teacher;
  FormTeacherClassPage(this.teachers, this.teacher);
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
        title: Text(teacher, style: TextStyle(color: MyColors.primaryColor)),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: teachers.formClasses.length,
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
                }else if (state is FormTeacherRemoved) {
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
                             child: Text('${toSentenceCase(teachers.formClasses[listIndex].label)} ${toSentenceCase(teachers.formClasses[listIndex].category)}',
                                 style: TextStyle(
                                     fontSize: 14,
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold)),
                           ),
                         ),
                       ),
                       /*Padding(
                         padding: const EdgeInsets.only(left: 8.0),
                         child: Text('${teachers.formSession[listIndex].sessionDate} (${teachers.formTerm[listIndex].term})',
                             textAlign: TextAlign.start,
                             style: TextStyle(
                                 fontSize: 14,
                                 color: Colors.black54,
                                 fontWeight: FontWeight.normal)),
                       ),*/
                     ],
                   ),
                   onTap: () {
                     if(teacher!='Your Form Classes')
                       showOptionsModalBottomSheet(context: context, index: listIndex);
                   },
                   onLongPress: (){
                     if(teacher!='Your Form Classes')
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
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  title: new Text('Remove'),
                  onTap: () {
                    Navigator.pop(context);
                    _teachersBloc.add(RemoveFormTeacherEvent(teachers.formClasses[index].id, teachers.formTeacherAssignId[index], teachers.id));
                  },
                ),
              ],
            ),
          );
        });
  }
}
