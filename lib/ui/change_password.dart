import 'package:flutter/material.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'general.dart';

class ChangePassword extends StatelessWidget {
  final String loggedInAs;
  ChangePassword({this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(updateProfileRepository: UpdateProfileRequest()),
      child: ChangePasswordPage(loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class ChangePasswordPage extends StatelessWidget {
  final String loggedInAs;
  ChangePasswordPage(this.loggedInAs);
  bool _obscureText = true;
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ProfileBloc _profileBloc;
  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Change Password",
              style: TextStyle(color: MyColors.primaryColor)),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MyColors.primaryColor),
        ),
        //backgroundColor: Colors.white,
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            BlocListener<ProfileBloc, ProfileStates>(listener:
                                (BuildContext context, ProfileStates state) {
                              if (state is VisiblePasswordState) {
                                _obscureText = state.password;
                              }
                            }, child: BlocBuilder<ProfileBloc, ProfileStates>(
                              builder:
                                  (BuildContext context, ProfileStates state) {
                                return Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: oldController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter old password.';
                                          }
                                          if (value.length < 6) {
                                            return 'Password too short.';
                                          }
                                          return null;
                                        },
                                        obscureText: _obscureText,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(25.0),
                                              ),
                                            ),
                                            //icon: Icon(Icons.email),
                                            prefixIcon: Icon(Icons.vpn_key,
                                                color: Colors.pink),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _profileBloc.add(
                                                    VisiblePassword(
                                                        !_obscureText));
                                              },
                                              icon: Icon(_obscureText?Icons.visibility:Icons.visibility_off_rounded),
                                            ),
                                            labelText: 'Current Password',
                                            labelStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            filled: true,
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: newController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter new password.';
                                          }
                                          if (value.length < 6) {
                                            return 'Password too short.';
                                          }
                                          return null;
                                        },
                                        obscureText: _obscureText,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(25.0),
                                              ),
                                            ),
                                            //icon: Icon(Icons.email),
                                            prefixIcon: Icon(Icons.lock,
                                                color: Colors.teal),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _profileBloc.add(
                                                    VisiblePassword(
                                                        !_obscureText));
                                              },
                                              icon: Icon(_obscureText?Icons.visibility:Icons.visibility_off_rounded),
                                            ),
                                            labelText: 'New Password',
                                            labelStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            filled: true,
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: confirmController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please confirm new password.';
                                          }
                                          if (value.length < 6) {
                                            return 'Password too short.';
                                          }
                                          if (value != newController.text) {
                                            return 'Password mismatch';
                                          }
                                          return null;
                                        },
                                        obscureText: _obscureText,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(25.0),
                                              ),
                                            ),
                                            //icon: Icon(Icons.email),
                                            prefixIcon: Icon(Icons.lock,
                                                color: Colors.indigo),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _profileBloc.add(
                                                    VisiblePassword(
                                                        !_obscureText));
                                              },
                                              icon: Icon(_obscureText?Icons.visibility:Icons.visibility_off_rounded),
                                            ),
                                            labelText: 'Confirm Password',
                                            labelStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            filled: true,
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _doneButtonFill(context),
                            )
                          ],
                        ),
                      ) //'poBox'
                      ),
                ),
              ),
              BlocListener<ProfileBloc, ProfileStates>(
                listener: (BuildContext context, ProfileStates state) {
                  if (state is ProfileUpdating) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Updating..."),
                      ),
                    );
                  } else if (state is NetworkErr) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content:
                            Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  } else if (state is UpdateError) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content:
                            Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  } else if (state is ProfileUpdated) {
                    Navigator.pop(context, state.message);
                  }
                },
                child: BlocBuilder<ProfileBloc, ProfileStates>(
                  builder: (BuildContext context, ProfileStates state) {
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget _doneButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            switch (loggedInAs) {
              case MyStrings.student:
                {
                  _profileBloc.add(ChangeStudentPasswordEvent(
                      oldController.text,
                      newController.text,
                      confirmController.text));
                  break;
                }
              case MyStrings.teacher:
                {
                  _profileBloc.add(ChangeTeacherPasswordEvent(
                      oldController.text,
                      newController.text,
                      confirmController.text));
                  break;
                }
              case MyStrings.school:
                {
                  _profileBloc.add(ChangeSchoolPasswordEvent(oldController.text,
                      newController.text,
                      confirmController.text));
                  break;
                }
            }
          }
        },
        textColor: Colors.white,
        color: MyColors.primaryColor,
        padding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
          child: const Text("Done", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
