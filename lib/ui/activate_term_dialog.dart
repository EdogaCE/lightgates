import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';

class ActivateTermDialog extends StatefulWidget {
  ActivateTermDialog({Key key}) : super(key: key);

  @override
  _ActivateTermDialogState createState() => _ActivateTermDialogState();
}

class _ActivateTermDialogState extends State<ActivateTermDialog> {
  final formatDate = DateFormat("yyyy-MM-dd");
  DateTime selectedDateFrom = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  bool loading=true;
  String sessionDropdownValue = '---session---';
  List<String> sessionSpinnerItems = ["---session---"];
  List<String> sessionSpinnerIds = [""];
  List<List<String>> session;
  _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year-5),
        lastDate: DateTime(selectedDateFrom.year+5));
    if (picked != null && picked != selectedDateFrom)
      setState(() {
        selectedDateFrom = picked;
      });
  }
  _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year-5),
        lastDate: DateTime(selectedDateTo.year+5));
    if (picked != null && picked != selectedDateTo)
      setState(() {
        selectedDateTo = picked;
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    populateSpinners();
    super.initState();
  }

  void populateSpinners() async {
    session = await getSessionSpinnerValue(await getApiToken());
    sessionSpinnerItems.addAll(session[0]);
    sessionSpinnerIds.addAll(session[1]);
    setState(() {
      sessionDropdownValue=session[2][1];
      loading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
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
                            child: Text("Activate Term",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 30.0),
                                        child: Text("From",
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
                                          width: double.maxFinite,
                                          padding: EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25.0),
                                            border: Border.all(
                                                color: MyColors.primaryColor,
                                                style: BorderStyle.solid,
                                                width: 0.80),
                                          ),
                                          child: Text(
                                              "${selectedDateFrom.toLocal()}".split(' ')[0],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: ()=> _selectDateFrom(context),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 30.0),
                                        child: Text("To",
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
                                          width: double.maxFinite,
                                          padding: EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25.0),
                                            border: Border.all(
                                                color: MyColors.primaryColor,
                                                style: BorderStyle.solid,
                                                width: 0.80),
                                          ),
                                          child: Text(
                                              "${selectedDateTo.toLocal()}".split(' ')[0],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: ()=> _selectDateTo(context),
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text("Select session",
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
                                        color: Colors.white.withOpacity(0.5),
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
                                          value: sessionDropdownValue,
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
                                              sessionDropdownValue = data;
                                            });
                                          },
                                          items: sessionSpinnerItems
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
                              ):Container(),
                            ],
                          ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
                          child: _createClassButtonFill(context),
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
    );
  }

  bool validateSpinner(){
    bool valid=true;
    if(sessionDropdownValue=='---session---'){
      valid=false;
      showToast(message: 'Please select session');
    }
    return valid;
  }

  Widget _createClassButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if(validateSpinner())
          Navigator.pop(context, [sessionSpinnerIds[sessionSpinnerItems.indexOf(sessionDropdownValue)], formatDate.format(selectedDateFrom.toLocal()), formatDate.format(selectedDateTo.toLocal())]);
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
