import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/edit_student_profile.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/image_cropper.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'change_password.dart';

class StudentProfile extends StatelessWidget {
  final Students students;
  StudentProfile(this.students);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
          viewProfileRepository: ViewProfileRequest(),
          updateProfileRepository: UpdateProfileRequest()),
      child: StudentProfilePage(students),
    );
  }
}

// ignore: must_be_immutable
class StudentProfilePage extends StatelessWidget {
  final Students students;
  StudentProfilePage(this.students);
  ProfileBloc _profileBloc;
  bool _profileUpdating=false;

  void _viewProfile() async {
    _profileBloc.add(ViewStudentProfileEvent(await getApiToken(), students.id));
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
                    _profileBloc.add(UploadStudentImageEvent(students.id,
                        'data:image/jpeg;base64,${base64Encode(fileImage.readAsBytesSync())}'));
                  })
            ],
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if (state is StudentProfileLoaded) {
                  return _buildProfileAppBar(context: context, students: state.students, loaded: true);
                } else {
                  try{
                    return _buildProfileAppBar(context: context, students: students, loaded: true);
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
              } else if (state is StudentProfileLoaded) {
                _profileUpdating=false;
              } else if (state is ProfileUpdating) {
                _profileUpdating=true;
              } else if (state is ProfileUpdated) {
                _profileUpdating=false;
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if (state is StudentProfileLoaded) {
                  return _buildTeachersProfileDisplayScreen(
                      context: context, students: state.students, loaded: true);
                } else {
                  try{
                    return _buildTeachersProfileDisplayScreen(
                        context: context, students: students, loaded: true);
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
      {BuildContext context, Students students, bool loaded}) {
    return FlexibleSpaceBar(
        centerTitle: true,
        title: Text(loaded
            ? toSentenceCase(
            '${students.lName} ${students.fName} ${students.mName}')
            : ""),
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
                          imageUrl: [students.passportLink + students.passport],
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
                  loaded ? students.passportLink + students.passport : "",
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
      {BuildContext context, Students students, bool loaded}) {
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
                child: Text(
                    loaded
                        ? (students.admissionNumber.isEmpty
                        ? '${students.sessions.admissionNumberPrefix}${students.genAdmissionNumber}'
                        : '${students.sessions.admissionNumberPrefix}${students.admissionNumber}'):'Unknown',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.normal)),
              ),
              (students.phone.isNotEmpty)?Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(loaded ? students.email : "Contact email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  onTap: (){
                    _navigateToStudentProfileEditScreen(context, 'email', students);
                  },
                ),
              ):Container(),
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
                (students.userName.isNotEmpty)?ListTile(
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
                    child: Text(loaded ? students.userName : "Username",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                ):Container(),
                Divider(
                  color: Colors.black,
                ),
                (students.phone.isNotEmpty)?ListTile(
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
                    child: Text(loaded ? students.phone : "Phone number",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToStudentProfileEditScreen(context, 'phone', students);
                  },
                ):Container(),
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
                            ? '${toSentenceCase(students.residentAddress)}, ${toSentenceCase(students.city)}, ${toSentenceCase(students.state)}, ${toSentenceCase(students.nationality)}'
                            : "Address",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if (loaded)
                      _navigateToStudentProfileEditScreen(context, 'address', students);
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
                              ? (students.stClass.isEmpty)
                              ? "None yet"
                              : toSentenceCase(students.stClass)
                              : "None yet",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18, color: Colors.black87)),
                    ),
                  ),
                  onTap: () {},
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
                          Icons.calendar_today,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Session",
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
                            ? students.sessions.sessionDate.isNotEmpty
                            ? toSentenceCase(students.sessions.sessionDate)
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
                Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.location_city,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Boarding Status",
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
                            ? ((students.boardingStatus))
                            ? toSentenceCase('Active')
                            :  toSentenceCase('Inactive')
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: (students.boardingStatus)?Colors.green:Colors.black87,
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
                            ? (students.gender.isNotEmpty)
                            ? students.gender
                            : "unknown"
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToStudentProfileEditScreen(context, 'gender', students);
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
                            ? (students.dob.isNotEmpty)
                            ? students.dob
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
                    _navigateToStudentProfileEditScreen(context, 'dob', students);
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
                          Icons.group_work,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Blood Group",
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
                            ? (students.bloodGroup.isNotEmpty)
                            ? students.bloodGroup
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
                    _navigateToStudentProfileEditScreen(context, 'blood group', students);
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
                          Icons.filter_vintage,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Genotype",
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
                            ? (students.genotype.isNotEmpty)
                            ? students.genotype
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
                    _navigateToStudentProfileEditScreen(context, 'genotype', students);
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
                          Icons.history,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Health History",
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
                            ? (students.healthHistory.isNotEmpty)
                            ? students.healthHistory
                            : "Unknown"
                            : "Unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToStudentProfileEditScreen(context, 'health history', students);
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: Icon(Icons.camera_alt, color: MyColors.primaryColor,),
                              onPressed: () async {
                                final pickedImage=await pickImage(context, true);
                                File fileImage = await cropImage(File(pickedImage.path));
                                _profileBloc.add(UploadParentImageEvent(students.id,
                                    students.parentId, 'data:image/jpeg;base64,${base64Encode(fileImage.readAsBytesSync())}'));
                              }),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImage(imageUrl: loaded?['${students.parentPassportLink}${students.parentPassport}']:['parent image'], heroTag: "parent image", placeholder: 'lib/assets/images/avatar.png', position: 0,),
                            ));
                      },
                      child: Hero(
                        tag: "parent image",
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
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
                                        image:loaded?'${students.parentPassportLink}${students.parentPassport}':'school_image',
                                      ),
                                    ),
                                  ),
                                ),
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SelectableText(
                          '${toSentenceCase(students.parentTitle)}, ${toSentenceCase(students.parentName)}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        onTap: (){
                          _navigateToStudentProfileEditScreen(context, 'parent name', students);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SelectableText(
                          (students.parentEmail.isNotEmpty)
                              ? students.parentEmail
                              : "Email Unknown",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                              fontWeight: FontWeight.normal),
                        onTap: (){
                          //_navigateToStudentProfileEditScreen(context, 'parent email', students);
                        },),
                    ),
                    Padding(
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
                          SelectableText(
                              (students.parentPhone.isNotEmpty)
                                  ? students.parentPhone
                                  : "Phone Unknown",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            onTap: (){
                             // _navigateToStudentProfileEditScreen(context, 'parent phone', students);
                            },),
                        ],
                      ),
                    ),
                    Padding(
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
                          SelectableText(
                              (students.parentAddress.isNotEmpty)
                                  ? toSentenceCase(students.parentAddress)
                                  : "Unknown",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            onTap: (){
                              _navigateToStudentProfileEditScreen(context, 'parent address', students);
                            },),
                        ],
                      ),
                    ),
                    Padding(
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
                          SelectableText(
                              (students
                                  .parentOccupation
                                  .isNotEmpty)
                                  ? toSentenceCase(students.parentOccupation)
                                  : "Unknown",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            onTap: (){
                              _navigateToStudentProfileEditScreen(context, 'parent occupation', students);
                            },),
                        ],
                      ),
                    ),
                  ],
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
                          Icons.monetization_on,
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
                            ? (students.currency.currencyName.isNotEmpty)
                            ? '${students.currency.currencyName.replaceAll('null', 'Unkonwn')} (${students.currency.secondCurrency})'
                            : "unknown"
                            : "unknown",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToStudentProfileEditScreen(context, 'currency', students);
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
                    _navigateToChangeStudentPasswordScreen(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
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
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _viewProfile();
    }
  }

  _navigateToChangeStudentPasswordScreen(BuildContext context) async {
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
}
