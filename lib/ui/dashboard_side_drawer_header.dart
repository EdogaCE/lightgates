import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/blocs/dashboard/dashboard_events.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/school_profile.dart';
import 'package:school_pal/ui/student_profile.dart';
import 'package:school_pal/ui/teacher_profile.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget initialDashboardSideDrawerHeader({BuildContext context, User user}) {
  return Stack(
    children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
            child: GestureDetector(
              onTap: (){
                if(!user.verificationStatus){
                  showMessageModalDialog(context: context, message: MyStrings.verificationErrorMessage, buttonText: 'Ok', closeable: true).then((value) {
                    print(value);
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.asset(
                  'lib/assets/images/avatar.png',
                  scale: 5,
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(user.userName,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(user.contactEmail,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
     _viewQualityAndTerm(" ", "")
    ],
  );
}

Widget schoolDashboardSideDrawerHeader({BuildContext context, School school, User user, String loggedInAs}) {
  return Stack(
    children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
            child: GestureDetector(
              onTap: () {
                navigateAndReturnResult(context: context, page: SchoolProfile(school: school, edit: true,)).then((value)async{
                  BlocProvider.of<DashboardBloc>(context).add(ViewSchoolProfileEvent(await getApiToken(), await getLoggedInAs()));
                });

              },
              child: Hero(
                tag: "profile picture",
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffFDCF09),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholderScale: 5,
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        fadeInDuration: const Duration(seconds: 1),
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: 'lib/assets/images/avatar.png',
                        image: '${school.imageLink}${school.image}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(toSentenceCase(school.name),
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(school.email,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
      _viewQualityAndTerm(school.activeSession, school.activeTerm)
    ],
  );
}

Widget teacherDashboardSideDrawerHeader({BuildContext context, Teachers teachers,  User user, String loggedInAs}) {
  return Stack(
    children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
            child: GestureDetector(
              onTap: () {

                navigateAndReturnResult(context: context, page: TeacherProfile(teachers)).then((value)async{
                  BlocProvider.of<DashboardBloc>(context).add(ViewTeacherProfileEvent(await getApiToken(), await getUserId(), await getLoggedInAs()));
                });

              },
              child: Hero(
                tag: "profile picture",
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffFDCF09),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholderScale: 5,
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        fadeInDuration: const Duration(seconds: 1),
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: 'lib/assets/images/avatar.png',
                        image: '${teachers.passportLink}${teachers.passport}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text('${toSentenceCase(teachers.lName)} ${toSentenceCase(teachers.fName)} ${toSentenceCase(teachers.mName)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(teachers.email,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
     _viewQualityAndTerm(teachers.activeSession, teachers.activeTerm)
    ],
  );
}

Widget studentDashboardSideDrawerHeader({BuildContext context, Students students,  User user, String loggedInAs}) {
  return Stack(
    children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
            child: GestureDetector(
              onTap: () {
                navigateAndReturnResult(context: context, page: StudentProfile(students)).then((value)async{
                  BlocProvider.of<DashboardBloc>(context).add(ViewStudentProfileEvent(await getApiToken(), await getUserId(), await getLoggedInAs()));
                });
              },
              child: Hero(
                tag: "profile picture",
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xffFDCF09),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholderScale: 5,
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        fadeInDuration: const Duration(seconds: 1),
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: 'lib/assets/images/avatar.png',
                        image: '${students.passportLink}${students.passport}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text('${toSentenceCase(students.lName)} ${toSentenceCase(students.fName)} ${toSentenceCase(students.mName)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(students.email,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
      _viewQualityAndTerm(students.activeSession, students.activeTerm)
    ],
  );
}


Widget _viewQualityAndTerm(String session, String term) {
  return Align(
      alignment: Alignment.topRight,
      child: Wrap(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(session,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(term,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.normal)),
              )
            ],
          ),
        ],
      ));
}

Future<dynamic> navigateAndReturnResult({BuildContext context, Widget page})async{
  final result= await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    ),
  );
  return result;
}