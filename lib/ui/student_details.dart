import 'package:flutter/material.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/blocs/view_students/students.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_payment_detail.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/requests/get/view_students_request.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/view_fees.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_student_profile.dart';

class StudentDetails extends StatelessWidget {
  final List<Students> students;
  final int index;
  final bool fees;
  final bool pickUpId;
  StudentDetails({this.students, this.index, this.fees, this.pickUpId});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FeesBloc>(
          create: (context) => FeesBloc(createFeesRepository: CreateFeesRequests()),
        ),
        BlocProvider<StudentsBloc>(
          create: (context) => StudentsBloc(viewStudentsRepository: ViewStudentsRequest()),
        ),
      ],
      child: StudentDetailsPage(students, index, fees, pickUpId),
    );
  }
}

// ignore: must_be_immutable
class StudentDetailsPage extends StatelessWidget {
  List<Students> students;
  final int index;
  final bool fees;
  final bool pickUpId;
  StudentDetailsPage(this.students, this.index, this.fees, this.pickUpId);

  bool _updated=false;
  FeesBloc _feesBloc;
  StudentsBloc _studentsBloc;

  void _viewStudents() async {
    if(!fees&&!pickUpId)
      _studentsBloc.add(ViewStudentsEvent(apiToken: await getApiToken(), localDb: false));
  }

  @override
  Widget build(BuildContext context) {
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _studentsBloc = BlocProvider.of<StudentsBloc>(context);
    _viewStudents();

    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              actions: <Widget>[
                fees?FlatButton(
                    child: Text('Deactivate', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _feesBloc.add(DeactivateDefaultStudentEvent(students[index].feesPayment.recordId, students[index].id));
                    }):Container()
              ],
              pinned: true,
              floating: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  centerTitle: true,
                  title: Text(
                      '${students[index].lName} ${students[index].fName} ${students[index].mName}'),
                  titlePadding: const EdgeInsets.all(15.0),
                  background: Hero(
                    tag: "student passport tag $index",
                    transitionOnUserGestures: true,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImage(
                                  imageUrl: [students[index].passportLink +
                                      students[index].passport],
                                  heroTag: "student passport tag $index",
                                  placeholder: 'lib/assets/images/avatar.png',
                                  position: 0,
                                ),
                              ));
                        },
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.fitWidth,
                          fadeInDuration: const Duration(seconds: 1),
                          fadeInCurve: Curves.easeInCirc,
                          placeholder: 'lib/assets/images/avatar.png',
                          image: students[index].passportLink +
                              students[index].passport,
                        ),
                      ),
                    ),
                  )),
            ),
            MultiBlocListener(
              listeners: [
                BlocListener<FeesBloc, FeesStates>(
                  listener: (context, state) {
                    //Todo: note listener returns void
                    if (state is FeesNetworkErr) {
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
                      if (state.message == "Please Login to continue") {
                        reLogUserOut(context);
                      }
                    }else if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if (state is StudentDeactivated) {
                      Navigator.pop(context, state.message);
                    }else if (state is FeePaymentConfirmed) {
                      Navigator.pop(context, state.message);
                    }
                  },
                ),
                BlocListener<StudentsBloc, StudentsStates>(
                  listener: (context, state) {
                    if (state is StudentsLoaded) {
                      students=state.students;
                      _updated=true;
                    }
                  },
                ),
              ],
              child: BlocBuilder<StudentsBloc, StudentsStates>(
                builder: (context, state) {
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
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Text(
                                        (students[index].admissionNumber.isEmpty
                                            ? '${students[index].sessions.admissionNumberPrefix}${students[index].genAdmissionNumber}'
                                            : '${students[index].sessions.admissionNumberPrefix}${students[index].admissionNumber}'),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0, top: 5.0, bottom: 2.0),
                                      child: Text(
                                          (students[index].email.isNotEmpty)
                                              ? students[index].email
                                              : "Email Unknown",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.teal,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                    onTap: (){
                                      _navigateToStudentProfileEditScreen(context, 'email', students[index]);
                                    },
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0, top: 5.0, bottom: 8.0),
                                      child: Text(
                                          (students[index].phone.isNotEmpty)
                                              ? students[index].phone
                                              : "Phone number unknown",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                    onTap: (){
                                      _navigateToStudentProfileEditScreen(context, 'phone', students[index]);
                                    },
                                    onLongPress: (){
                                      if(students[index].phone.isNotEmpty)
                                        showCallWhatsappMessageModalBottomSheet(context: context,countryCode: '+234', number: students[index].parentPhone);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            (!fees&&!pickUpId)?Padding(
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
                                          Text(toSentenceCase(students[index].userName),
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
                                            child: Text(("Password: "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Text(toSentenceCase(students[index].password),
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
                                            child: Text(("Class:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Text(toSentenceCase(students[index].stClass),
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
                                            child: Text(("Session:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Text(students[index].sessions.sessionDate.isNotEmpty
                                              ? toSentenceCase(students[index].sessions.sessionDate)
                                              : "unknown",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                              child: Text(("Boarding Status:  "),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: MyColors.primaryColor,
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                            Text(
                                                (students[index].boardingStatus)
                                                    ? toSentenceCase('Active')
                                                    : toSentenceCase('Inactive'),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: (students[index].boardingStatus)?Colors.green:Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                        onTap: (){
                                          _navigateToStudentProfileEditScreen(context, 'boarding status', students[index]);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ):Container(),
                            !fees?Padding(
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
                                    GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(("Gender:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            Text(
                                                (students[index].gender.isNotEmpty
                                                    ? students[index].gender
                                                    : "unknown"),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        _navigateToStudentProfileEditScreen(context, 'gender', students[index]);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(("DOB:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            Text(
                                                (students[index].dob.isNotEmpty)
                                                    ? students[index].dob
                                                    : "Unknown",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        _navigateToStudentProfileEditScreen(context, 'dob', students[index]);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(("Blood Group:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            Text(
                                                (students[index].bloodGroup.isNotEmpty)
                                                    ? students[index].bloodGroup
                                                    : "Unknown",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        _navigateToStudentProfileEditScreen(context, 'blood group', students[index]);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(("Genotype:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            Text(
                                                (students[index].genotype.isNotEmpty)
                                                    ? students[index].genotype
                                                    : "Unknown",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        _navigateToStudentProfileEditScreen(context, 'genotype', students[index]);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(("Health History:  "),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold)),
                                            Text(
                                                (students[index].healthHistory.isNotEmpty)
                                                    ? students[index].healthHistory
                                                    : "Unknown",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                      onTap: (){
                                        _navigateToStudentProfileEditScreen(context, 'health history', students[index]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ):Container(),
                            !fees?Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Card(
                                // margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                elevation: 2,
                                child: GestureDetector(
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
                                        Text(
                                            '${students[index].residentAddress}, ${students[index].city}, ${students[index].state}, ${students[index].nationality}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  onTap: (){
                                    _navigateToStudentProfileEditScreen(context, 'address', students[index]);
                                  },
                                ),
                              ),
                            ):Container(),
                            !fees?Padding(
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
                                      child: Text(("Parent Info  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ViewImage(imageUrl: ['${students[index].parentPassportLink}${students[index].parentPassport}'], heroTag: "parent image", placeholder: 'lib/assets/images/avatar.png', position: 0,),
                                                    ));
                                              },
                                              child: Hero(
                                                tag: "parent image",
                                                child: CircleAvatar(
                                                  radius: 100,
                                                  backgroundColor: Color(0xffFDCF09),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100.0),
                                                      child: FadeInImage.assetNetwork(
                                                        placeholderScale: 5,
                                                        height: 200,
                                                        width: 200,
                                                        fit: BoxFit.cover,
                                                        fadeInDuration: const Duration(seconds: 1),
                                                        fadeInCurve: Curves.easeInCirc,
                                                        placeholder: 'lib/assets/images/avatar.png',
                                                        image:'${students[index].parentPassportLink}${students[index].parentPassport}',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Text(
                                                '${students[index].parentTitle}, ${students[index].parentName}',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          onTap: (){
                                            _navigateToStudentProfileEditScreen(context, 'parent name', students[index]);
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                              (students[index].parentEmail.isNotEmpty)
                                                  ? students[index].parentEmail
                                                  : "Email Unknown",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.normal)),
                                        ),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Icon(
                                                    Icons.phone,
                                                    color: MyColors.primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                    (students[index].parentPhone.isNotEmpty)
                                                        ? students[index].parentPhone
                                                        : "Phone Unknown",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.teal,
                                                        fontWeight: FontWeight.normal)),
                                              ],
                                            ),
                                          ),
                                          onTap: (){
                                            if(students[index].parentPhone.isNotEmpty)
                                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number:students[index].parentPhone);
                                          },
                                          onLongPress: (){
                                            if(students[index].parentPhone.isNotEmpty)
                                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number:students[index].parentPhone);
                                          },
                                        ),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: MyColors.primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                    (students[index].parentAddress.isNotEmpty)
                                                        ? toSentenceCase(students[index].parentAddress)
                                                        : "Unknown",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.normal)),
                                              ],
                                            ),
                                          ),
                                          onTap: (){
                                            _navigateToStudentProfileEditScreen(context, 'parent address', students[index]);
                                          },
                                        ),
                                        GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 15.0),
                                                  child: Icon(
                                                    Icons.work,
                                                    color: MyColors.primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                    (students[index]
                                                        .parentOccupation
                                                        .isNotEmpty)
                                                        ? toSentenceCase(students[index].parentOccupation)
                                                        : "Unknown",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.normal)),
                                              ],
                                            ),
                                          ),
                                          onTap: (){
                                            _navigateToStudentProfileEditScreen(context, 'parent occupation', students[index]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ):Container(),
                            fees?Padding(
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
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Fees:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildFeesList(context, students[index].feesPayment.fees),
                                    ),
                                  ],
                                ),
                              ),
                            ):Container(),
                            fees?Padding(
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
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Fee Payments Details:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _buildFeesPaymentDetailsList(context, students[index].feesPayment.paymentDetails),
                                    ),
                                  ],
                                ),
                              ),
                            ):Container(),
                            fees?Padding(
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
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Fee Payments Summary:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: double.maxFinite,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                            child: Text(toSentenceCase(students[index].feesPayment.status.replaceAll('_', ' ')),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyColors.primaryColor,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                          child: Text('Total: ${convertPrice(currency: students[index].school.currency, amount: students[index].feesPayment.totalAmount)}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                          child: Text('Paid: ${convertPrice(currency: students[index].school.currency, amount: students[index].feesPayment.amountPaid)}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                          child: Text('Balance: ${convertPrice(currency: students[index].school.currency, amount: students[index].feesPayment.balance)}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ):Container(),
                          ]
                      ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildFeesList(BuildContext context, List<Fees> fees) {
    List<Widget> choices = List();
    int counter=0;
    fees.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child:Column(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      color: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('${++counter}',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(
                          color: Colors.black54,
                        ),
                        Container(
                          width: double.maxFinite,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(item.division.replaceAll("_", " ")),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text(toSentenceCase(item.title),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text('Amount: ${convertPrice(currency: students[index].school.currency, amount: item.amount)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewFees(feesRecord: item.feesRecord)),
                );
              },
            ),
          ],
        )
      ));
    });    return choices;
  }

  _buildFeesPaymentDetailsList(BuildContext context, List<FeesPaymentDetail> feesPaymentDetails) {
    List<Widget> choices = List();
    int counter=0;
    feesPaymentDetails.forEach((item) {
      choices.add(Container(
          padding: const EdgeInsets.all(2.0),
          child:Column(
            children: <Widget>[
              Divider(
                color: Colors.black54,
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Hero(
                        tag: "payment proof tag ${counter++}",
                        transitionOnUserGestures: true,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: FadeInImage.assetNetwork(
                              placeholderScale: 5,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(seconds: 1),
                              fadeInCurve: Curves.easeInCirc,
                              placeholder: MyStrings.logoPath,
                              image: item.paymentProofLink +
                                  item.paymentProof,
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImage(
                                imageUrl: [item.paymentProofLink + item.paymentProof],
                                heroTag: "payment proof tag ${counter++}",
                                placeholder: MyStrings.logoPath,
                                position: 0,
                              ),
                            ));
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                              child: Text(toSentenceCase(item.status.replaceAll('_', ' ')),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(item.paymentOption),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text('Amount Paid: ${convertPrice(currency: students[index].school.currency, amount: item.amountPaid)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                onTap: () {
                 // showOptionsModalBottomSheet(context: context, feesPaymentDetail: item);
                },
                onLongPress: (){
                  //showOptionsModalBottomSheet(context: context, feesPaymentDetail: item);
                },
              ),
            ],
          )
      ));
    });    return choices;
  }


  void showOptionsModalBottomSheet({BuildContext context, FeesPaymentDetail feesPaymentDetail}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
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
                      Icons.confirmation_number,
                      color: Colors.green,
                    ),
                    title: new Text('Confirm Payment'),
                    onTap: () {
                      Navigator.pop(context);
                      _feesBloc.add(ConfirmFeesPaymentEvent(students[index].feesPayment.recordId, feesPaymentDetail.id));
                    }),
              ],
            ),
          );
        });
  }

  _navigateToStudentProfileEditScreen(
      BuildContext context, String editing, Students students) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditStudentProfile(editing: editing, students: students,)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      //Refresh after update
      _viewStudents();
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
