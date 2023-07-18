import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/advert/advert.dart';
import 'package:school_pal/models/advert.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/result_view_option.dart';
import 'package:school_pal/ui/view_assessments_by_class.dart';
import 'package:school_pal/ui/view_school_gallery.dart';
import 'package:school_pal/ui/view_students.dart';
import 'package:school_pal/ui/view_teachers.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';
import 'events_calender.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/utils/launch_request.dart';

Widget schoolDashboardContent({BuildContext context, User user,  School school, String loggedInAs, bool loaded}) {
  return SingleChildScrollView(
    physics: ClampingScrollPhysics(),
    child: CustomPaint(
      painter: DashBoardBackgroundPainter(),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                              loaded?'${MyStrings.welcomeTitle}, ${toSentenceCase(school.name)}!':'${MyStrings.welcomeTitle}, ${toSentenceCase(user.userName)}!',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(MyStrings.welcomeMessage,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, school: school, title:MyStrings.bntStudents, icon:Icons.people, iconColor:Colors.orange, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, school: school, title:MyStrings.bntTeachers, icon:Icons.person, iconColor:Colors.green, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, school: school, title:MyStrings.bntGallery, icon:Icons.image, iconColor:Colors.pink, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, school: school, title:MyStrings.bntAssignments,  icon:Icons.library_books, iconColor:Colors.blue, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context,anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.teal,
                                    Icons.people,
                                    "Total Students",
                                    loaded?toSentenceCase(school.numberOfStudents):toSentenceCase(user.numberOfStudents),
                                    loaded?((double.parse(school.numberOfStudents)-double.parse(user.numberOfStudents))/100):(double.parse(user.numberOfStudents)/100),
                                    "${loaded?toSentenceCase((double.parse(school.numberOfStudents)-double.parse(user.numberOfStudents)).toString()):toSentenceCase(double.parse(user.numberOfStudents).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context,anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.orange,
                                    Icons.person,
                                    "Total Teachers",
                                    loaded?toSentenceCase(school.numberOfTeachers):toSentenceCase(user.numberOfTeachers),
                                    loaded?((double.parse(school.numberOfTeachers)-double.parse(user.numberOfTeachers))/100):(double.parse(user.numberOfTeachers)/100),
                                    "${loaded?toSentenceCase((double.parse(school.numberOfTeachers)-double.parse(user.numberOfTeachers)).toString()):toSentenceCase(double.parse(user.numberOfTeachers).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user, randomly: true),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context,anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.blue,
                                    Icons.school,
                                    "Total Subjects",
                                    loaded?toSentenceCase(school.numberOfSubjects):toSentenceCase(user.numberOfSubjects),
                                    loaded?((double.parse(school.numberOfSubjects)-double.parse(user.numberOfSubjects))/100):(double.parse(user.numberOfSubjects)/100),
                                    "${loaded?toSentenceCase((double.parse(school.numberOfSubjects)-double.parse(user.numberOfSubjects)).toString()):toSentenceCase(double.parse(user.numberOfSubjects).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context,anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.pink,
                                    Icons.monetization_on,
                                    "Fees Collection",
                                    loaded?convertPrice(currency: school.currency, amount: school.confirmedFees):toSentenceCase(user.confirmedFees),
                                    loaded?(((double.parse(convertPriceNoFormatting(currency: school.currency, amount: school.confirmedFees))-double.parse(user.confirmedFees))/100)>100)?0.0:((double.parse(convertPriceNoFormatting(currency: school.currency, amount: school.confirmedFees))-double.parse(user.confirmedFees))/100):(double.parse(user.confirmedFees)/100),
                                    "${loaded?((((double.parse(convertPriceNoFormatting(currency: school.currency, amount: school.confirmedFees))-double.parse(user.confirmedFees))/100)>100)?'0.0':toSentenceCase((double.parse(convertPriceNoFormatting(currency: school.currency, amount: school.confirmedFees))-double.parse(user.confirmedFees)).toString())):toSentenceCase(double.parse(user.confirmedFees).toString())}% Increase"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget teacherDashboardContent({BuildContext context, User user, Teachers teachers, String loggedInAs, bool loaded}) {
  return SingleChildScrollView(
    physics: ClampingScrollPhysics(),
    child: CustomPaint(
      painter: DashBoardBackgroundPainter(),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                             loaded?'${MyStrings.welcomeTitle}, ${toSentenceCase(teachers.fName)}!':'${MyStrings.welcomeTitle}, ${toSentenceCase(user.userName.split(' ')[0])}!',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(MyStrings.welcomeMessage,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntAssignments, icon:Icons.library_books, iconColor:Colors.blue, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntDictionary, icon:Icons.library_books, iconColor:Colors.green, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntCalender, icon:Icons.date_range, iconColor:Colors.indigo, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context,anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntGallery, icon:Icons.image, iconColor:Colors.pink, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.teal,
                                    Icons.people,
                                    "Total Assessments",
                                    loaded?toSentenceCase(teachers.assessmentsCount):toSentenceCase(user.assessmentsCount),
                                    loaded?((double.parse(teachers.assessmentsCount)-double.parse(user.assessmentsCount))/100):(double.parse(user.assessmentsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(teachers.assessmentsCount)-double.parse(user.assessmentsCount)).toString()):toSentenceCase(double.parse(user.assessmentsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.orange,
                                    Icons.person,
                                    "Total Learning Materials",
                                    loaded?toSentenceCase(teachers.learningMaterialsCount):toSentenceCase(user.learningMaterialsCount),
                                    loaded?((double.parse(teachers.learningMaterialsCount)-double.parse(user.learningMaterialsCount))/100):(double.parse(user.learningMaterialsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(teachers.assessmentsCount)-double.parse(user.learningMaterialsCount)).toString()):toSentenceCase(double.parse(user.learningMaterialsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user, randomly: true),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.blue,
                                    Icons.school,
                                    "Class Teaching",
                                    loaded?toSentenceCase(teachers.numberOfClassTeaching):toSentenceCase(user.numberOfClassTeaching),
                                    loaded?((double.parse(teachers.numberOfClassTeaching)-double.parse(user.numberOfClassTeaching))/100):(double.parse(user.numberOfClassTeaching)/100),
                                    "${loaded?toSentenceCase((double.parse(teachers.numberOfClassTeaching)-double.parse(user.numberOfClassTeaching)).toString()):toSentenceCase(double.parse(user.numberOfClassTeaching).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.pink,
                                    Icons.monetization_on,
                                    "Pending Results",
                                    loaded?toSentenceCase(teachers.pendingResultsCount):toSentenceCase(user.pendingResultsCount),
                                    loaded?((double.parse(teachers.pendingResultsCount)-double.parse(user.pendingResultsCount))/100):(double.parse(user.pendingResultsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(teachers.pendingResultsCount)-double.parse(user.pendingResultsCount)).toString()):toSentenceCase(double.parse(user.pendingResultsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget studentDashboardContent({BuildContext context, User user, Students students, String loggedInAs, bool loaded}) {
  return SingleChildScrollView(
    physics: ClampingScrollPhysics(),
    child: CustomPaint(
      painter: DashBoardBackgroundPainter(),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                              loaded?'${MyStrings.welcomeTitle}, ${toSentenceCase(students.fName)}!':'${MyStrings.welcomeTitle}, ${toSentenceCase(user.userName.split(' ')[0])}!',
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(MyStrings.welcomeMessage,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context, anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntAssignments, icon:Icons.library_books, iconColor:Colors.blue, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context, anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context:context, user:user, title:MyStrings.bntResults, icon:Icons.description, iconColor:Colors.blueGrey, loggedInAs:loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(-2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context, anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _viewButton(context: context, user: user, title: MyStrings.bntCalender, icon: Icons.date_range, iconColor: Colors.indigo, loggedInAs: loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Animator<Offset>(
                                      tween: Tween<Offset>(
                                          begin: Offset(2, 0), end: Offset.zero),
                                      cycles: 0,
                                      repeats: 1,
                                      duration: Duration(seconds: 2),
                                      builder: (context, anim, child) => FractionalTranslation(
                                        translation: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),

                                          child: _viewButton(context: context, user: user, title:  MyStrings.bntGallery, icon: Icons.image, iconColor: Colors.pink, loggedInAs: loggedInAs),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.teal,
                                    Icons.people,
                                    "Total Assessments",
                                    loaded?toSentenceCase(students.assessmentsCount):toSentenceCase(user.assessmentsCount),
                                    loaded?((double.parse(students.assessmentsCount)-double.parse(user.assessmentsCount))/100):(double.parse(user.assessmentsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(students.assessmentsCount)-double.parse(user.assessmentsCount)).toString()):toSentenceCase(double.parse(user.assessmentsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.orange,
                                    Icons.person,
                                    "Total Learning Materials",
                                    loaded?toSentenceCase(students.learningMaterialsCount):toSentenceCase(user.learningMaterialsCount),
                                    loaded?((double.parse(students.learningMaterialsCount)-double.parse(user.learningMaterialsCount))/100):(double.parse(user.learningMaterialsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(students.learningMaterialsCount)-double.parse(user.learningMaterialsCount)).toString()):toSentenceCase(double.parse(user.learningMaterialsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _viewAdverts(context: context, user: user, randomly: true),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.blue,
                                    Icons.school,
                                    "Total Events",
                                    loaded?toSentenceCase(students.eventsCount):toSentenceCase(user.eventsCount),
                                    loaded?((double.parse(students.eventsCount)-double.parse(user.eventsCount))/100):(double.parse(user.eventsCount)/100),
                                    "${loaded?toSentenceCase((double.parse(students.eventsCount)-double.parse(user.eventsCount)).toString()):toSentenceCase(double.parse(user.eventsCount).toString())}% Increase"),
                              ),
                            ),
                          ),
                          Animator<Offset>(
                            tween: Tween<Offset>(
                                begin: Offset(0, 5), end: Offset.zero),
                            cycles: 0,
                            repeats: 1,
                            duration: Duration(seconds: 2),
                            builder: (context, anim, child) => FractionalTranslation(
                              translation: anim.value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _summary(
                                    context,
                                    Colors.pink,
                                    Icons.monetization_on,
                                    "Pending Fees",
                                    loaded?convertPrice(currency: students.currency, amount: students.pendingFees):toSentenceCase(user.pendingFees),
                                    loaded?((double.parse(convertPriceNoFormatting(currency: students.currency, amount: students.pendingFees))-double.parse(user.pendingFees))/100>100)?0.0:((double.parse(convertPriceNoFormatting(currency: students.currency, amount: students.pendingFees))-double.parse(user.pendingFees))/100):(double.parse(user.pendingFees)/100),

                                    "${loaded?((double.parse(convertPriceNoFormatting(currency: students.currency, amount: students.pendingFees))-double.parse(user.pendingFees))/100>100)?'0.0':toSentenceCase((double.parse(convertPriceNoFormatting(currency: students.currency, amount: students.pendingFees))-double.parse(user.pendingFees)).toString()):toSentenceCase(double.parse(user.pendingFees).toString())}% Increase"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _viewButton(
    {BuildContext context, User user, School school, String title, IconData icon, Color iconColor, String loggedInAs}) {
  return RaisedButton(
    onPressed: ()  async{
      if(user.verificationStatus){
        switch(title) {
          case MyStrings.bntTeachers:{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewTeachers(from: '', classes: '')),
            );
            break;
          }
          case MyStrings.bntStudents:{
            if(school?.useCustomAdmissionNum!=null)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewStudents(classes: '', requireAdmissionNumber: school?.useCustomAdmissionNum??false)),
            );

            break;
          }
          case MyStrings.bntGallery:{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewSchoolGallery(loggedInAs: loggedInAs,)),
            );
            break;
          }
          case MyStrings.bntAssignments:{
            getStudentClass().then((classes) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewAssessmentsByClass(loggedInAs: loggedInAs, classes: classes)),
              );
            });
            break;
          }
          case MyStrings.bntResults:{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResultViewOption(title: 'save results', loggedInAs: loggedInAs, type: 'save results', cumulative: false)),
            );
            break;
          }
          case MyStrings.bntDictionary:{
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewLoader(
                    url: '${MyStrings.frontEndDomain}${MyStrings.dictionaryUrl}',
                    downloadLink: '',
                    title: 'Dictionary',
                  )),
            );
            break;
          }
          case MyStrings.bntCalender:{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventsCalender(loggedInAs: loggedInAs,)),
            );
            break;
          }
        }
      }else{
        showMessageModalDialog(context: context, message: MyStrings.verificationErrorMessage, buttonText: 'Ok', closeable: true).then((value) {
          print(value);
        });
      }
    },
    color: Colors.white,
    padding: const EdgeInsets.all(0.0),
    shape: RoundedRectangleBorder(
      borderRadius: new BorderRadius.circular(20.0),
    ),
    child: Container(
      padding: const EdgeInsets.only(
          top: 15.0, bottom: 15.0, left: 15.0, right: 15.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 10.0, bottom: 10.0),
            child: Icon(icon, size: 50, color: iconColor),
          ),
           Text(title,
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget _summary(BuildContext context, Color background, IconData icon,
    String title, String amount, double progress, String increase) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20.0),
    child: Container(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(icon, color: Colors.white),
                    )),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(amount,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: (title.contains('Fees'))?18:35,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Colors.black54,
                        value: progress,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(increase,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

List<Advert> adverts=[];
Random random = new Random();
Widget _viewAdverts({BuildContext context, User user, bool randomly=false}){
  PageController _controller = PageController(
      initialPage: 0,
      viewportFraction: 1.0
  );
  return BlocListener<AdvertBloc, AdvertStates>(listener:
      (BuildContext context, state) {
    if(state is AdvertsLoaded){
     adverts=state.adverts;
     Timer.periodic(Duration(seconds: randomly?10:5), (timer) {
       try{
         BlocProvider.of<AdvertBloc>(context).add(CaptureAdImpressionEvent(impression: 'view', adUniqueId: adverts[_controller.page.round()].uniqueId, userUniqueId: user.uniqueId, nextPosition: randomly?random.nextInt(adverts.length):(_controller.page.round() + 1) % adverts.length, randomly: randomly));
       }catch(e){}
     });
    }else if(state is ImpressionCaptured){
      adverts=state.adverts;
      if(state.impression=='view'){
        if(randomly.toString()==state.randomly.toString())
          _controller.animateToPage(state.nextPosition, duration: Duration(milliseconds: 500), curve: Curves.easeInExpo);
      }

    }else if (state is AdvertViewError){
      if(state.message==MyStrings.impressionCapturedError){
        if(state.impression=='view'){
          if(randomly.toString()==state.randomly.toString())
            _controller.animateToPage(state.nextPosition, duration: Duration(milliseconds: 500), curve: Curves.easeInExpo);
        }
      }
    }
  }, child:BlocBuilder<AdvertBloc, AdvertStates>(builder:
      (BuildContext context, state) {
    return Visibility(
      visible: adverts.isNotEmpty,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: MyColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, position) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          color: Colors.white,
                          child: FadeInImage.assetNetwork(
                            placeholderScale: 5,
                            imageScale: 5,
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(seconds: 1),
                            fadeInCurve: Curves.easeInCirc,
                            placeholder: MyStrings.logoPath,
                            image: '${adverts[position].imageUrl}${adverts[position].image}',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Sponsored',
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(toSentenceCase(adverts[position].description),
                                  overflow: TextOverflow.fade,
                                  maxLines: 10,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal)),
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              BlocProvider.of<AdvertBloc>(context).add(CaptureAdImpressionEvent(impression: 'click', adUniqueId: adverts[position].uniqueId, userUniqueId: user.uniqueId, nextPosition: position+1));
                              if(adverts[position].driveTrafficTo=='website'){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewLoader(
                                        url: '${adverts[position].websiteAppUrl}',
                                        downloadLink: '',
                                        title: '',
                                      )),
                                );
                                //LaunchRequest().launchURL(adverts[position].websiteAppUrl);
                              }else if(adverts[position].driveTrafficTo=='whatsapp'){
                                LaunchRequest().launchWhasapp(int.parse('+${adverts[position].whatsAppNo}'));
                              }else if(adverts[position].driveTrafficTo=='app'){
                                LaunchRequest().launchURL(adverts[position].websiteAppUrl);
                              }
                            },
                            textColor: MyColors.primaryColor,
                            color: Colors.white,
                            padding: const EdgeInsets.all(2.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                            ),
                            child:  Text((adverts[position].driveTrafficTo=='whatsapp')?"Chat Now":"Visit Now", style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            itemCount: adverts.length, // Can be null
          ),
        ),
      ),
    );
  }),
  );

}