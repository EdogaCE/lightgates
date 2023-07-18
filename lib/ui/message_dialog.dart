import 'package:flutter/material.dart';
import 'package:school_pal/res/colors.dart';

class MessageDialog extends StatelessWidget {
  final String message;
  final String buttonText;
  final bool closeable;
  MessageDialog({this.message, this.buttonText, this.closeable});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () =>_popNavigator(context, closeable),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          color: Colors.black.withOpacity(0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none))
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pop(context, message);
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
                    child: Text(buttonText,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _popNavigator(BuildContext context, bool closeable) async {
    if (closeable) {
      print("onwill goback");
      //Navigator.pop(context);
      return Future.value(true);
    } else {
      print("onwillNot goback");
      return Future.value(false);
    }
  }

}
