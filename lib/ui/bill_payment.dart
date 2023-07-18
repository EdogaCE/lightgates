import 'package:flutter/material.dart';
import 'package:school_pal/blocs/bill/bill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/top_up.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/bill_payment_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';

class BillPayment extends StatelessWidget {
  final bool isAirtime;
  BillPayment({this.isAirtime});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillBloc(billPaymentRepository: BillPaymentRequests()),
      child: BillPaymentPage(isAirtime),
    );
  }
}

// ignore: must_be_immutable
class BillPaymentPage extends StatelessWidget {
  final bool isAirtime;
  BillPaymentPage(this.isAirtime);

  BillBloc _billBloc;
  final _formKey = GlobalKey<FormState>();
  final iucPhoneController = TextEditingController();
  final amountController = TextEditingController();

  TopUp categoryDropdownValue=TopUp(name: 'Categories');
  List<TopUp> categorySpinnerItems = [TopUp(name: 'Categories')];


  void _viewSpinnerValues() async {
    _billBloc.add(ViewBillCategoriesEvent(apiToken: await getApiToken()));
  }


  @override
  Widget build(BuildContext context) {
    _billBloc = BlocProvider.of<BillBloc>(context);
    _viewSpinnerValues();
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[

          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text('Bill Payment', style: TextStyle(color: MyColors.primaryColor)),
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
                              BlocListener<BillBloc, BillStates>(
                                listener: (BuildContext context, state) {
                                  if (state is Processing) {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(minutes: 30),
                                        content: General.progressIndicator("Processing..."),
                                      ),
                                    );
                                  }else if (state is NetworkErr) {
                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content:
                                          Text(state.message, textAlign: TextAlign.center),
                                        ),
                                      );
                                  } else if (state is ViewError) {
                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content:
                                          Text(state.message, textAlign: TextAlign.center),
                                        ),
                                      );
                                  }else if (state is BillCategoriesLoaded) {
                                    categorySpinnerItems=state.topUp.where((element) => element.isAirtime==isAirtime).toList();
                                    _billBloc.add(SelectBillCategoryEvent(topUp: categorySpinnerItems.first));
                                  }else if (state is BillCategorySelected) {
                                    categoryDropdownValue=state.topUp;
                                  }else if (state is BillPaid){
                                    Navigator.pop(context, state.message);
                                  }
                                },
                                child: BlocBuilder<BillBloc, BillStates>(
                                  builder: (BuildContext context, state) {
                                    return Column(
                                      children: [
                                        Stack(
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 30.0),
                                                  child: Text("Bill Categories",
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
                                                          color: Colors.deepPurpleAccent,
                                                          style: BorderStyle.solid,
                                                          width: 0.80),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 20.0),
                                                      child: DropdownButton<TopUp>(
                                                        isExpanded: true,
                                                        value: categoryDropdownValue,
                                                        icon: Icon(Icons.arrow_drop_down),
                                                        iconSize: 24,
                                                        elevation: 16,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                        underline: Container(
                                                          height: 0,
                                                          color: Colors.deepPurpleAccent,
                                                        ),
                                                        onChanged: (TopUp data) {
                                                          _billBloc.add(SelectBillCategoryEvent(topUp: data));
                                                        },
                                                        items: categorySpinnerItems.map<DropdownMenuItem<
                                                            TopUp>>((TopUp value) {return DropdownMenuItem<TopUp>(
                                                          value: value,
                                                          child: Text(value.name),
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
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0, right: 8.0, top: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Account Identification/Phone Number: ',  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(text: 'Phone Number must start with + before country code: +23490xxxxxxxx', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: iucPhoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Field is required';
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
                                      Icon(Icons.label, color: Colors.blue),
                                      labelText: 'IUC/Phone Number',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Field is required.';
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
                                      prefixIcon: Icon(Icons.monetization_on,
                                          color: Colors.blue),
                                      labelText: 'Amount(NG)',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
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
                    child: _sendButtonFill(context),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  bool validateSpiner(){
    bool valid=true;
    if(categoryDropdownValue.name=='Categories'){
      valid=false;
      showToast(message: 'Please select bill category');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(validateSpiner())
              _billBloc.add(PayBillEvent(customer: iucPhoneController.text, amount: amountController.text, billCategoryKey: categoryDropdownValue.uniqueId));
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
          child:  Text('Done', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}