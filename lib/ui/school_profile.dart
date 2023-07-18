import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/change_password.dart';
import 'package:school_pal/ui/edit_school_profile.dart';
import 'package:school_pal/ui/school_settings.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/image_cropper.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';

class SchoolProfile extends StatelessWidget {
  final School school;
  final bool edit;
  SchoolProfile({this.school, this.edit});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(viewProfileRepository: ViewProfileRequest(),
              updateProfileRepository: UpdateProfileRequest()),
      child: SchoolProfilePage(school, edit),
    );
  }
}

// ignore: must_be_immutable
class SchoolProfilePage extends StatelessWidget {
  final School school;
  final bool edit;
  SchoolProfilePage(this.school, this.edit);
  ProfileBloc _profileBloc;
  bool _profileUpdating=false;
  void _viewProfile() async {
    _profileBloc.add(ViewSchoolProfileEvent(await getApiToken()));
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
              edit?IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    final pickedImage=await pickImage(context, true);
                    File fileImage = await cropImage(File(pickedImage.path));
                    print(fileImage.toString().split('.')[fileImage.toString().split('.').length-1]);
                    _profileBloc.add(UploadSchoolLogoEvent('data:image/jpeg;base64,${base64Encode(fileImage.readAsBytesSync())}'));
                  }):Container()
            ],
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                //Todo: note builder returns widget
                if (state is SchoolProfileLoaded) {
                  return _buildProfileAppBar(
                      context: context, school: state.school, loaded: true);
                } else {
                  try{
                    return _buildProfileAppBar(
                        context: context, school: school, loaded: true);
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
              }else if (state is ProfileUpdating) {
                _profileUpdating=true;
              } else if (state is ProfileUpdated) {
                _profileUpdating=false;
              }else if (state is SchoolProfileLoaded){
                _profileUpdating=false;
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if (state is SchoolProfileLoaded) {
                  return _buildSchoolProfileDisplayScreen(
                      context: context, school: state.school, loaded: true);
                } else {
                  try{
                    return _buildSchoolProfileDisplayScreen(
                        context: context, school: school, loaded: true);
                  }on NoSuchMethodError{
                    return _buildSchoolProfileDisplayScreen(
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
      {BuildContext context, School school, bool loaded}) {
    return FlexibleSpaceBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              if(loaded)
                _navigateToSchoolProfileEditScreen(context, 'name', school);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(loaded ? toSentenceCase(school.name) : "School name", textAlign: TextAlign.center,),
            )),
        titlePadding: const EdgeInsets.all(5.0),
        background: CustomPaint(
          painter: ProfilePainter(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewImage(imageUrl: loaded?['${school.imageLink}${school.image}']:['school_image'], heroTag: "school profile picture", placeholder: 'lib/assets/images/avatar.png', position: 0,),
                      ));
                },
                child: Hero(
                  tag: "school profile picture",
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Center(
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Color(0xffFDCF09),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: FadeInImage.assetNetwork(
                                placeholderScale: 5,
                                height: 200,
                                width: 200,
                                fit: BoxFit.fill,
                                fadeInDuration: const Duration(seconds: 1),
                                fadeInCurve: Curves.easeInCirc,
                                placeholder: 'lib/assets/images/avatar.png',
                                image:loaded?'${school.imageLink}${school.image}':'school_image',
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
            ],
          ),
        ));
  }

  _buildSchoolProfileDisplayScreen(
      {BuildContext context, School school, bool loaded}) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Card(
          // margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(loaded ? school.email : "School email",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    color: MyColors.primaryColor,
                    fontWeight: FontWeight.bold)),
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
                /*ListTile(
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
                    child: Text(loaded ? school.userName : "Username",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),*/
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
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? school.phone : "School phone",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'phone', school);
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
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded
                        ? '${toSentenceCase(school.address)}, ${toSentenceCase(school.city)}, ${toSentenceCase(school.town)}, ${toSentenceCase(school.nationality)}'
                        : "School address",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'address', school);
                  },
                ),
                (loaded&&school.website.isEmpty&&!edit)
                    ?Container():Divider(
                  color: Colors.black,
                ),
                (loaded&&school.website.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.web,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Website",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? school.website.isNotEmpty? school.website: 'Enter your school website': "School website",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'website', school);
                  },
                ),
                (loaded&&school.facebook.isEmpty&&!edit)
                    ?Container():Divider(
                  color: Colors.black,
                ),
                (loaded&&school.facebook.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.chat,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Facebook",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? school.facebook.isNotEmpty? school.facebook: 'Enter your school facebook handle' : "School facebook handle",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'facebook', school);
                  },
                ),
                (loaded&&school.twitter.isEmpty&&!edit)
                    ?Container():Divider(
                  color: Colors.black,
                ),
                (loaded&&school.twitter.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.chat,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Twitter",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? school.twitter.isNotEmpty? school.twitter: 'Enter your school twitter handle' : "School twitter handle",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'twitter', school);
                  },
                ),
                (loaded&&school.instagram.isEmpty&&!edit)
                    ?Container():Divider(
                  color: Colors.black,
                ),
                (loaded&&school.instagram.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.chat,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Instagram",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded ? school.instagram.isNotEmpty? school.instagram: 'Enter your school instagram handle' : "School instagram handle",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'instagram', school);
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
                  child: Text("About",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                ),
                (loaded&&school.slogan.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.business,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Slogan",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded
                        ? school.slogan.isNotEmpty
                        ? toSentenceCase(school.slogan)
                        : "Add a slogan"
                        : "School slogan",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'slogan', school);
                  },
                ),
                (loaded&&school.poBox.isEmpty&&!edit)
                    ?Container():Divider(
                  color: Colors.black,
                ),
                (loaded&&school.poBox.isEmpty&&!edit)
                    ?Container():ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.polymer,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("P.O. Box",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded
                        ? school.poBox.isNotEmpty
                        ? toSentenceCase(school.poBox)
                        : "Add a P.O Box"
                        : "School P.O Box",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    if(loaded)
                      _navigateToSchoolProfileEditScreen(context, 'poBox', school);
                  },
                ),
              ],
            ),
          ),
        ),
        edit?Padding(
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
                            ? (school.currency.currencyName.isNotEmpty)
                            ? '${school.currency.currencyName.replaceAll('null', 'Unkonwn')} (${school.currency.secondCurrency})'
                            : "Choose a currency"
                            : "",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: () {
                    _navigateToSchoolProfileEditScreen(context, 'currency', school);
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
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text("Change your account password",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: (){
                    _navigateToChangeSchoolPasswordScreen(context);
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
                          Icons.settings,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Settings",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text("Change your account settings",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal)),
                  ),
                  onTap: (){
                    _navigateToSettingsScreen(context, school);
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
                          Icons.stars,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      Text("Account Status",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                    child: Text(loaded
                        ? (school.status=="yes"&&!school.deleted)
                        ? "Active"
                        : "Inactive"
                        : "Account status",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: loaded?(school.status=="yes"&&!school.deleted)?Colors.green:Colors.red:Colors.green,
                            fontWeight: FontWeight.normal)),
                  ),
                ),
              ],
            ),
          ),
        ):Container(),
      ]),
    );
  }

  _navigateToSchoolProfileEditScreen(BuildContext context, String editing, School school) async {
    if(edit) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            EditSchoolProfile(editing: editing, school: school,)),
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
  }

  _navigateToChangeSchoolPasswordScreen(BuildContext context) async {
    if(edit){
      String loggedInAs=await getLoggedInAs();
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChangePassword(loggedInAs: loggedInAs,)),
      );

      // After the Selection Screen returns a result, hide any previous snackbars
      // and show the new result.
      if(result!=null){
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      }
    }
  }

  _navigateToSettingsScreen(BuildContext context, School school) async {
    if(edit){
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchoolSettings(school: school)),
      );

      // After the Selection Screen returns a result, hide any previous snackbars
      // and show the new result.
      if(result!=null){
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      }
    }
  }

}
