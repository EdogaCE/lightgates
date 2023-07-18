import 'package:flutter/material.dart';
import 'package:school_pal/res/colors.dart';

class AddEditFaqDialog extends StatelessWidget {
  final String title;
  final String question;
  final String answer;
  AddEditFaqDialog({this.title, this.question, this.answer});
  final _formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    questionController.text=question;
    answerController.text=answer;
    return Container(
      height: 400,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 30.0,
                                  left: 10.0,
                                  right: 10.0),
                              child: Text('$title FAQ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: MyColors.primaryColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: questionController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter question.';
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
                                    Icon(Icons.help, color: Colors.blue),
                                    labelText: 'Question',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: answerController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter answer.';
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
                                    Icon(Icons.priority_high, color: Colors.green),
                                    labelText: 'Answer',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                          ]),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
                            child: _createClassButtonFill(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createClassButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if(_formKey.currentState.validate())
            Navigator.pop(context, [questionController.text, answerController.text]);
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
