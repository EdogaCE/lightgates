import 'package:flutter/material.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/utils/launch_request.dart';

class AppRatingDialog extends StatefulWidget {
  final String message;
  final String appLink;
  AppRatingDialog({Key key, this.message, this.appLink}) : super(key: key);

  @override
  _AppRatingDialogState createState() => _AppRatingDialogState(message, appLink);
}

class _AppRatingDialogState extends State<AppRatingDialog> {
  final String message;
  final String appLink;
  _AppRatingDialogState(this.message, this.appLink);

  int selectedStar=0;
  List<int> stars=[1,2,3,4,5];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('Your Opinion Matters To Us',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 20,
                      color: MyColors.primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none))
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 320.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildRatingStars(context, stars),
                ),
              ),
            ),
            (selectedStar>0)?SizedBox(
              width: 320.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    LaunchRequest().launchURL(appLink);
                    saveDoNotOpenAgainToSF(true);
                    Navigator.pop(context);
                  },
                  textColor: Colors.white,
                  color: MyColors.primaryColor, //MyColors.primaryColor,
                  padding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.white)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 2.0, right: 25.0, bottom: 2.0),
                    child: const Text("Submit",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ):Container(),
            SizedBox(
              width: 320.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    saveDoNotOpenAgainToSF(true);
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
                    child:  Text("No Thanks",
                        style: TextStyle(fontSize: 18, color: MyColors.primaryColor)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 320.0,
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
                    child:  Text("Remind me later",
                        style: TextStyle(fontSize: 18, color: MyColors.primaryColor)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildRatingStars(BuildContext context, List<int> stars) {
    List<Widget> choices = List();
    stars.forEach((item) {
      choices.add(IconButton(
          icon: (selectedStar<item)
              ?Icon(Icons.star_border, color: Colors.grey,)
              :Icon(Icons.star, color: Colors.orange,),
          onPressed: () {
            setState(() {
              selectedStar=item;
            });
          }));
    });    return choices;
  }


}