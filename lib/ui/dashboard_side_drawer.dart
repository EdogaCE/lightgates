import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/view_adverts.dart';
import 'package:school_pal/ui/view_bill_payment.dart';
import 'package:school_pal/ui/create_flutter_wave_sub_account.dart';
import 'package:school_pal/ui/create_pay_stack_sub_account.dart';
import 'package:school_pal/ui/dashboard_side_drawer_header.dart';
import 'package:school_pal/ui/generate_pick-up_id.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/result_view_option.dart';
import 'package:school_pal/ui/school_profile.dart';
import 'package:school_pal/ui/verify_pick_up_id.dart';
import 'package:school_pal/ui/view_all_classes.dart';
import 'package:school_pal/ui/view_assessments_by_class.dart';
import 'package:school_pal/ui/view_chat_category.dart';
import 'package:school_pal/ui/view_class_categories.dart';
import 'package:school_pal/ui/view_class_labels.dart';
import 'package:school_pal/ui/view_fees_record.dart';
import 'package:school_pal/ui/view_learning_materials_by_class.dart';
import 'package:school_pal/ui/view_salary_record.dart';
import 'package:school_pal/ui/view_school_grades.dart';
import 'package:school_pal/ui/view_school_sessions.dart';
import 'package:school_pal/ui/view_school_terms.dart';
import 'package:school_pal/ui/view_wallet.dart';
import 'package:school_pal/ui/view_students.dart';
import 'package:school_pal/ui/view_students_by_class.dart';
import 'package:school_pal/ui/view_students_fee_records.dart';
import 'package:school_pal/ui/view_subjects.dart';
import 'package:school_pal/ui/view_teachers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/ui/view_teachers_by_class.dart';
import 'package:school_pal/ui/view_tickets.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';
import 'developer_contact.dart';
import 'events_calender.dart';
import 'view_school_gallery.dart';

Widget dashboardSideDrawer({BuildContext context, DashboardBloc dashboardBloc, User user, String loggedInAs,  School school,
Teachers teachers, Students students}) {
  return Drawer(
// Add a ListView to the drawer. This ensures the user can scroll
// through the options in the drawer if there isn't enough vertical
// space to fit everything.
    child: ListView(
// Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      children: <Widget>[
        DrawerHeader(
          child: BlocListener<DashboardBloc, DashboardStates>(
            listener: (BuildContext context, DashboardStates state) {
              if (state is SchoolProfileLoaded) {
                school = state.school;
              }else if (state is TeacherProfileLoaded) {
                teachers = state.teachers;
              }else if (state is StudentProfileLoaded) {
                students = state.students;
              }
            },
            child: BlocBuilder<DashboardBloc, DashboardStates>(
                builder: (BuildContext context, DashboardStates state) {
              if (state is SchoolProfileLoaded) {
                return schoolDashboardSideDrawerHeader(
                    context: context, school: state.school, user: user, loggedInAs: loggedInAs);
              }else if (state is TeacherProfileLoaded) {
                return teacherDashboardSideDrawerHeader(
                    context: context, teachers: state.teachers, user: user, loggedInAs: loggedInAs);
              }else if (state is StudentProfileLoaded) {
                return studentDashboardSideDrawerHeader(
                    context: context, students: state.students, user: user, loggedInAs: loggedInAs);
              } else {
                try {
                  return (loggedInAs==MyStrings.school)?schoolDashboardSideDrawerHeader(
                      context: context, school: school, user: user, loggedInAs: loggedInAs):
                  (loggedInAs==MyStrings.teacher)?teacherDashboardSideDrawerHeader(
                      context: context, teachers: teachers, user: user, loggedInAs: loggedInAs):
                  studentDashboardSideDrawerHeader(
                      context: context, students: students, user: user, loggedInAs: loggedInAs);
                } on NoSuchMethodError {
                  return initialDashboardSideDrawerHeader(context: context, user: user);
                }
              }
            }),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                MyColors.primaryColor,
                MyColors.primaryColorShade500,
                MyColors.primaryColorShade400,
              ],
            ),
          ),
        ),
        _parentList(context, dashboardBloc, Icons.library_books, Colors.blue, MyStrings.navAssignments, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.collections_bookmark, Colors.lime, MyStrings.navLearningMaterials, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.games, Colors.teal, MyStrings.navGames, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.date_range, Colors.indigo, MyStrings.navCalender, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.image, Colors.pink, MyStrings.navGallery, loggedInAs, user),
        _parentList(context,dashboardBloc,  Icons.library_books, Colors.green, MyStrings.navDictionary, loggedInAs, user),
        (loggedInAs==MyStrings.school)?ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.school, color: Colors.brown),
              ),
              Text(MyStrings.navSchool,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            _childList(context, Icons.school, MyStrings.navViewSessions, loggedInAs, user, school),
            _childList(context, Icons.school, MyStrings.navViewTerms, loggedInAs, user, school),
            _childList(context, Icons.school, MyStrings.navViewGradingSystem, loggedInAs, user, school),
          ],
        ):Container(),
        ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.description, color: Colors.blueGrey),
              ),
              Text(MyStrings.navResults,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            (loggedInAs==MyStrings.school || loggedInAs==MyStrings.teacher)?_childList(context, Icons.description, MyStrings.navPendingResults, loggedInAs, user, school):Container(),
            (loggedInAs==MyStrings.school || loggedInAs==MyStrings.teacher)?_childList(context, Icons.description, MyStrings.navVerifiedResults, loggedInAs, user, school):Container(),
            (loggedInAs==MyStrings.student)?_childList(context, Icons.description, MyStrings.navTermlyResults, loggedInAs, user, school):Container(),
            (loggedInAs==MyStrings.student)?_childList(context, Icons.description, MyStrings.navCumulativeResults, loggedInAs, user, school):Container()
          ],
        ),
        ((loggedInAs==MyStrings.school)||(loggedInAs==MyStrings.teacher && user.isFormTeacher))?
        BlocBuilder<DashboardBloc, DashboardStates>(
            builder: (BuildContext context, DashboardStates state) {
              return ExpansionTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.people, color: Colors.orange),
                    ),
                    Text(MyStrings.navStudents,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ],
                ),
                children: <Widget>[
                  (loggedInAs==MyStrings.school)?_childList(context, Icons.people, MyStrings.navAllStudents, loggedInAs, user, school):Container(),
                  (loggedInAs==MyStrings.school)?_childList(context, Icons.people, MyStrings.navAllStudentsByClass, loggedInAs, user, school):Container(),
                  (loggedInAs==MyStrings.school)?_childList(context, Icons.people, MyStrings.principalsComments, loggedInAs, user, school):Container(),
                  (loggedInAs==MyStrings.teacher && user.isFormTeacher)?_childList(context, Icons.people, MyStrings.navAttendance, loggedInAs, user, school):Container(),
                  (loggedInAs==MyStrings.teacher && user.isFormTeacher)?_childList(context, Icons.people, MyStrings.navBehaviouralSkills, loggedInAs, user, school):Container(),
                ],
              );
            }):Container(),
        (loggedInAs==MyStrings.school)?ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.person, color: Colors.green),
              ),
              Text(MyStrings.navTeachers,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            _childList(context, Icons.person, MyStrings.navAllTeachers, loggedInAs, user, school),
            _childList(context, Icons.person, MyStrings.navAllTeachersByClass, loggedInAs, user,school)
          ],
        ):Container(),
        (loggedInAs==MyStrings.school)?_parentList(context, dashboardBloc, Icons.subject, Colors.purpleAccent, MyStrings.navSubjects, loggedInAs, user):Container(),
        (loggedInAs==MyStrings.school)?_parentList(context, dashboardBloc, Icons.monetization_on, Colors.deepOrange, MyStrings.navSalary, loggedInAs, user):Container(),
        (loggedInAs==MyStrings.school||loggedInAs==MyStrings.student)?_parentList(context, dashboardBloc, Icons.monetization_on, Colors.lightGreen, MyStrings.navFees, loggedInAs, user):Container(),
       ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.account_balance_wallet, color: Colors.purple),
              ),
              Text(MyStrings.navWallet,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            _childList(context, Icons.account_balance_wallet, MyStrings.navViewWallet, loggedInAs, user, school),
            (loggedInAs==MyStrings.school)?_childList(context, Icons.account_balance_wallet, MyStrings.navCreatePayStackAccount, loggedInAs, user, school):Container(),
            (loggedInAs==MyStrings.school)?_childList(context, Icons.account_balance_wallet, MyStrings.navCreateFlutterWaveAccount, loggedInAs, user, school):Container(),
          ],
        ),
        _parentList(context, dashboardBloc, Icons.chat, Colors.deepPurple, MyStrings.navChats, loggedInAs, user),
        ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.contacts, color: Colors.cyan),
              ),
              Text(MyStrings.navContact,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            (loggedInAs!=MyStrings.student)?_childList(context, Icons.contacts, MyStrings.navCreateTicket, loggedInAs, user, school):Container(),
            (loggedInAs!=MyStrings.student)?_childList(context, Icons.contacts, MyStrings.navContactDeveloper, loggedInAs, user, school):Container(),
            (loggedInAs==MyStrings.student)?_childList(context, Icons.contacts, MyStrings.navAboutSchool, loggedInAs, user, school):Container(),
          ],
        ),
        ((loggedInAs==MyStrings.teacher)||(loggedInAs==MyStrings.school))?_parentList(context, dashboardBloc, Icons.verified_user, Colors.yellow, MyStrings.navVerifyPickUpId, loggedInAs, user):Container(),
        (loggedInAs==MyStrings.student)?_parentList(context, dashboardBloc, Icons.verified_user, Colors.yellow, MyStrings.navGeneratePickUpId, loggedInAs, user):Container(),
        (loggedInAs==MyStrings.school)?ExpansionTile(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.class_, color: Colors.teal),
              ),
              Text(MyStrings.navClass,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          children: <Widget>[
            _childList(context, Icons.class_, MyStrings.navAllClass, loggedInAs, user, school),
            _childList(context, Icons.class_, MyStrings.navAllClassCategories, loggedInAs, user, school),
            _childList(context, Icons.class_, MyStrings.navAllClassLabels, loggedInAs, user, school),
            //_childList(context, Icons.class_, MyStrings.navAllClassLevels, loggedInAs, user)
          ],
        ):Container(),
        _parentList(context, dashboardBloc, Icons.payment, Colors.purple, MyStrings.navBills, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.card_giftcard, Colors.red, MyStrings.navAdvertise, loggedInAs, user),
        _parentList(context, dashboardBloc, Icons.keyboard_return, Colors.black, MyStrings.navSignOut, loggedInAs, user)
      ],
    ),
  );
}

Widget _parentList(
    BuildContext context, DashboardBloc dashboardBloc, IconData iconData, Color iconColor, String title, String loggedInAs, User user) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            iconData,
            color: iconColor,
          ),
        ),
        Text(title,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, color: Colors.black)),
      ],
    ),
    onTap: () async{
      Navigator.pop(context);
      if(user.verificationStatus){
        switch (title) {
          case MyStrings.navAssignments:
            {
              getStudentClass().then((classes) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAssessmentsByClass(loggedInAs: loggedInAs, classes: classes,)),
                );
              });
              break;
            }
          case MyStrings.navLearningMaterials:
            {
              getStudentClass().then((classes) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewLearningMaterialsByClass(loggedInAs: loggedInAs, classes: classes,)),
                );
              });
              break;
            }
          case MyStrings.navCalender:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventsCalender(loggedInAs: loggedInAs,)),
              );
              break;
            }
          case MyStrings.navGallery:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSchoolGallery(loggedInAs: loggedInAs,)),
              );
              break;
            }
          case MyStrings.navSubjects:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSubjects(firstTimeLogin: false)),
              );
              break;
            }
          case MyStrings.navSalary:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSalaryRecord()),
              );
              break;
            }
          case MyStrings.navFees:
            {
              (loggedInAs==MyStrings.school)?Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewFeesRecord()),
              ):Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewStudentsFeeRecords()),
              );
              break;
            }
          case MyStrings.navChats:
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewChatCategory(userChatType: user.userChatType, userChatId: user.userChatId,)));
              break;
            }
          case MyStrings.navVerifyPickUpId:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerifyPickUpId()),
              );
              break;
            }
          case MyStrings.navGeneratePickUpId:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeneratePickupId()),
              );
              break;
            }
          case MyStrings.navGeneratePickUpId:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeneratePickupId()),
              );
              break;
            }
          case MyStrings.navGames:
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewLoader(
                      url: '${MyStrings.frontEndDomain}${MyStrings.gamesUrl}',
                      downloadLink: '',
                      title: 'Games',
                    )),
              );
              break;
            }
          case MyStrings.navDictionary:
            {
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
          case MyStrings.navAdvertise:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewAdvert()),
              );
              break;
            }
          case MyStrings.navBills:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewBillPayment()),
              );
              break;
            }
          case MyStrings.navSignOut:
            {
              //Todo: logout from server
              showLogoutModalBottomSheet(context).then((value){
                if(value!=null){
                  if(value){
                    dashboardBloc.add(LogoutEvent(loggedInAs, getDevicePlatform()));
                  }
                }
              });
              break;
            }
        }
      }else{
        if(title==MyStrings.navSignOut){
          showLogoutModalBottomSheet(context).then((value){
            if(value!=null){
              if(value){
                dashboardBloc.add(LogoutEvent(loggedInAs, getDevicePlatform()));
              }
            }
          });
        }else{
          showMessageModalDialog(context: context, message: MyStrings.verificationErrorMessage, buttonText: 'Ok', closeable: true).then((value) {
            print(value);
          });
        }
      }
    },
  );
}

Widget _childList(BuildContext context, IconData iconData, String title, String loggedInAs, User user, School school) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: Icon(
            iconData,
            color: Colors.grey,
            size: 20,
          ),
        ),
        Text(title,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 15, color: Colors.black54)),
      ],
    ),
    onTap: () {
      Navigator.pop(context);
      if(user.verificationStatus){
        switch (title) {
          case MyStrings.navAllClass:
            {
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewClasses(firstTimeLogin: false)),
              );*/
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewAllClasses(firstTimeLogin: false)),
              );
              break;
            }
          case MyStrings.navAllClassCategories:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewClassCategories(firstTimeLogin: false)),
              );
              break;
            }
          case MyStrings.navAllClassLabels:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewClassLabels(firstTimeLogin: false)),
              );
              break;
            }
          /*case MyStrings.navAllClassLevels:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewClassLevels(firstTimeLogin: false)),
              );
              break;
            }*/
          case MyStrings.navViewSessions:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSchoolSessions(firstTimeLogin: false)),
              );
              break;
            }
          case MyStrings.navViewTerms:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSchoolTerms(firstTimeLogin: false)),
              );
              break;
            }
          case MyStrings.navViewGradingSystem:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSchoolGrades()),
              );
              break;
            }
          case MyStrings.navViewWallet:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewWallet()),
              );
              break;
            }
          case MyStrings.navCreatePayStackAccount:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePayStackSubAccount()),
              );
              break;
            }
          case MyStrings.navCreateFlutterWaveAccount:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateFlutterWaveSubAccount()),
              );
              break;
            }
          case MyStrings.navAboutSchool:
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SchoolProfile(edit: false)));
              break;
            }
          case MyStrings.navAllStudents:
            {
              if(school?.useCustomAdmissionNum!=null)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewStudents(classes: '', requireAdmissionNumber: school?.useCustomAdmissionNum??false)),
              );

              break;
            }
          case MyStrings.navAllStudentsByClass:
            {
              if(school?.useCustomAdmissionNum!=null)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewStudentsByClass(requireAdmissionNumber: school?.useCustomAdmissionNum??false)),
              );

              break;
            }
          case MyStrings.navAllTeachers:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewTeachers(from: '', classes: '')),
              );
              break;
            }
          case MyStrings.navAllTeachersByClass:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewTeachersByClass()),
              );
              break;
            }
          case MyStrings.navCreateTicket:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewTickets()),
              );
              break;
            }
          case MyStrings.navContactDeveloper:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeveloperContact()),
              );
              break;
            }
          case MyStrings.navPendingResults:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'pending results', type: 'pending results', loggedInAs: loggedInAs, cumulative: false)),
              );
              break;
            }
          case MyStrings.navVerifiedResults:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'verified results', type: 'verified results', loggedInAs: loggedInAs, cumulative: false)),
              );
              break;
            }
          case MyStrings.navTermlyResults:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'save results', loggedInAs: loggedInAs, type: 'save results', cumulative: false,)),
              );
              break;
            }
          case MyStrings.navCumulativeResults:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'save results', loggedInAs: loggedInAs, type: 'save results', cumulative: true,)),
              );
              break;
            }
          case MyStrings.navBehaviouralSkills:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'behavioural skills', type: 'behavioural skills', loggedInAs: loggedInAs, cumulative: false)),
              );
              break;
            }
          case MyStrings.principalsComments:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'principal\'s comment', type: 'behavioural skills', loggedInAs: loggedInAs, cumulative: false)),
              );
              break;
            }
          case MyStrings.navAttendance:
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultViewOption(title: 'attendance', type: 'attendance', loggedInAs: loggedInAs, cumulative: false)),
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
  );
}
