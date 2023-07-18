import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/login/login.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/login_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/dashboard.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/ui/forgot_password.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/register.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/utils/system.dart';

class Login extends StatelessWidget {
  final String loginAs;
  Login({Key key, @required this.loginAs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(LoginRequests()),
      child: LoginPage(loginAs),
    );
  }
}

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  final String loginAs;
  LoginPage(this.loginAs);

  bool _obscureText = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String schoolDropdownValue = '---School---';
  List<String> schoolSpinnerItems = ["---School---"];
  List<String> schoolsSpinnerIds = ['0'];
  // ignore: close_sinks
  LoginBloc loginBloc;
  @override
  Widget build(BuildContext context) {
    loginBloc = BlocProvider.of<LoginBloc>(context);
    //if (loginAs != 'school') loginBloc.add(ViewSchoolCategoriesEvent());
    // TODO: implement build
    return Scaffold(
        /*appBar: AppBar(
        title: Text("Login"),
      ),*/
        //backgroundColor: Colors.white,
        body: CustomPaint(
      painter: BackgroundPainter(),
      child: Form(
        key: _formKey,
        child: BlocListener<LoginBloc, LoginStates>(
          listener: (BuildContext context, LoginStates state) {
            if (state is UserLoading) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(minutes: 30),
                  content: General.progressIndicator("Logging-in..."),
                ),
              );
            } else if (state is NetworkErr) {
              Scaffold.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                SnackBar(
                  content: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            } else if (state is UserError) {
              if(state.message=='Your account is not activated! Please confirm your email to activate.'){
                retrieveLoginDetailsFromSF().then((user) {
                  _navigateToRegisterScreen(context: context, user: user, password: passwordController.text, position: 3);
                });

              }
              Scaffold.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message, textAlign: TextAlign.center),
                  ),
                );
            } else  if (state is VisiblePasswordState) {
              _obscureText = state.password;
            } /*else if (state is SpinnerDataSelected) {
              schoolDropdownValue = state.selectedData;
            } else if (state
            is SchoolCategoriesLoaded) {
              schoolSpinnerItems
                  .addAll(state.schools[0]);
              schoolsSpinnerIds
                  .addAll(state.schools[1]);
            } */else if (state is UserLoaded) {
              Scaffold.of(context).removeCurrentSnackBar();
              if((loginAs==MyStrings.school)&&(state.user.videoForVerification.isEmpty)){
                /// Continue with video upload under registration page
                _navigateToRegisterScreen(context: context, user: state.user, password: passwordController.text, position: 4);
                emailController.clear();
                passwordController.clear();
              }else if((loginAs==MyStrings.school)&&(!state.user.verificationStatus)){
                /// Display user dashboard but deactivate actions
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                        loggedInAs: loginAs,
                        user: state.user,
                      )),
                  ModalRoute.withName('/'),
                );
                saveFirstTimeSetupPageToSF(state.user.firstTimeSetupPage);
                saveLoginDetailsToSF(
                    false,
                    state.user.id,
                    state.user.uniqueId,
                    state.user.userName,
                    state.user.contactPhone,
                    state.user.contactEmail,
                    "${state.user.address}, ${state.user.town}, ${state.user.lga}, ${state.user.city}, ${state.user.nationality}",
                    state.user.apiToken,
                    state.user.userChatId,
                    state.user.userChatType,
                    loginAs,
                    state.user.verificationStatus,
                    state.user.videoForVerification,
                    state.user.firstTimeLogin
                );
              }else if((loginAs==MyStrings.school)&&(state.user.firstTimeLogin)){
                // Display settings
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                        loggedInAs: loginAs,
                        user: state.user,
                      )),
                  ModalRoute.withName('/'),
                );
                saveFirstTimeSetupPageToSF(state.user.firstTimeSetupPage);
                saveLoginDetailsToSF(
                    true,
                    state.user.id,
                    state.user.uniqueId,
                    state.user.userName,
                    state.user.contactPhone,
                    state.user.contactEmail,
                    "${state.user.address}, ${state.user.town}, ${state.user.lga}, ${state.user.city}, ${state.user.nationality}",
                    state.user.apiToken,
                    state.user.userChatId,
                    state.user.userChatType,
                    loginAs,
                    state.user.verificationStatus,
                    state.user.videoForVerification,
                    state.user.firstTimeLogin
                );

              }else{
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                        loggedInAs: loginAs,
                        user: state.user,
                      )),
                  ModalRoute.withName('/'),
                );
                saveLoginDetailsToSF(
                    true,
                    state.user.id,
                    state.user.uniqueId,
                    state.user.userName,
                    state.user.contactPhone,
                    state.user.contactEmail,
                    "${state.user.address}, ${state.user.town}, ${state.user.lga}, ${state.user.city}, ${state.user.nationality}",
                    state.user.apiToken,
                    state.user.userChatId,
                    state.user.userChatType,
                    loginAs,
                    state.user.verificationStatus,
                    state.user.videoForVerification,
                    state.user.firstTimeLogin
                );

              }

            }
          },
          child: BlocBuilder<LoginBloc, LoginStates>(
            builder: (BuildContext context, LoginStates state) {
              return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            (loginAs==MyStrings.teacher||loginAs==MyStrings.student)?Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                // margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text("You must create a school account first before you can create teachers and students.",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ),
                            ):Animator(
                              repeats: 1,
                              duration: Duration(seconds: 2),
                              builder: (context, anim, child) => Opacity(
                                opacity: anim.value,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                      bottom: 20.0,
                                      top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      "lib/assets/images/avatar.png",
                                      scale: 4,
                                      colorBlendMode: BlendMode.darken,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /*(loginAs != 'school')
                          ? Stack(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0),
                                      child: Text("Select School",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: MyColors
                                                  .primaryColor,
                                              fontWeight:
                                              FontWeight.normal)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 1.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              25.0),
                                          border: Border.all(
                                              color: Colors
                                                  .deepPurpleAccent,
                                              style:
                                              BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              left: 10.0,
                                              right: 20.0),
                                          child:
                                          DropdownButton<String>(
                                            isExpanded: true,
                                            value:
                                            schoolDropdownValue,
                                            icon: Icon(Icons
                                                .arrow_drop_down),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                            underline: Container(
                                              height: 0,
                                              color: Colors
                                                  .deepPurpleAccent,
                                            ),
                                            onChanged: (String data) {
                                              loginBloc.add(
                                                  SelectSpinnerDataEvent(
                                                      data));
                                            },
                                            items: schoolSpinnerItems
                                                .map<
                                                DropdownMenuItem<
                                                    String>>((String
                                            value) {
                                              return DropdownMenuItem<
                                                  String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                (state is Loading)
                                    ? Align(
                                  alignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(
                                        100.0),
                                    child: Container(
                                        color: Colors.white,
                                        child: Padding(
                                          padding:
                                          const EdgeInsets
                                              .all(20.0),
                                          child:
                                          CircularProgressIndicator(
                                            valueColor:
                                            new AlwaysStoppedAnimation<
                                                Color>(
                                                Colors
                                                    .deepPurple),
                                            backgroundColor:
                                            Colors.pink,
                                          ),
                                        )),
                                  ),
                                )
                                    : Container(),
                              ],
                            )
                          : Container(),*/
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator:(loginAs != MyStrings.school)?(value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your username.';
                                  }
                                  return null;
                                }:validateEmail,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(25.0),
                                      ),
                                    ),
                                    //icon: Icon(Icons.email),
                                    prefixIcon:
                                    Icon((loginAs != MyStrings.school)?Icons.person:Icons.email, color: Colors.blue),
                                    labelText: (loginAs != MyStrings.school)?'Username':'Email',
                                    labelStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your password.';
                                  }
                                  if (value.length < 6) {
                                    return 'Password too short.';
                                  }
                                  return null;
                                },
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(25.0),
                                      ),
                                    ),
                                    //icon: Icon(Icons.email),
                                    prefixIcon: Icon(Icons.lock, color: Colors.pink),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        loginBloc.add(
                                            VisiblePassword(!_obscureText));
                                      },
                                      icon: Icon(_obscureText?Icons.visibility:Icons.visibility_off_rounded),
                                    ),
                                    labelText: 'Password',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: _forgotPasswordButtonFill(
                                      context) /*InkWell(
                                onTap: _openForgotPasswordPage(),
                                child: Text(
                                    "Forgot password ?",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 18, color: Colors.blue)
                                ),
                              ),*/
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _loginButtonFill(context),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _registerButtonFill(
                                    context) /*InkWell(
                              //onTap: ()=> new LaunchRequest().launchURL(MyStrings.registerUrl),
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Register()),
                                );
                              },
                              child: Text(
                                  "New School? Register",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18, color: Colors.blue)
                              ),
                            ),*/
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  Widget _loginButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            switch (loginAs) {
              case MyStrings.student:
                {
                  loginBloc.add(LoginStudent(emailController.text, passwordController.text));
                  break;
                }
              case MyStrings.teacher:
                {
                  loginBloc.add(LoginTeacher(
                      /*schoolsSpinnerIds[
                          schoolSpinnerItems.indexOf(schoolDropdownValue)],*/
                      emailController.text, passwordController.text));
                  break;
                }
              case MyStrings.school:
                {
                  loginBloc.add(LoginSchool(
                      emailController.text, passwordController.text));
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
          child: const Text("Login", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  Widget _registerButtonFill(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Register(continueRegistration: false,)));
      },
      textColor: Colors.white,
      color: MyColors.transparent,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 20.0, top: 2.0, right: 20.0, bottom: 2.0),
        child: const Text("New School?  Register",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: Colors.blue /*, decoration: TextDecoration.underline*/)),
      ),
    );
  }

  Widget _forgotPasswordButtonFill(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPassword(loginAs: loginAs,)),
        );
      },
      textColor: Colors.white,
      color: MyColors.transparent,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 20.0, top: 2.0, right: 20.0, bottom: 2.0),
        child: const Text("Forgot password ?",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18,
                color: Colors.blue /*, decoration: TextDecoration.underline*/)),
      ),
    );
  }

  _navigateToRegisterScreen(
      {BuildContext context, User user,  String password, int position}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register(continueRegistration: true, user: user, password: passwordController.text, position: position,)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      //Refresh after update
     Navigator.pop(context);
    }
  }
}
