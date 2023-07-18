import 'package:flutter/material.dart';
import 'package:school_pal/blocs/salary/salary.dart';
import 'package:school_pal/blocs/view_teachers/teachers.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/requests/get/view_teachers_request.dart';
import 'package:school_pal/requests/posts/create_update_salary_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/form_teacher_class.dart';
import 'package:school_pal/ui/teacher_class_subject.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_teacher_profile.dart';
import 'general.dart';
import 'modals.dart';

class TeachersDetails extends StatelessWidget {
  final List<Teachers> teachers;
  final int index;
  final SalaryRecord salaryRecord;
  final String from;
  TeachersDetails({this.teachers, this.index, this.salaryRecord, this.from});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SalaryBloc>(
          create: (context) => SalaryBloc(createSalaryRepository: CreateSalaryRequests()),
        ),
        BlocProvider<TeachersBloc>(
          create: (context) => TeachersBloc(viewTeachersRepository: ViewTeachersRequest(),),
        ),
      ],
      child: TeachersDetailsPages(teachers, index, salaryRecord, from),
    );
  }
}

// ignore: must_be_immutable
class TeachersDetailsPages extends StatelessWidget {
  List<Teachers> teachers;
  final int index;
  final SalaryRecord salaryRecord;
  final String from;
  TeachersDetailsPages(this.teachers, this.index, this.salaryRecord, this.from);

  bool _updated=false;
  SalaryBloc _salaryBloc;
  TeachersBloc _teachersBloc;
  void _viewTeachers() async {
    if(from.isEmpty){
      _teachersBloc.add(ViewTeachersEvent(apiToken: await getApiToken(), localDb: false));
    }
  }
  @override
  Widget build(BuildContext context) {
    _teachersBloc = BlocProvider.of<TeachersBloc>(context);
    _salaryBloc = BlocProvider.of<SalaryBloc>(context);
    _viewTeachers();
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              actions: <Widget>[
                (from.isNotEmpty)?Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton<String>(
                    icon: Icon( Icons.more_vert, color: Colors.white,),
                    items: <String>[(teachers[index].subPayment.paymentStatus=='not_paid')
                        ?'Mark Paid':'Mark Not Paid'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      switch(value){
                        case 'Pay':{
                          break;
                        }
                        case 'Mark Paid':{
                          _salaryBloc.add(UpdateTeacherSalaryRecordEvent(
                              teachers[index].subPayment.id,
                              'paid'));
                          break;
                        }
                        case 'Mark Not Paid':{
                          _salaryBloc.add(UpdateTeacherSalaryRecordEvent(
                              teachers[index].subPayment.id,
                              'not_paid'));
                          break;
                        }
                        case 'Invoice':{
                          break;
                        }
                      }
                    },
                  ),
                ):Container()
              ],
              pinned: true,
              floating: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  centerTitle: true,
                  title: GestureDetector(
                    child: Text(
                        ' ${teachers[index].title} ${teachers[index].lName} ${teachers[index].fName} ${teachers[index].mName}'),
                    onTap: (){
                      _navigateToTeacherProfileEditScreen(context, 'name', teachers[index]);
                    },
                  ),
                  titlePadding: const EdgeInsets.all(15.0),
                  background: Hero(
                    tag: "teacher passport tag $index",
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewImage(imageUrl: [teachers[index].passportLink+teachers[index].passport], heroTag: "teacher passport tag $index", placeholder: 'lib/assets/images/avatar.png', position: 0,),
                          ));
                        },
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.fitWidth,
                          fadeInDuration: const Duration(seconds: 1),
                          fadeInCurve: Curves.easeInCirc,
                          placeholder: 'lib/assets/images/avatar.png',
                          image:teachers[index].passportLink+teachers[index].passport,
                        ),
                      ),
                    ),
                  )),
            ),
            MultiBlocListener(
              listeners: [
                BlocListener<TeachersBloc, TeachersStates>(
                  listener: (context, state) {
                    if (state is TeachersLoaded) {
                      _updated=true;
                      teachers = state.teachers;
                    }
                  },
                ),
                BlocListener<SalaryBloc, SalaryStates>(
                  listener: (context, state) {
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
                    } else if (state is TeacherSalaryRecordUpdated) {
                      Navigator.pop(context, state.message);
                    }
                  },
                ),
              ],
              child: BlocBuilder<TeachersBloc, TeachersStates>(
                builder: (BuildContext context, TeachersStates state) {
                  return SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Card(
                            // margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 5.0, bottom: 2.0),
                                  child: Text(
                                      (teachers[index].email.isNotEmpty)
                                          ? teachers[index].email.toString()
                                          : "Email Unknown",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.teal,
                                          fontWeight: FontWeight.normal)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 5.0, bottom: 8.0),
                                  child: GestureDetector(
                                    child: Text(
                                        (teachers[index].phone.isNotEmpty)
                                            ? teachers[index].phone
                                            : "Phone number unknown",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.normal)),
                                    onTap: (){
                                      _navigateToTeacherProfileEditScreen(context, 'phone', teachers[index]);
                                    },
                                    onLongPress: (){
                                      if(teachers[index].phone.isNotEmpty)
                                        showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number: teachers[index].phone);
                                    },
                                  ),
                                ),
                                /*GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 5.0, bottom: 8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(("Role:  "),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: MyColors.primaryColor,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            (teachers[index].role.toString().isNotEmpty)
                                                ? teachers[index].role.toString()
                                                : "Unknown",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  onTap: (){
                                    _navigateToTeacherProfileEditScreen(context, 'role', teachers[index]);
                                  },
                                ),*/
                              ],
                            ),
                          ),
                          (from.isEmpty)?Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: Text(("Username:  "),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: MyColors.primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(toSentenceCase(teachers[index].userName),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                            child: Text(("Password:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Text(toSentenceCase(teachers[index].password),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ):Container(),
                          (from.isEmpty)?Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Class:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    (teachers[index].classes.isEmpty)
                                        ? Text(("None yet"),
                                        textAlign: TextAlign.start,
                                        //overflow: TextOverflow.ellipsis,
                                        //maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal))
                                        : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: (){
                                          _navigateToTeacherClassSubjectScreen(context, teachers[index], '${teachers[index].lName} ${teachers[index].fName} ${teachers[index].mName}');
                                        },
                                        child: Text(
                                            "See Classes and Subjects asigned to ${teachers[index].lName} ${teachers[index].fName} ${teachers[index].mName}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 18, color: Colors.blue)
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ):Container(),
                          (from.isEmpty)?Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Form Class:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    (teachers[index].formClasses.isEmpty)
                                        ? Text(("None yet"),
                                        textAlign: TextAlign.start,
                                        //overflow: TextOverflow.ellipsis,
                                        //maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal))
                                        : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: (){
                                          _navigateToFormTeacherClassScreen(context, teachers[index], '${teachers[index].lName} ${teachers[index].fName} ${teachers[index].mName}');
                                        },
                                        child: Text(
                                            "See Form Classes asigned to ${teachers[index].lName} ${teachers[index].fName} ${teachers[index].mName}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 18, color: Colors.blue)
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ):Container(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Salary:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    (from.isEmpty)?GestureDetector(
                                      child: Text(
                                          "${(teachers[index].salary.isNotEmpty
                                              ?convertPrice(currency: teachers[index].school.currency, amount: teachers[index].salary)
                                              : "unknown")}",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.normal)),
                                      onTap: (){
                                        _navigateToTeacherProfileEditScreen(context, 'salary', teachers[index]);
                                      },
                                    ):Text(
                                        "${(teachers[index].subPayment.salary.isNotEmpty ? convertPrice(currency: teachers[index].school.currency, amount: teachers[index].subPayment.salary) : "unknown")}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                    (from.isNotEmpty)?Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: Text( teachers[index].subPayment.paymentStatus.toUpperCase().replaceAll('_', ' '),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: (teachers[index].subPayment.paymentStatus=='not_paid')?Colors.red:Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                        ),

                                        (teachers[index].subPayment.paymentStatus=='not_paid')?Container():
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: Text( 'Bonus: ${convertPrice(currency: teachers[index].school.currency, amount: teachers[index].subPayment.bonus)}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        ),

                                        (teachers[index].subPayment.paymentStatus=='not_paid')?Container():
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: Text( 'Date paid: ${teachers[index].subPayment.datePaid}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        )
                                      ],
                                    ):Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          (from.isEmpty)?Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(("Currency:  "),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: MyColors.primaryColor,
                                                fontWeight: FontWeight.bold)),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                                (teachers[index].currency.currencyName.isNotEmpty
                                                    ? '${teachers[index].currency.currencyName.replaceAll('null', 'Unkonwn')} (${teachers[index].currency.secondCurrency})'
                                                    : "unknown"),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ),
                                          onTap: (){
                                            _navigateToTeacherProfileEditScreen(context, 'currency', teachers[index]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(("Bank Details:  "),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: MyColors.primaryColor,
                                                fontWeight: FontWeight.bold)),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                                ((teachers[index].bankName.isNotEmpty && teachers[index].bankAccountNumber.isNotEmpty)
                                                    ? '${teachers[index].bankName} [${teachers[index].bankAccountNumber}]'
                                                    : "Not yet updated by teacher"),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ),
                                          onTap: (){
                                            _navigateToTeacherProfileEditScreen(context, 'bank detail', teachers[index]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ):Container(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Address:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    GestureDetector(
                                      child: Text(
                                          '${toSentenceCase(teachers[index].address)}, ${toSentenceCase(teachers[index].city)}, ${toSentenceCase(teachers[index].state)}, ${toSentenceCase(teachers[index].nationality)}',
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.normal)),
                                      onTap: (){
                                        _navigateToTeacherProfileEditScreen(context, 'address', teachers[index]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _navigateToTeacherProfileEditScreen(
      BuildContext context, String editing, Teachers teachers) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditTeacherProfile(editing: editing, teachers: teachers,)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _viewTeachers();
    }
  }

  _navigateToFormTeacherClassScreen(
      BuildContext context, Teachers teachers, String title) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormTeacherClass(teachers: teachers,
          teacher: title)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _viewTeachers();
    }
  }

  _navigateToTeacherClassSubjectScreen(
      BuildContext context, Teachers teachers, String title) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeacherClassSubject(teachers: teachers, teacher: title),
    ));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      _viewTeachers();
    }
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_updated) {
      print("onwill goback");
      Navigator.pop(context, 'new update');
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}
