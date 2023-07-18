import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/utils/system.dart';

class CreateSessionDialog extends StatefulWidget {
  final Sessions sessions;
  final String type;
  CreateSessionDialog(this.sessions, this.type,{Key key}) : super(key: key);

  @override
  _CreateSessionDialogState createState() => _CreateSessionDialogState(sessions, type);
}
class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final Sessions sessions;
  final String type;
  _CreateSessionDialogState(this.sessions, this.type);
  final formatDate = DateFormat("yyyy/MM/dd");
  final formatYear = DateFormat("yyyy");
  DateTime selectedDateFrom = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year-500),
        lastDate: DateTime(selectedDateFrom.year+500));
    if (picked != null && picked != selectedDateFrom)
      setState(() {
        selectedDateFrom = picked;
      });
  }
  Future<Null> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year-500),
        lastDate: DateTime(selectedDateTo.year+500));
    if (picked != null && picked != selectedDateTo)
      setState(() {
        selectedDateTo = picked;
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    if(type=='Edit'){
      selectedDateFrom=convertDateFromString(sessions.startAndEndDate.split(',')[0].replaceAll("/", "-"));
      selectedDateTo=convertDateFromString(sessions.startAndEndDate.split(',')[1].replaceAll("/", "-"));
      _textController.text=sessions.admissionNumberPrefix;
    }
    super.initState();
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
                            child: Text("Add New Session",
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _textController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter admission prefix.';
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
                                    Icon(Icons.label, color: MyColors.primaryColor),
                                    labelText: 'Admission prefix',
                                    hintText: 'Admission prefix',
                                    labelStyle: new TextStyle(color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
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
          if(_formKey.currentState.validate()){
            Navigator.pop(context, {'sessionDate':formatYear.format(selectedDateFrom.toLocal())+"/"+formatYear.format(selectedDateTo.toLocal()), 'startDate':formatDate.format(selectedDateFrom.toLocal()), 'endDate': formatDate.format(selectedDateTo.toLocal()), 'admissionPrefix' :_textController.text});
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
}
