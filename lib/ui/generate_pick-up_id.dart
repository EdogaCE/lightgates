import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/pick_up_id/pick_up_id.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/pick_up_id_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:animator/animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'general.dart';

class GeneratePickupId extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => PickUpIdBloc(PickUpIdRequests()),
    child: GeneratePickupIdPage(),
  );
}}

// ignore: must_be_immutable
class GeneratePickupIdPage extends StatelessWidget {
  // ignore: close_sinks
  PickUpIdBloc pickUpIdBloc;
  String pickUpId='';

  @override
  Widget build(BuildContext context) {
    pickUpIdBloc = BlocProvider.of<PickUpIdBloc>(context);
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Generate Pick-Up Id",
              style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Stack(
            children: <Widget>[
              Animator(
                repeats: 1,
                duration: Duration(seconds: 2),
                builder: (context, anim, child) => Opacity(
                  opacity: anim.value,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SvgPicture.asset(
                        "lib/assets/images/students.svg",
                        alignment: Alignment.topCenter,
                      )),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
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
                            BlocListener<PickUpIdBloc, PickUpIdStates>(
                                listener: (BuildContext context,
                                    PickUpIdStates state) {
                                 if (state is GeneratingPickUpId) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(minutes: 30),
                                        content: General.progressIndicator("Generating Id..."),
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
                                  } else if (state is VerificationError) {
                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content:
                                          Text(state.message, textAlign: TextAlign.center),
                                        ),
                                      );
                                  } else if (state is PickUpIdGenerated) {
                                   pickUpId=state.pickUpId;
                                   Scaffold.of(context)
                                     ..removeCurrentSnackBar()
                                     ..showSnackBar(
                                       SnackBar(
                                         content:
                                         Text('Generated Successfully', textAlign: TextAlign.center),
                                       ),
                                     );
                                 }
                                }, child: BlocBuilder<PickUpIdBloc, PickUpIdStates>(
                              builder: (BuildContext context, PickUpIdStates state) {
                                return Visibility(
                                  visible: pickUpId.isNotEmpty,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30.0),
                                        child: Text("Pick-Up Id",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: MyColors.primaryColor,
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
                                          width: double.maxFinite,
                                          padding: EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(25.0),
                                            border: Border.all(
                                                color: Colors.deepPurpleAccent,
                                                style: BorderStyle.solid,
                                                width: 0.80),
                                          ),
                                          child: SelectableText(
                                            pickUpId,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            onTap: (){
                                              if(pickUpId.isNotEmpty)
                                              showCopyShareModalBottomSheet(context: context, content: pickUpId, subject: 'My child pick-up id');
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _generateButtonFill(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<String> showPasswordModalDialog({BuildContext context})async{
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    final data=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child:Container(
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Authentication',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your password.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ),
                                ),
                                //icon: Icon(Icons.email),
                                prefixIcon:
                                Icon(Icons.lock, color: MyColors.primaryColor),
                                labelText: "Password",
                                labelStyle: new TextStyle(color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () async {
                              if(_formKey.currentState.validate()){
                                Navigator.pop(context, _passwordController.text);
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
                              child: const Text("Continue",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
          );
        });
    return data;
  }

  Widget _generateButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () async{
          String userId=await getUserId();
          showPasswordModalDialog(context: context).then((password){
            if(password!=null)
            pickUpIdBloc.add(GeneratePickUpIdEvent(userId, password));
          });

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
          child: const Text("Generate", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }


}
