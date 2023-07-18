import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/wallet/wallet.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_wallet_request.dart';
import 'package:school_pal/requests/posts/wallet_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';

class CreatePayStackSubAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(walletRepository: WalletRequests(),
          viewWalletRepository: ViewWalletRequest()),
      child: CreatePayStackSubAccountPage(),
    );
  }
}

// ignore: must_be_immutable
class CreatePayStackSubAccountPage extends StatelessWidget {

  WalletBloc _walletBloc;
  final _formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  final businessNameController = TextEditingController();

  String banksDropdownValue = '---Banks---';
  List<String> banksSpinnerItems = ["---Banks---"];
  List<String> banksSpinnerIds = ['0'];
  String _currentBank='';

  @override
  Widget build(BuildContext context) {
    _walletBloc = BlocProvider.of<WalletBloc>(context);
    _walletBloc.add(ViewPayStackSubAccountEvent());
    _walletBloc.add(GetPayStackBankCodes());
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text('Create PayStack Account', style: TextStyle(color: MyColors.primaryColor)),
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
                              BlocListener<WalletBloc, WalletStates>(
                                listener: (BuildContext context, WalletStates state) {
                                  if (state is BankSelected) {
                                    banksDropdownValue = state.bank;
                                  } else if (state is BanksLoaded) {
                                    banksSpinnerItems.addAll(state.banks[0]);
                                    banksSpinnerIds.addAll(state.banks[1]);

                                    if(banksSpinnerItems.contains(_currentBank))
                                      _walletBloc.add(SelectBankEvent(_currentBank));
                                  }else if (state is WalletProcessing){
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(minutes: 30),
                                        content: General.progressIndicator("Processing..."),
                                      ),
                                    );
                                  }else if (state is SubAccountRegistered){
                                    Scaffold.of(context).removeCurrentSnackBar();
                                    showMessageModalDialog(context: context, message: state.message, buttonText: 'Continue', closeable: false).then((value) =>  Navigator.pop(context));
                                  }else if (state is ViewError){
                                    Scaffold.of(context).removeCurrentSnackBar();
                                    showMessageModalDialog(context: context, message: state.message, buttonText: 'Continue', closeable: false).then((value) =>  Navigator.pop(context));
                                  }else if (state is NetworkErr){
                                    Scaffold.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content:
                                          Text(state.message, textAlign: TextAlign.center),
                                        ),
                                      );
                                  }else if (state is SubAccountLoaded){

                                    if(state.subAccount!=null){
                                      accountNumberController.text=state.subAccount.accountNumber;
                                      businessNameController.text=state.subAccount.businessName;
                                      _currentBank= '${state.subAccount.bankName}(${state.subAccount.country})';
                                    }

                                  }
                                },
                                child: BlocBuilder<WalletBloc, WalletStates>(
                                  builder: (BuildContext context, WalletStates state) {
                                    return Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 30.0),
                                              child: Text("Select bank",
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
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: banksDropdownValue,
                                                    icon: Icon(Icons.arrow_drop_down),
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
                                                      _walletBloc.add(SelectBankEvent(data));
                                                    },
                                                    items: banksSpinnerItems.map<DropdownMenuItem<
                                                        String>>((String value) {return DropdownMenuItem<
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
                                        (state is WalletLoading)
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
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: accountNumberController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please account number.';
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
                                      Icon(Icons.account_balance, color: Colors.blue),
                                      labelText: 'Account number',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: businessNameController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter business name.';
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
                                      prefixIcon: Icon(Icons.account_balance,
                                          color: Colors.blue),
                                      labelText: 'Business name',
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

  bool validateSpinner() {
    bool valid = true;
    if(banksDropdownValue == '---Banks---'){
      valid = false;
      showToast(message: 'Please select bank');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (validateSpinner()) {
              _walletBloc.add(RegisterPayStackSubAccountEvent(banksSpinnerIds[banksSpinnerItems.indexOf(banksDropdownValue)], accountNumberController.text, businessNameController.text, '10'));
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
          child:  Text('Done', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value.isEmpty){
      return 'Please enter your email.';
    }
    if (!regex.hasMatch(value))
      return 'Please enter a valid email.';
    else
      return null;
  }
}
