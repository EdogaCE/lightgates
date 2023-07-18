import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_payment_detail.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';

class ViewStudentsFeePayments extends StatelessWidget {
  final Students feesRecord;
  ViewStudentsFeePayments(this.feesRecord);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  DropdownButton<String>(
                    icon: Icon( Icons.more_vert, color: Colors.white,),
                    items: <String>['Pay With Flutter Wave', 'Pay With PayStack'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if(value=='Pay With Flutter Wave'){

                      }else if(value=='Pay With PayStack'){

                      }
                    },
                  )
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('${toSentenceCase(feesRecord.feesPayment.fees[0].feesRecord.title)}'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/payment.svg")
                      ),
                    )),
              ),
              _buildSalaryRecord(context)
            ],
          ),
    );
  }

  Widget _buildSalaryRecord(context) {
    return SliverList(
        delegate: SliverChildListDelegate(
          [
            Card(
              // margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              elevation: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                        '${toSentenceCase(feesRecord.fName)} ${toSentenceCase(feesRecord.lName)} ${toSentenceCase(feesRecord.mName)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0),
                    child: Text(
                        (feesRecord.admissionNumber.isEmpty
                            ? '${feesRecord.sessions.admissionNumberPrefix}${feesRecord.genAdmissionNumber}'
                            : '${feesRecord.sessions.admissionNumberPrefix}${feesRecord.admissionNumber}'),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal)),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 5.0, bottom: 2.0),
                      child: Text(
                          (feesRecord.email.toString().isNotEmpty)
                              ? feesRecord.email.toString()
                              : "Email Unknown",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                              fontWeight: FontWeight.normal)),
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 5.0, bottom: 8.0),
                      child: Text(
                          (feesRecord.phone.isNotEmpty)
                              ? feesRecord.phone
                              : "Phone number unknown",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.normal)),
                    ),
                    onTap: (){
                      if(feesRecord.phone.isNotEmpty)
                        showCallWhatsappMessageModalBottomSheet(context: context,countryCode: '+234', number: feesRecord.parentPhone);
                    },
                    onLongPress: (){
                      if(feesRecord.phone.isNotEmpty)
                        showCallWhatsappMessageModalBottomSheet(context: context,countryCode: '+234', number: feesRecord.parentPhone);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                // margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(("Fees:  "),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildFeesList(context, feesRecord.feesPayment.fees),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                // margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(("Fee Payments Details:  "),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildFeesPaymentDetailsList(context, feesRecord.feesPayment.paymentDetails),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                // margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(("Fee Payments Summary:  "),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: double.maxFinite,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(feesRecord.feesPayment.status.replaceAll('_', ' ')),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text('Total: ${convertPrice(currency: feesRecord.currency, amount: feesRecord.feesPayment.totalAmount)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text('Paid: ${convertPrice(currency: feesRecord.currency, amount: feesRecord.feesPayment.amountPaid)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text('Balance: ${convertPrice(currency: feesRecord.currency, amount: feesRecord.feesPayment.balance)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                // margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _sendButtonFill(context, 'Pay With Flutter Wave'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _sendButtonFill(context, 'Pay With PayStack'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  _buildFeesList(BuildContext context, List<Fees> fees) {
    List<Widget> choices = List();
    int counter=0;
    fees.forEach((item) {
      choices.add(Container(
          padding: const EdgeInsets.all(2.0),
          child:Column(
            children: <Widget>[
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.0),
                      child: Container(
                        color: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('${++counter}',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(
                            color: Colors.black54,
                          ),
                          Container(
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                              child: Text(toSentenceCase(item.division.replaceAll("_", " ")),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(item.title),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text('Amount: ${convertPrice(currency: feesRecord.currency, amount: item.amount)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
      ));
    });    return choices;
  }

  _buildFeesPaymentDetailsList(BuildContext context, List<FeesPaymentDetail> feesPaymentDetails) {
    List<Widget> choices = List();
    int counter=0;
    feesPaymentDetails.forEach((item) {
      choices.add(Container(
          padding: const EdgeInsets.all(2.0),
          child:Column(
            children: <Widget>[
              Divider(
                color: Colors.black54,
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Hero(
                        tag: "payment proof tag ${counter++}",
                        transitionOnUserGestures: true,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: FadeInImage.assetNetwork(
                              placeholderScale: 5,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(seconds: 1),
                              fadeInCurve: Curves.easeInCirc,
                              placeholder: MyStrings.logoPath,
                              image: item.paymentProofLink +
                                  item.paymentProof,
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImage(
                                imageUrl: [item.paymentProofLink + item.paymentProof],
                                heroTag: "payment proof tag ${counter++}",
                                placeholder: MyStrings.logoPath,
                                position: 0,
                              ),
                            ));
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                              child: Text(toSentenceCase(item.status.replaceAll('_', ' ')),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(item.paymentOption),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text('Amount Paid: ${convertPrice(currency: feesRecord.currency, amount: item.amountPaid)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
      ));
    });    return choices;
  }

  Widget _sendButtonFill(BuildContext context, String title) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () async{
          String apiToken=await getApiToken();
          switch (title){
            case 'Pay With Flutter Wave':{
              showAmountModalDialog(context: context).then((amount){
                if(amount!=null){
                  print('${MyStrings.domain}${MyStrings.studentFeesPaymentGatewayUrl}$apiToken/${base64Encode(utf8.encode(amount))}/${feesRecord.feesPayment.id}/${feesRecord.id}/front_end');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebViewLoader(
                          url: "${MyStrings.domain}${MyStrings.studentFeesPaymentGatewayUrl}$apiToken/${base64Encode(utf8.encode(amount))}/${feesRecord.feesPayment.id}/${feesRecord.id}/front_end",
                          downloadLink: '',
                          title: 'Card Details',
                        )),
                  );
                }

              });
              break;
            }
            case 'Pay With PayStack':{
              showAmountModalDialog(context: context).then((amount){
                if(amount!=null){
                  print('${MyStrings.domain}${MyStrings.studentFeesPaymentGatewayUrl}$apiToken/${base64Encode(utf8.encode(amount))}/${feesRecord.feesPayment.id}/${feesRecord.id}/front_end/paystack');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebViewLoader(
                          url: "${MyStrings.domain}${MyStrings.studentFeesPaymentGatewayUrl}$apiToken/${base64Encode(utf8.encode(amount))}/${feesRecord.feesPayment.id}/${feesRecord.id}/front_end/paystack",
                          downloadLink: '',
                          title: 'Card Details',
                        )),
                  );
                }

              });
              break;
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
          child:  Text(title, style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  Future<String> showAmountModalDialog({BuildContext context})async{
    final _textController = TextEditingController();
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
                        child: Text('Enter Amount',
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
                            controller: _textController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter amount(${feesRecord.currency.secondCurrency})';
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
                                Icon(Icons.monetization_on, color: MyColors.primaryColor),
                                labelText: "Amount(${feesRecord.currency.secondCurrency})",
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
                          //height: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () async {
                              if(_formKey.currentState.validate()){
                                Navigator.pop(context, _textController.text);
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

}

