import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/pick_up_id/pick_up_id.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/pick_up_id_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/ui/student_details.dart';

class VerifyPickUpId extends StatelessWidget {
  VerifyPickUpId({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PickUpIdBloc(PickUpIdRequests()),
      child: VerifyPickUpIdPage(),
    );
  }
}

// ignore: must_be_immutable
class VerifyPickUpIdPage extends StatelessWidget {
  bool _obscureText = true;
  final pickUpIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PickUpIdBloc pickUpIdBloc;

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
          title: Text("Verify Pick-Up Id",
              style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
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
                                if (state is IdVisibilityState) {
                                  _obscureText = state.visibility;
                                }
                              }, child:
                                      BlocBuilder<PickUpIdBloc, PickUpIdStates>(
                                builder: (BuildContext context,
                                    PickUpIdStates state) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: pickUpIdController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter pick-up id.';
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
                                              color: Colors.pink),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              pickUpIdBloc.add(
                                                  IdVisibilityEvent(
                                                      !_obscureText));
                                            },
                                            icon: Icon(Icons.visibility),
                                          ),
                                          labelText: 'Pick-up Id',
                                          labelStyle: new TextStyle(
                                              color: Colors.grey[800]),
                                          filled: true,
                                          fillColor: Colors.white70),
                                    ),
                                  );
                                },
                              )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _verifyButtonFill(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BlocListener<PickUpIdBloc, PickUpIdStates>(
                  listener: (BuildContext context, PickUpIdStates state) {
                    if (state is VerifyingPickUpId) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Verifying Id..."),
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
                    } else if (state is PickUpIdVerified) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      pickUpIdController.clear();
                      showStudentDetailsModalDialog(
                          context: context, students: [state.student]);
                      /*Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Pick-up Id Verified Successfully",
                          textAlign: TextAlign.center),
                    ),
                  );*/
                    }
                  },
                  child: BlocBuilder<PickUpIdBloc, PickUpIdStates>(
                    builder: (BuildContext context, PickUpIdStates state) {
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _verifyButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            pickUpIdBloc.add(VerifyPickUpIdEvent(pickUpIdController.text));
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
          child: const Text("Verify", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  void showStudentDetailsModalDialog(
      {BuildContext context, List<Students> students}) {
    showModalBottomSheet(
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (BuildContext context) {
          return Stack(
            children: <Widget>[
              Container(
                //this right here
                child: StudentDetails(
                  students: students,
                  index: 0,
                  fees: false,
                  pickUpId: true,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    "lib/assets/images/verified.svg",
                    alignment: Alignment.topRight,
                  ),
                ),
              )
            ],
          );
        });
  }
}
