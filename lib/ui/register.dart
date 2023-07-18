import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/register/register.dart';
import 'package:school_pal/blocs/register/register_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/verify_registration_requests.dart';
import 'package:school_pal/requests/posts/register_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/dashboard.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/video_player.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'package:video_player/video_player.dart';


class Register extends StatelessWidget {
  final bool continueRegistration;
  final User user;
  final String password;
  final int position;
  Register({this.continueRegistration, this.user, this.password, this.position});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>RegisterBloc(registerRepository: RegisterRequest(), verifyRegistrationRepository: VerifyRegistrationRequest()),
      child: RegisterPage(continueRegistration, user, password, position),
    );
  }
}

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget{
  final bool continueRegistration;
  final User user;
  final String password;
  final int position;
  RegisterPage(this.continueRegistration, this.user, this.password, this.position);
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _country="Nigeria";
  String _countryCode;
  int _selectedStepIndex=0;
  // ignore: close_sinks
  RegisterBloc registerBloc;
  final _firstFormKey = GlobalKey<FormState>();
  final _secondFormKey = GlobalKey<FormState>();
  final _thirdFormKey = GlobalKey<FormState>();
  final _fifthFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final sloganController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController=TextEditingController();
  final phoneController = TextEditingController(
    text: '+234'
  );
  final addressController = TextEditingController();
  final townController = TextEditingController();
  final cityController = TextEditingController();
  final lgaController = TextEditingController();
  VideoPlayerController _videoPlayerController;
  bool _videoPlayerInitialized=false;
  File videoFile, trimmedVideoFile;
  List<String> videoFileName=List();
  //final Trimmer _trimmer = Trimmer();
  _populateForm(){
    if(continueRegistration){
      nameController.text=user.userName;
      usernameController.text=user.userName;
      emailController.text=user.contactEmail;
      passwordController.text=password;
      confirmPasswordController.text=password;
      phoneController.text=user.contactPhone;
      addressController.text=user.address;
      townController.text=user.town;
      cityController.text=user.city;
      lgaController.text=user.lga;
      _country=user.nationality;
      _selectedStepIndex=position;
  }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _populateForm();
    registerBloc=BlocProvider.of<RegisterBloc>(context);
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            //Todo: to change back button color
            /*iconTheme: IconThemeData(
            color: MyColors.primaryColor
          ),*/
            leading: Icon(Icons.library_books, color: MyColors.primaryColor,),
            title: Text("Register School", style: TextStyle(color: MyColors.primaryColor)),
          ),
          body: CustomPaint(
              painter: BackgroundPainter(),
              child: BlocListener<RegisterBloc, RegisterStates>(
                  listener: (BuildContext context, RegisterStates state) {
                    if(state is PasswordVisibilityChanged){
                      _obscurePassword=state.password;
                      _obscureConfirmPassword=state.confirmPassword;
                    }else if(state is StepChanged){
                      _selectedStepIndex=state.index;
                    }else if(state is RegisteringUser){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Registering..."),
                        ),
                      );
                    }else if(state is Processing){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if(state is NetworkErr){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if(state is RegisterError){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    }else if(state is UserRegistered){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      saveLoginDetailsToSF(
                          false,
                          '', '',
                          nameController.text,
                          phoneController.text,
                          emailController.text,
                          "${addressController.text}, ${townController.text}, ${lgaController.text}, ${cityController.text}, $_country",
                          '', '', '', '',
                        false, '', false
                      );
                      _selectedStepIndex=3;
                    } else if(state is VerificationEmailResent){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      _selectedStepIndex=4;
                    }else if(state is VerificationVideoUploaded){
                      Scaffold.of(context).removeCurrentSnackBar();
                      showMessageModalDialog(context: context, message: state.message, buttonText: 'Continue', closeable: false).then((value) => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Dashboard(
                              loggedInAs: MyStrings.school,
                              user: user,
                            )),
                        ModalRoute.withName('/'),
                      )/*Navigator.pop(context)*/);
                    }else if(state is VideoFileSelected){
                      videoFile=state.videoFile;

                      trimmedVideoFile=state.videoFile;
                      _videoPlayerInitialized=true;
                      _videoPlayerController = VideoPlayerController.file(state.videoFile)..initialize().then((_) {
                      });
                     /* _trimmer.loadVideo(videoFile: state.videoFile).then((value){
                        _navigateVideoEditorScreen(context: context, trimmer: _trimmer).then((trimmedVideo){
                          if(trimmedVideo!=null){
                           registerBloc.add(EditVideoFileEvent(trimmedVideo));
                          }
                        });
                      });*/
                    }else if(state is VideoFileEdited){
                      trimmedVideoFile=state.videoFile;
                      _videoPlayerInitialized=true;
                      _videoPlayerController = VideoPlayerController.file(state.videoFile)..initialize().then((_) {
                      });

                    }

                  },
                  child: BlocBuilder<RegisterBloc, RegisterStates>(builder:
                      (BuildContext context, RegisterStates state) {
                    return Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: _registerStepper(context),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Wrap(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                              child: _stepperButtons(context),
                            )
                          ],)
                        ),
                      ],
                    );
                    /*if(state is StepChanged){
                    return _registerStepper(context);
                  }else if(state is InitialState){
                    return _registerStepper(context);
                  }*/
                  },
                  )
              )
          )
      ),
    );
  }

  Widget _registerStepper(BuildContext context){
    return Stepper(
      type: StepperType.vertical,
      steps: [
        Step(
          title: Text("Start"),
          subtitle: Text("Enter school name, email and phone to continue"),
          content: firstForm(context),
          isActive: _selectedStepIndex==0,
          state: (_selectedStepIndex==0)?StepState.editing:(_selectedStepIndex>0)?StepState.complete:StepState.indexed,
        ),
        Step(
          title: Text("Authentications"),
          subtitle: Text("Choose a username and a password to continue"),
          content: secondForm(context),
          isActive: _selectedStepIndex==1,
          state: (_selectedStepIndex==1)?StepState.editing:(_selectedStepIndex>1)?StepState.complete:StepState.indexed,
        ),
        Step(
          title: Text("Location"),
          subtitle: Text("Where is your school located?"),
          content: thirdForm(context),
          isActive: _selectedStepIndex==2,
          state: (_selectedStepIndex==2)?StepState.editing:(_selectedStepIndex>2)?StepState.complete:StepState.indexed,
        ),
        Step(
          title: Text("Email Verification"),
          subtitle: Text("Verify your registration email"),
          content: fourthForm(context),
          isActive: _selectedStepIndex==3,
          state: (_selectedStepIndex==3)?StepState.editing:(_selectedStepIndex>3)?StepState.complete:StepState.indexed,
        ),
        Step(
          title: Text("Video Verification"),
          subtitle: Text("15 Seconds video of your school premises"),
          content: fifthForm(context),
          isActive: _selectedStepIndex==4,
          state: (_selectedStepIndex==4)?StepState.editing:(_selectedStepIndex>4)?StepState.complete:StepState.indexed,
        )
      ],
      currentStep: _selectedStepIndex,
      onStepTapped: (index) {
        if(continueRegistration){
          if(continueRegistration&&position==3&&index==4){
            showMessageModalDialog(context: context, message: 'Please login to continue this process', buttonText: 'Continue', closeable: false).then((value) =>   Navigator.pop(context));
          }
        }else if((_selectedStepIndex==0&&_firstFormKey.currentState.validate())||
            (_selectedStepIndex==1&&_secondFormKey.currentState.validate())){
          registerBloc.add(ChangeStepEvent(index));
        }
      },
      /*onStepCancel: () {
        print("You are clicking the cancel button.");
      },
      onStepContinue: () {
        print("You are clicking the continue button.");
      },*/
      controlsBuilder: (BuildContext context,
          {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
          /*_stepperButtons(context)*/ Container(),
    );
  }

  Widget firstForm(BuildContext context){
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Form(
            key: _firstFormKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter your school name.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border:OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      //icon: Icon(Icons.email),
                      prefixIcon: Icon(Icons.business, color: Colors.pink),
                      labelText: 'School name',
                      labelStyle: new TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: sloganController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter your school slogan';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border:OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      //icon: Icon(Icons.email),
                      prefixIcon: Icon(Icons.stars, color: Colors.teal),
                      labelText: 'School slogan',
                      labelStyle: new TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: validateEmail,
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        labelText: 'Email',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 0.0),
                  child: Stack(
                    children: <Widget>[
                      CountryCodePicker(
                        onChanged: _onCountryChange,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'NG',
                        favorite: ['+234','NG'],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, right: 100.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                            child: Icon(Icons.expand_more, size: 20.0, color: Colors.black87,)),
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter your phone number.';
                      }
                      if(value.length<5){
                        return 'Please enter a vaild phone number.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.phone, color: MyColors.primaryColor),
                        labelText: 'Phone',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),

                /*Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: nextButtonFill(),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    //onTap: ()=> new LaunchRequest().launchURL(MyStrings.registerUrl),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text(
                        "Registered School? Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.blue)
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget secondForm(BuildContext context){
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Form(
            key: _secondFormKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: usernameController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter a username.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border:OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      //icon: Icon(Icons.email),
                      prefixIcon: Icon(Icons.person, color: Colors.teal),
                      labelText: 'Username',
                      labelStyle: new TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Create a password.';
                      }
                      if(value.length<6){
                        return 'Password too short.';
                      }
                      return null;
                    },
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.lock, color: Colors.red),
                        suffixIcon: IconButton(
                          onPressed: (){
                            registerBloc.add(VisiblePasswordEvent(!_obscurePassword, _obscureConfirmPassword));
                          },
                          icon: Icon(_obscurePassword?Icons.visibility:Icons.visibility_off_rounded),
                        ),
                        labelText: 'Password',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: confirmPasswordController,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please confirm your password.';
                      }
                      if(value!=passwordController.text){
                        return 'Password mismatch.';
                      }
                      return null;
                    },
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          onPressed: () {
                            registerBloc.add(VisiblePasswordEvent(_obscurePassword, !_obscureConfirmPassword));
                          },
                          icon: Icon(_obscureConfirmPassword?Icons.visibility:Icons.visibility_off_rounded),
                        ),
                        labelText: 'Re-Enter Password',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget thirdForm(BuildContext context){
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Form(
            key: _thirdFormKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: addressController,
                    enableSuggestions: true,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter school address.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                        labelText: 'Address',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: townController,
                    enableSuggestions: true,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter town or city.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border:OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                      ),
                      //icon: Icon(Icons.email),
                      prefixIcon: Icon(Icons.location_on, color: MyColors.primaryColor),
                      labelText: 'Town/City',
                      labelStyle: new TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: cityController,
                    enableSuggestions: true,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter state province or region.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.location_city, color: Colors.pink),
                        labelText: 'State/Province/Region',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),

                /*Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: lgaController,
                    enableSuggestions: true,
                    validator:  (value) {
                      if(value.isEmpty){
                        return 'Please enter lga.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border:OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(25.0),
                          ),
                        ),
                        //icon: Icon(Icons.email),
                        prefixIcon: Icon(Icons.location_city, color: Colors.black),
                        labelText: 'LGA',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget fourthForm(BuildContext context){
    return Container(
      color: Colors.white54,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
              child: Text('An email has been sent to ${emailController.text} please login to your email to verify',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.teal,
                      fontWeight: FontWeight.normal)),
            ),
            FlatButton(
              onPressed: () {
                if(emailController.text.isNotEmpty){
                  registerBloc.add(ResendVerificationEmailEvent(emailController.text));
                }
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
                child: const Text("Resend Email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue /*, decoration: TextDecoration.underline*/)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget fifthForm(BuildContext context){
    return Container(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Form(
            key: _fifthFormKey,
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(25.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(
                            color: MyColors.primaryColor,
                            style: BorderStyle.solid,
                            width: 0.80),
                      ),
                      height: 250.0,
                      child:_videoPlayerInitialized
                          ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Stack(
                          children: [
                            Hero(
                                tag: 'registration video',
                                child: VideoPlayer(_videoPlayerController)),
                            Center(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: IconButton(icon: Icon(Icons.video_library, size: 30, color: Colors.white),
                                        onPressed:() async{
                                          final pickedImage=await pickImage(context, false);
                                          final File videoFile=File(pickedImage.path);
                                          if(videoFile!=null){
                                            print(videoFile.toString().split('.')[videoFile.toString().split('.').length-1]);
                                            registerBloc.add(SelectVideoFileEvent(videoFile));
                                          }
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: IconButton(icon: Icon(Icons.play_circle_filled, size: 30, color: Colors.white),
                                        onPressed:() async{
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => VideoPlayers(heroTag: 'registration video', videoFile: videoFile, videoUrl: '',)),
                                          );
                                        }),
                                  ),
                                  /*Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: IconButton(icon: Icon(Icons.edit, size: 30, color: Colors.white),
                                        onPressed:() async{

                                          _trimmer.loadVideo(videoFile: videoFile).then((value){
                                            _navigateVideoEditorScreen(context: context, trimmer: _trimmer).then((trimmedVideo){
                                              if(trimmedVideo!=null){
                                                registerBloc.add(EditVideoFileEvent(trimmedVideo));
                                              }
                                            });
                                          });

                                        }),
                                  ),*/
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        child: Center(
                          child: IconButton(icon: Icon(Icons.video_library, size: 50, color: Colors.grey),
                              onPressed:() async{
                                final pickedImage=await pickImage(context, false);
                                final File videoFile=File(pickedImage.path);
                                if(videoFile!=null){
                                  print(videoFile.absolute);
                                  print(videoFile.toString().split('.')[videoFile.toString().split('.').length-1]);
                                  registerBloc.add(SelectVideoFileEvent(videoFile));
                                }
                              }),
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _stepperButtons(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: (_selectedStepIndex==0||_selectedStepIndex==3||position==4)?_cancelButtonFill(context):_previousButtonFill(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: (_selectedStepIndex==2)?_registerButtonOutline(context):(_selectedStepIndex==4)?_doneButtonOutline(context):_nextButtonOutline(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextButtonOutline(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        if(_selectedStepIndex==3){
          showMessageModalDialog(context: context, message: 'Please verify your email and login to continue this process', buttonText: 'Ok', closeable: true).then((value) =>   Navigator.pop(context));
        }else if((_selectedStepIndex==0&&_firstFormKey.currentState.validate())||
            (_selectedStepIndex==1&&_secondFormKey.currentState.validate())){
          registerBloc.add(ChangeStepEvent(++_selectedStepIndex));
        }
      },
      textColor: MyColors.primaryColor,
      color: Colors.white70,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
          side: BorderSide(color: MyColors.primaryColor)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
        child: const Text(
            "Next >",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }


  Widget _previousButtonFill(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        registerBloc.add(ChangeStepEvent(--_selectedStepIndex));
      },
      textColor: Colors.white,
      color: MyColors.primaryColor,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
        child: const Text(
            "< Previous",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }

  Widget _registerButtonOutline(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        /*print("${nameController.text}, ${emailController.text}, ${passwordController.text}, ${confirmPasswordController.text}, ${phoneController.text}, ${addressController.text}, ${townController.text}, ${lgaController.text}, ${cityController.text}, $_country");*/
        if(_thirdFormKey.currentState.validate()){
          registerBloc.add(RegisterUser(nameController.text, sloganController.text, emailController.text, usernameController.text, passwordController.text, confirmPasswordController.text, phoneController.text, addressController.text, townController.text, lgaController.text, cityController.text, _country));
        }
      },
      textColor: MyColors.primaryColor,
      color: Colors.white70,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
          side: BorderSide(color: MyColors.primaryColor)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
        child: const Text(
            "Register",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }

  Widget _doneButtonOutline(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        if(videoFile!=null){
          if(_videoPlayerController.value.duration.inSeconds<=15){
            registerBloc.add(UploadVerificationVideoEvent(user.apiToken, videoFile.path));
          }else{
            showToast(message: 'Video must 15 seconds max');
          }
        }else{
          showToast(message: 'Please upload video to continue');
        }
      },
      textColor: MyColors.primaryColor,
      color: Colors.white70,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
          side: BorderSide(color: MyColors.primaryColor)
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
        child: const Text(
            "Done",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }

  Widget _cancelButtonFill(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        if (continueRegistration) {
          Navigator.pop(context, 'Exit');
        } else {
          Navigator.pop(context);
        }
      },
      textColor: Colors.white,
      color: MyColors.primaryColor,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
        child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    //Todo : manipulate the selected country code here
    _country=countryCode.name;
    _countryCode=countryCode.toString();
    phoneController.text=_countryCode;

    print("New Country selected: " + countryCode.toString()+" "+countryCode.name);

  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (continueRegistration) {
      print("onwill goback");
      Navigator.pop(context, 'Exit');
      return Future.value(false);
    } else {
      Navigator.pop(context);
      return Future.value(true);
    }
  }

  /*Future<File> _navigateVideoEditorScreen({BuildContext context, Trimmer trimmer}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoTrimmer(trimmer)),
    );

    return File(result);
  }*/


}
