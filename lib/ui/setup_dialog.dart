import 'package:flutter/material.dart';
import 'package:school_pal/blocs/register/register.dart';
import 'package:school_pal/requests/get/verify_registration_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/view_class_categories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/ui/view_class_labels.dart';
import 'package:school_pal/ui/view_class_levels.dart';
import 'package:school_pal/ui/view_classes.dart';
import 'package:school_pal/ui/view_school_sessions.dart';
import 'package:school_pal/ui/view_school_terms.dart';
import 'package:school_pal/ui/view_subjects.dart';

class SetupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>RegisterBloc(verifyRegistrationRepository: VerifyRegistrationRequest()),
      child: SetupDialogPage(),
    );
  }
}

// ignore: must_be_immutable
class SetupDialogPage extends StatelessWidget {

  RegisterBloc registerBloc;
  PageController _controller = PageController(
    initialPage: 0,
  );

  List<String> setupMessages=[MyStrings.stepOneMessage, MyStrings.stepTwoMessage, MyStrings.stepThreeMessage, MyStrings.stepFourMessage, MyStrings.stepSixMessage, MyStrings.stepSevenMessage];
  String doneSetup='';
  List<String> setupStages=['session', 'term', 'class_label', 'class_category', 'class', 'subject'];
  List<Widget> setupPages=[ViewSchoolSessions(firstTimeLogin: true), ViewSchoolTerms(firstTimeLogin: true), ViewClassLabels(firstTimeLogin: true), ViewClassCategories(firstTimeLogin: true), ViewClasses(firstTimeLogin: true), ViewSubjects(firstTimeLogin: true)];


  void initPageController()async{
    String lastCompletedSetupPage=await getFirstTimeSetupPage();
    if(setupStages.contains(lastCompletedSetupPage))
      _controller.jumpToPage((setupStages.indexOf(lastCompletedSetupPage)+1));

  }

  @override
  Widget build(BuildContext context) {
    registerBloc=BlocProvider.of<RegisterBloc>(context);
    initPageController();
    return WillPopScope(
      onWillPop: () =>Future.value(false),
      child: Stack(
        children: [
          BlocListener<RegisterBloc, RegisterStates>(
              listener: (BuildContext context, RegisterStates state) {
               if(state is Processing){
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(minutes: 30),
                      content: General.progressIndicator("Processing..."),
                    ),
                  );
                }else if(state is FirstTimeSetupPageUpdated || state is RegisterError || state is NetworkErr){
                 saveFirstTimeSetupPageToSF(setupStages[_controller.page.round()]);
                 if((_controller.page.round() + 1)>=setupMessages.length){
                   showMessageModalDialog(context: context, message: MyStrings.stepCompletionMessage, buttonText: 'Continue', closeable: false).then((value){
                     if(value!=null){
                       registerBloc.add(UpdateFirstTimeLoginEvent());
                     }
                   });
                 }else{
                   _controller.animateToPage((_controller.page.round() + 1), duration: Duration(milliseconds: 500), curve: Curves.ease);
                 }

               }else if(state is FirstTimeLoginUpdated){
                 updateFirstTimeLogin(false);
                 Navigator.pop(context);
               }

              },
              child: BlocBuilder<RegisterBloc, RegisterStates>(builder:
                  (BuildContext context, RegisterStates state) {
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.all(20),
                    color: Colors.black.withOpacity(0.7),
                    child: PageView.builder(
                      controller: _controller,
                      physics: NeverScrollableScrollPhysics(),
                      pageSnapping: true,
                      allowImplicitScrolling: false,
                      itemBuilder: (context, position) {
                        return _setupPage(context: context, title: 'STEP ${position+1}', message: setupMessages[position], position: position);
                      },
                      itemCount: setupMessages.length, // Can be null
                    ),
                  ),
                );
              },
              )
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: Colors.white,
                color:MyColors.transparent, //MyColors.primaryColor,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                  child: const Text("Remind me later",
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _setupPage({BuildContext context, String title, String message, int position}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: MyColors.primaryColor, //Colors.transparent,
              borderRadius: BorderRadius.circular(0.0),
              border: Border.all(
                  color: Colors.white,
                  style: BorderStyle.solid,
                  width: 0.80),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none)),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none))
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    _navigateToSetupPageScreen(context: context, page: setupPages[position]).then((nextStep){
                      if (nextStep != null) {
                        if(nextStep)
                          registerBloc.add(UpdateFirstTimeSetupPageEvent(page: setupStages[position]));
                      }
                    });
                  },
                  textColor: Colors.white,
                  color:MyColors.transparent, //MyColors.primaryColor,
                  padding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.white)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                    child: const Text("Continue",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    //Navigator.pop(context, message);
                    registerBloc.add(UpdateFirstTimeSetupPageEvent(page: setupStages[position]));
                  },
                  textColor: Colors.white,
                  color:MyColors.transparent, //MyColors.primaryColor,
                  padding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                    child: const Text("Skip",
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _navigateToSetupPageScreen({BuildContext context, Widget page}) async {
    final bool nextStep = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
    print(nextStep);
    return nextStep;
  }

}
