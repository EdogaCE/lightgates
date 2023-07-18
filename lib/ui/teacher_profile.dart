import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/edit_teacher_profile.dart';
import 'package:school_pal/ui/form_teacher_class.dart';
import 'package:school_pal/ui/teacher_class_subject.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/image_cropper.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'change_password.dart';

class TeacherProfile extends StatelessWidget {
  final Teachers teachers;
  TeacherProfile(this.teachers);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
          viewProfileRepository: ViewProfileRequest(),
          updateProfileRepository: UpdateProfileRequest()),
      child: TeacherProfilePage(teachers),
    );
  }
}

// ignore: must_be_immutable
class TeacherProfilePage extends StatelessWidget {
  final Teachers teachers;
  TeacherProfilePage(this.teachers);
  ProfileBloc _profileBloc;
  List<String> subjects, classes;
  bool _profileUpdating=false;
  void _viewProfile() async {
    subjects = teachers.subjects;
    classes = teachers.classes;
    _profileBloc.add(ViewTeacherProfileEvent(await getApiToken(), teachers.id));
  }

  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _viewProfile();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    final pickedImage=await pickImage(context, true);
                    File fileImage = await cropImage(File(pickedImage.path));
                    _profileBloc.add(UploadTeacherImageEvent(teachers.id,
                        'data:image/jpeg;base64,${base64Encode(fileImage.readAsBytesSync())}'));
                  })
            ],
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if (state is TeacherProfileLoaded) {
                  return _buildProfileAppBar(context: context, teachers: state.teachers, loaded: true);
                } else {
                  try{
                    return _buildProfileAppBar(context: context, teachers: teachers, loaded: true);
                  }on NoSuchMethodError{
                    return _buildProfileAppBar(context: context, loaded: false);
                  }
                }
              },
            ),
          ),
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (context, state) {
              //Todo: note listener returns void
              if (state is NetworkErr) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              } else if (state is ViewError) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
                if (state.message == "Please Login to continue") {
                  reLogUserOut(context);
                }
              } else if (state is TeacherProfileLoaded) {
                _profileUpdating=false;
                if (state.teachers.classes.isNotEmpty) {
                  subjects = state.teachers.subjects;
                  classes = state.teachers.classes;
                }
              }else if (state is ProfileUpdating) {
                _profileUpdating=true;
              } else if (state is ProfileUpdated) {
                _profileUpdating=false;
                _viewProfile();
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if (state is TeacherProfileLoaded) {
                  return _buildTeachersProfileDisplayScreen(context: context, teachers: state.teachers, loaded: true);
                } else {
                  try{
                    return _buildTeachersProfileDisplayScreen(context: context, teachers: teachers, loaded: true);
                  }on NoSuchMethodError{
                    return _buildTeachersProfileDisplayScreen(
                        context: context, loaded: false);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAppBar(
      {BuildContext context, Teachers teachers, bool loaded}) {
    return FlexibleSpaceBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              if (loaded)
                _navigateToTeacherProfileEditScreen(context, 'name', teachers);
            },
            child: Text(loaded
                ? toSentenceCase(
                    '${teachers.title} ${teachers.lName} ${teachers.fName} ${teachers.mName}')
                : "")),
        titlePadding: const EdgeInsets.all(8.0),
        background: Hero(
          tag: "profile picture",
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewImage(
                          imageUrl: [teachers.passportLink + teachers.passport],
                          heroTag: "teacher passport tag",
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
                  image:
                      loaded ? teachers.passportLink + teachers.passport : "",
                ),
              ),
              Center(
                  child: _profileUpdating
                      ? CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        MyColors.primaryColor),
                    backgroundColor: Colors.white,
                  ):Container())
            ],
          ),
        ));
  }

  _buildTeachersProfileDisplayScreen(
      {BuildContext context, Teachers teachers, bool loaded}) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Card(
          // margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          elevation: 2,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(loaded ? teachers.email : "Contact email",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              /*(teachers.role.toString().isNotEmpty)?Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    loaded
                        ? (teachers.role.toString().isNotEmpty)
                            ? teachers.role.toString()
                            : "Unknown"
                        : "Unknown",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.normal)),
              ):Container(),*/
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
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
                  child: Text("Contacts",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.person,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Username",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? teachers.userName : "Username",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.phone,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Phone",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? teachers.phone : "Phone number",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToTeacherProfileEditScreen(context, 'phone', teachers);
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.location_on,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Address",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? '${toSentenceCase(teachers.address)}, ${toSentenceCase(teachers.city)}, ${toSentenceCase(teachers.state)}, ${toSentenceCase(teachers.nationality)}'
                            : "Address",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToTeacherProfileEditScreen(context, 'address', teachers);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
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
                  child: Text("School",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.class_,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Class",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          loaded
                              ? (classes.isEmpty)
                                  ? "None yet"
                                  : "See Classes and Subjects asigned to you"
                              : "None yet",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18, color: Colors.blue)),
                    ),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToTeacherClassSubjectScreen(context, teachers, 'Your classes and subjects');
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.class_,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Form Class",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          loaded
                              ? (teachers.formClasses.isEmpty)
                              ? "None yet"
                              : "See Form Classes asigned to you"
                              : "None yet",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18, color: Colors.blue)),
                    ),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToFormTeacherClassScreen(context, teachers, 'Your Form Classes');
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.monetization_on,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Salary",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? teachers.salary.isNotEmpty
                                ? convertPrice(currency: teachers.currency, amount: teachers.salary)
                                : "unknown"
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
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
                  child: Text("About",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.supervised_user_circle,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Gender",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? (teachers.gender.isNotEmpty)
                                ? teachers.gender
                                : "unknown"
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToTeacherProfileEditScreen(context, 'gender', teachers);
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.date_range,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("DOB",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? (teachers.dob.isNotEmpty)
                                ? teachers.dob
                                : "Unknown"
                            : "Unknown",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToTeacherProfileEditScreen(context, 'dob', teachers);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
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
                  child: Text("Account",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.attach_money,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Preferred Currency",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? (teachers.currency.currencyName.isNotEmpty)
                            ? '${teachers.currency.currencyName.replaceAll('null', 'Unkonwn')} (${teachers.currency.secondCurrency})'
                            : "unknown"
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToTeacherProfileEditScreen(context, 'currency', teachers);
                  },
                ),
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Bank Details",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(
                        loaded
                            ? (teachers.bankName.isNotEmpty && teachers.bankAccountNumber.isNotEmpty)
                            ? '${teachers.bankName} [${teachers.bankAccountNumber}]'
                            : "Please add your bank detail"
                            : "Please add your bank detail",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToTeacherProfileEditScreen(context, 'bank detail', teachers);
                  },
                ),
                Visibility(
                  visible: teachers.isFormTeacher,
                  child: Divider(
                    color: Colors.black,
                  ),
                ),
                Visibility(
                  visible: teachers.isFormTeacher,
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.attach_file,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        Text("Signatory Area",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                      child:_profileUpdating
                          ? LinearProgressIndicator(
                            minHeight: 2.0,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                MyColors.primaryColor),
                            backgroundColor: Colors.white,
                          ):teachers.signatoryArea.isNotEmpty
                          ?FadeInImage.assetNetwork(
                        fit: BoxFit.scaleDown,
                        height: 50,
                        fadeInDuration: const Duration(seconds: 1),
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: 'lib/assets/images/logo.png',
                        image: loaded ? teachers.signatoryAreaUrl + teachers.signatoryArea : "",
                      ):Text("Attach your signatory",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.normal)),
                    ),
                    onTap: () async{
                      final pickedImage=await pickImage(context, true);
                      File fileImage = await cropImage(File(pickedImage.path));
                      _profileBloc.add(UploadTeacherSignatoryEvent(teachers.id, fileImage.path));
                    },
                  ),
                ),

                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.vpn_key,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Password",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text("Change your account password",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToChangeTeacherPasswordScreen(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
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
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _viewProfile();
    }
  }

  _navigateToChangeTeacherPasswordScreen(BuildContext context) async {
    String loggedInAs = await getLoggedInAs();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChangePassword(
                loggedInAs: loggedInAs,
              )),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("$result", textAlign: TextAlign.center)));
    }
  }

  _navigateToFormTeacherClassScreen(
      BuildContext context, Teachers teachers, String titile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormTeacherClass(teachers: teachers,
          teacher: titile)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      Navigator.pop(context, result);
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
      Navigator.pop(context, result);
    }
  }
}
