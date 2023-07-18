import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/forgot_password/forgot_password.dart';
import 'package:school_pal/blocs/forgot_password/forgot_password_bloc.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/forgot_password_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';

class ForgotPassword extends StatelessWidget {
  final String loginAs;
  ForgotPassword({this.loginAs});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(forgotPasswordRepository: ForgotPasswordRequests()),
      child: ForgotPasswordPage(loginAs),
    );
  }
}

// ignore: must_be_immutable
class ForgotPasswordPage extends StatelessWidget {
  final String loginAs;
  ForgotPasswordPage(this.loginAs);
  int _currentPage=0;
  bool _obscureText = true;
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ForgotPasswordBloc _forgotPasswordBloc;

  String message;
  String otp;

  @override
  Widget build(BuildContext context) {
    _forgotPasswordBloc = BlocProvider.of<ForgotPasswordBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password",
              style: TextStyle(color: MyColors.primaryColor)),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MyColors.primaryColor),
        ),
        //backgroundColor: Colors.white,
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: BlocListener<ForgotPasswordBloc, ForgotPasswordStates>(
                  listener: (BuildContext context, ForgotPasswordStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
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
                    } else if (state is ViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    }else if (state is VisiblePasswordState) {
                      _obscureText = state.password;
                    }else if (state is ForgotPasswordActivated) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      message=state.message['message'];
                      otp=state.message['otp'];
                      _currentPage=1;
                    }else if (state is OtpVerified) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      message=state.message['message'];
                      otp=state.message['otp'];
                      _currentPage=2;
                    }else if (state is PasswordResetDone) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      showMessageModalDialog(context: context, message: state.message['message'], buttonText: 'Continue', closeable: false)
                          .then((value) =>Navigator.pop(context));
                    }
                  },
                  child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordStates>(
                    builder: (BuildContext context, ForgotPasswordStates state) {
                      if(state is ForgotPasswordInitial){
                        return _initialForgotPasswordWidget(context: context, message: "Please provide your account email to continue!");
                      }else if(state is ForgotPasswordActivated){
                        return _verifyOtpWidget(context: context, message: state.message['message']);
                      }else if(state is OtpVerified){
                        return _resetPasswordWidget(context: context, message: state.message['message']);
                      }else{
                        return (_currentPage==0)
                            ?_initialForgotPasswordWidget(context: context, message: "Please provide your account email to continue!")
                        :(_currentPage==1)?_verifyOtpWidget(context: context, message: message)
                        : _resetPasswordWidget(context: context, message: message);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ));
  }


  Widget _initialForgotPasswordWidget({BuildContext context, String message}){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
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
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator:validateEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon:
                  Icon(Icons.email, color: Colors.blue),
                  labelText:'Email',
                  labelStyle:
                  new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.maxFinite,
              //height: double.maxFinite,
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _forgotPasswordBloc.add(ForgotPasswordEvent(emailController.text));
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
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _verifyOtpWidget({BuildContext context, String message}){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
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
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PinCodeTextField(
              appContext: context,
              length: 5,
              obscureText: false,
              autoFocus: true,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              autoDismissKeyboard: true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.white.withOpacity(0.0),
              enableActiveFill: true,
              controller: otpController,
              onCompleted: (v) {
                if(v==otp){
                  _forgotPasswordBloc.add(VerifyOtpEvent(v));
                }
                print("Completed");
              },
              onChanged: (value) {
                print(value);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.maxFinite,
              //height: double.maxFinite,
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _forgotPasswordBloc.add(VerifyOtpEvent(otpController.text));
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
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _resetPasswordWidget({BuildContext context, String message}){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
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
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passwordController,
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
                      _forgotPasswordBloc.add(
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
              controller: confirmPasswordController,
              keyboardType:
              TextInputType.visiblePassword,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please confirm new password.';
                }
                if (value.length < 6) {
                  return 'Password too short.';
                }
                if (value != passwordController.text) {
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
                      _forgotPasswordBloc.add(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.maxFinite,
              //height: double.maxFinite,
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _forgotPasswordBloc.add(ResetPasswordEvent(passwordController.text, confirmPasswordController.text, otp));
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
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

}
