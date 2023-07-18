import 'package:flutter/material.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';

class CreateClassDialog extends StatefulWidget {
  final Classes classes;
  final String type;
  CreateClassDialog(this.classes, this.type, {Key key})
      : super(key: key);

  @override
  _CreateClassDialogState createState() =>
      _CreateClassDialogState(classes, type);
}

class _CreateClassDialogState extends State<CreateClassDialog> {
  final Classes classes;
  final String type;
  _CreateClassDialogState(this.classes, this.type);

  bool loading=true;
  String categoryDropdownValue = '---category---';
  String levelDropdownValue = '---level---';
  String labelDropdownValue = '---label---';

  List<String> categorySpinnerItems = ["---category---"];
  List<String> levelSpinnerItems = ["---level---"];
  List<String> labelSpinnerItems = ["---label---"];

  List<List<String>> category;
  List<List<String>> label;
  List<List<String>> level;

  @override
  void initState() {
    // TODO: implement initState
    populateSpinners();
    super.initState();
  }

  void populateSpinners() async {
    category = await getCategoriesSpinnerValue(await getApiToken());
    categorySpinnerItems.addAll(category[0]);
    level = await getLevelsSpinnerValue(await getApiToken());
    levelSpinnerItems.addAll(level[0]);
    label = await getLabelsSpinnerValue(await getApiToken());
    labelSpinnerItems.addAll(label[0]);
    setState(() {
      loading=false;
      if(type=='Edit'){
        categoryDropdownValue=classes.category;
        labelDropdownValue=classes.label;
        levelDropdownValue=classes.level;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                    Column(
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
                            child: Text("Add New Class",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text("Select class label",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.normal)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 8.0,
                                    top: 1.0),
                                child: Container(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    border: Border.all(
                                        color: MyColors.primaryColor,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 20.0),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: labelDropdownValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      underline: Container(
                                        height: 0,
                                        color: MyColors.primaryColor,
                                      ),
                                      onChanged: (String data) {
                                        setState(() {
                                          labelDropdownValue = data;
                                        });
                                      },
                                      items: labelSpinnerItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text("Select class category",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.normal)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 8.0,
                                    top: 1.0),
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    border: Border.all(
                                        color: MyColors.primaryColor,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 20.0),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: categoryDropdownValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      underline: Container(
                                        height: 0,
                                        color: MyColors.primaryColor,
                                      ),
                                      onChanged: (String data) {
                                        setState(() {
                                          categoryDropdownValue = data;
                                        });
                                      },
                                      items: categorySpinnerItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text("Select class level",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.normal)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 8.0,
                                    top: 1.0),
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    border: Border.all(
                                        color: MyColors.primaryColor,
                                        style: BorderStyle.solid,
                                        width: 0.80),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 20.0),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: levelDropdownValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      underline: Container(
                                        height: 0,
                                        color: MyColors.primaryColor,
                                      ),
                                      onChanged: (String data) {
                                        setState(() {
                                          levelDropdownValue = data;
                                        });
                                      },
                                      items: levelSpinnerItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
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
                        ]),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, bottom: 8.0, left: 8.0, right: 8.0),
                          child: _createClassButtonFill(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          loading?Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                      backgroundColor: Colors.pink,
                    ),
                  )),
            ),
          ):Container()
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
          if(validInput()){
            Navigator.pop(context,{'category':category[1][categorySpinnerItems.indexOf(categoryDropdownValue)-1],
            'label':label[1][labelSpinnerItems.indexOf(labelDropdownValue)-1], 'level':level[1][levelSpinnerItems.indexOf(levelDropdownValue)-1]});
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

  bool validInput(){
    bool valid=true;
    if(categoryDropdownValue == '---category---'){
      valid=false;
      showToast(message: 'Please select category');
    }

    if(levelDropdownValue == '---level---'){
      valid=false;
      showToast(message: 'Please select level');
    }

    if(labelDropdownValue == '---label---'){
      valid=false;
      showToast(message: 'Please select label');
    }

    return valid;
  }
}