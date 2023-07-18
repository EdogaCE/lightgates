import 'package:flutter/material.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/models/fees.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class CreateFee extends StatelessWidget {
  final Fees fees;
  final FeesRecord feesRecord;
  final String event;
  CreateFee({this.fees, this.feesRecord, this.event});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FeesBloc(createFeesRepository: CreateFeesRequests()),
      child: CreateFeePage(fees, feesRecord, event),
    );
  }
}

// ignore: must_be_immutable
class CreateFeePage extends StatelessWidget {
  final Fees fees;
  final FeesRecord feesRecord;
  final String event;
  CreateFeePage(this.fees, this.feesRecord, this.event);
  FeesBloc _feesBloc;
  bool classSelectable=false;
  String currency;

  String classDropdownValue = '---class---';
  List<String> classSpinnerItems = ["---class---"];
  List<String> classSpinnerIds = ['0'];

  String divisionDropdownValue = '---division---';
  List<String> divisionSpinnerItems = ["---division---", 'All', 'Borders', 'Non_borders', 'By_class'];

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  void _viewSpinnerValues() async {
    currency='(${await getUserCurrency()})';
    _feesBloc.add(GetClassEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _viewSpinnerValues();

    if(event=='Update'){
      titleController.text=fees.title;
      amountController.text=convertPrice(currency: fees.currency, amount: fees.amount).split(' ').last;

      if(divisionSpinnerItems.contains(fees.division.replaceAll('_', ' ')))
      divisionDropdownValue=toSentenceCase(fees.division.replaceAll('_', ' '));

      if(toSentenceCase(fees.division.replaceAll('_', ' '))=='By class')
        classSelectable=true;
    }


    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("${toSentenceCase(event)} Fee", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 55.0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              BlocListener<FeesBloc, FeesStates>(
                                listener: (BuildContext context, FeesStates state) {
                                  if (state is DivisionSelected) {
                                    divisionDropdownValue = state.division;
                                    classSelectable=state.division=='By_class';
                                  }
                                },
                                child: BlocBuilder<FeesBloc, FeesStates>(
                                  builder: (BuildContext context, FeesStates state) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0),
                                          child: Text("Select fee division",
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(25.0),
                                              border: Border.all(
                                                  color: MyColors.primaryColor,
                                                  style: BorderStyle.solid,
                                                  width: 0.80),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 10.0,
                                                  right: 20.0),
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: divisionDropdownValue,
                                                icon: Icon(
                                                    Icons.arrow_drop_down),
                                                iconSize: 24,
                                                elevation: 16,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                                underline: Container(
                                                  height: 0,
                                                  color: MyColors.primaryColor,
                                                ),
                                                onChanged: (String data) {
                                                  _feesBloc.add(SelectDivisionEvent(data));
                                                },
                                                items: divisionSpinnerItems.map<DropdownMenuItem<String>>((String value) {
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
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: titleController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter title.';
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
                                      Icon(Icons.title, color: Colors.blue),
                                      labelText: 'Title',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              BlocBuilder<FeesBloc, FeesStates>(
                                builder: (BuildContext context, FeesStates state) {
                                  return        Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: amountController,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter amount.';
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
                                          Icon(Icons.monetization_on, color: Colors.pink),
                                          labelText: (event=='Update')
                                              ?'Amount: ${convertPrice(currency: fees.currency, amount: fees.amount).split(' ').first}'
                                              : 'Amount: $currency',
                                          labelStyle: new TextStyle(
                                              color: Colors.grey[800]),
                                          filled: true,
                                          fillColor: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                              BlocListener<FeesBloc, FeesStates>(
                                listener: (BuildContext context, FeesStates state) {
                                  if (state is ClassSelected) {
                                    classDropdownValue = state.clas;
                                  } else if (state is ClassesLoaded) {
                                    classSpinnerItems.addAll(state.classes[0]);
                                    classSpinnerIds.addAll(state.classes[1]);
                                    if(event=='Update'){
                                      try{
                                        _feesBloc.add(SelectClassEvent(classSpinnerItems[classSpinnerIds.indexOf(fees.classId)]));
                                      } on NoSuchMethodError{}
                                    }
                                  }
                                },
                                child: BlocBuilder<FeesBloc, FeesStates>(
                                  builder: (BuildContext context, FeesStates state) {
                                    return classSelectable?Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Text("Select class",
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(
                                                      color: MyColors.primaryColor,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 10.0,
                                                      right: 20.0),
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: classDropdownValue,
                                                    icon: Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18),
                                                    underline: Container(
                                                      height: 0,
                                                      color: MyColors.primaryColor,
                                                    ),
                                                    onChanged: (String data) {
                                                      _feesBloc.add(SelectClassEvent(data));
                                                    },
                                                    items: classSpinnerItems.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
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
                                        (state is Loading)
                                            ? Align(
                                          alignment: Alignment.center,
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(
                                                100.0),
                                            child: Container(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(20.0),
                                                  child:
                                                  CircularProgressIndicator(
                                                    valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(
                                                        Colors
                                                            .deepPurple),
                                                    backgroundColor:
                                                    Colors.pink,
                                                  ),
                                                )),
                                          ),
                                        )
                                            : Container(),
                                      ],
                                    ):Container();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _sendButtonFill(context, event),
                  ),
                ),
                BlocListener<FeesBloc, FeesStates>(
                  listener: (BuildContext context, FeesStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    } else if (state is FeesNetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is FeesViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                            Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is FeeCreated) {
                      Navigator.pop(context, state.message);
                    } else if (state is FeeUpdated) {
                      Navigator.pop(context, state.message);
                    }
                  },
                  child: BlocBuilder<FeesBloc, FeesStates>(
                    builder: (BuildContext context, FeesStates state) {
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  bool validateSpinner() {
    bool valid = true;
    if (classDropdownValue == '---class---'&&divisionDropdownValue == 'By class') {
      valid = false;
      showToast(message: 'Please select class');
    }
    if (divisionDropdownValue == '---division---') {
      valid = false;
      showToast(message: 'Please select division');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context, String eventTitle) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              if(event=='Update'){
                _feesBloc.add(UpdateFeeEvent(
                    fees.recordId,
                    fees.id,
                    titleController.text,
                    divisionDropdownValue.toLowerCase(),
                    amountController.text,
                    classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)]
                ));
              }else{
                print('Record id: ${feesRecord.id}');
                _feesBloc.add(CreateFeeEvent(
                    feesRecord.id,
                    titleController.text,
                    divisionDropdownValue.toLowerCase(),
                    amountController.text,
                    classSpinnerIds[classSpinnerItems.indexOf(classDropdownValue)]
                ));
              }
            }
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
          child:  Text(eventTitle, style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

