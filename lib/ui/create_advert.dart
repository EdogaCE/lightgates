import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/advert/advert.dart';
import 'package:school_pal/models/advert.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_adverts_request.dart';
import 'package:school_pal/requests/get/view_wallet_request.dart';
import 'package:school_pal/requests/posts/update_advert_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/utils/image_cropper.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'package:country_code_picker/country_code_picker.dart';


class CreateAdvert extends StatelessWidget {
  final bool edit;
  final Advert advert;
  CreateAdvert({this.edit, this.advert});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertBloc(viewAdvertsRepository: ViewAdvertsRequest(),
          updateAdvertRepository: UpdateAdvertRequests(), viewWalletRepository: ViewWalletRequest()),
      child: CreateAdvertPage(edit, advert),
    );
  }
}

// ignore: must_be_immutable
class CreateAdvertPage extends StatelessWidget {
  final bool edit;
  final Advert advert;
  CreateAdvertPage(this.edit, this.advert);
// ignore: close_sinks
  AdvertBloc _advertBloc;
  final formatDate = DateFormat("yyyy-MM-dd");
  DateTime selectedDateFrom = DateTime.now();
  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year - 500),
        lastDate: DateTime(selectedDateFrom.year + 500));
    if (picked != null && picked != selectedDateFrom)
      _advertBloc.add(ChangeDateFromEvent(picked));
  }
  DateTime selectedDateTo = DateTime.now();
  Future<Null> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year - 5),
        lastDate: DateTime(selectedDateTo.year + 5));
    if (picked != null && picked != selectedDateTo)
      _advertBloc.add(ChangeDateToEvent(picked));
  }

  final budgetController = TextEditingController();
  final descriptionController = TextEditingController();
  final imagePathController = TextEditingController();
  final webUrlController = TextEditingController();
  final appUrlController = TextEditingController();
  final whatsAppNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _deriveTrafficTo='website';
  String _advertValidateStatement='';
  String _walletBalance='0';
//  String _country = "Nigeria";
  String _countryCode='';

  void populateForm()async{
    _advertBloc.add(ViewWalletBalanceEvent());
    if(edit){
      budgetController.text=convertPriceNoFormatting(currency: advert.preferredCurrency, amount: advert.budget);
      selectedDateFrom=convertDateFromString(advert.startDate);
      selectedDateTo=convertDateFromString(advert.endDate);
      _deriveTrafficTo=advert.driveTrafficTo;
      whatsAppNumberController.text=advert.whatsAppNo;
      if(advert.driveTrafficTo=='website')
      webUrlController.text=advert.websiteAppUrl;
      if(advert.driveTrafficTo=='app')
      appUrlController.text=advert.websiteAppUrl;
      descriptionController.text=advert.description;

      if(budgetController.text.isNotEmpty&& selectedDateFrom.day!=DateTime.now().day && selectedDateTo.day!=DateTime.now().day){
        _advertBloc.add(ValidateAdvertEvent(budget: budgetController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal())));
      }
    }
  }

  void _onCountryChange(CountryCode countryCode) {
    //Todo : manipulate the selected country code here
    //_country = countryCode.name;
    _countryCode = countryCode.dialCode;

    print("New Country selected: " +
        countryCode.dialCode +
        " " +
        countryCode.name);
  }

  @override
  Widget build(BuildContext context) {
    _advertBloc = BlocProvider.of<AdvertBloc>(context);
    populateForm();
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text(edit?"Update Campaign":"Create Campaign", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: BlocListener<AdvertBloc, AdvertStates>(
                listener: (BuildContext context,  state) {
                  if(state is AdvertsProcessing){
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Processing..."),
                      ),
                    );
                  }else if(state is AdvertNetworkErr){
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                  } else if(state is AdvertViewError){
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                  }else if (state is DateToChanged) {
                    selectedDateTo = state.to;
                    if(budgetController.text.isNotEmpty&& selectedDateFrom.day!=DateTime.now().day && selectedDateTo.day!=DateTime.now().day){
                      _advertBloc.add(ValidateAdvertEvent(budget: budgetController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal())));
                    }
                  }else if (state is DateFromChanged) {
                    selectedDateFrom = state.from;
                    if(budgetController.text.isNotEmpty&& selectedDateFrom.day!=DateTime.now().day && selectedDateTo.day!=DateTime.now().day){
                      _advertBloc.add(ValidateAdvertEvent(budget: budgetController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal())));
                    }
                  }else if (state is DriveTrafficToChanged) {
                    _deriveTrafficTo = state.value;
                  }else if (state is ImageSelected) {
                    imagePathController.text = state.path;
                  }else if (state is AdvertValidated) {
                    Scaffold.of(context).removeCurrentSnackBar();
                    _advertValidateStatement = state.message;
                  }else if (state is WalletBalanceLoaded) {
                    Scaffold.of(context).removeCurrentSnackBar();
                    if(state.school.isNotEmpty){
                      _walletBalance = convertPrice(currency: state.school.first.currency, amount: state.school.first.walletBalance);
                    }else{_walletBalance='0.00';}

                  }else if (state is AdCampaignCreated) {
                    Scaffold.of(context).removeCurrentSnackBar();
                    Navigator.pop(context, state.message);
                  }else if (state is AdCampaignUpdated) {
                    Scaffold.of(context).removeCurrentSnackBar();
                    Navigator.pop(context, state.message);
                  }
                },
                child: BlocBuilder<AdvertBloc, AdvertStates>(
                  builder: (BuildContext context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            // margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text("Ads relating to or showcasing a particular school's activities are not allowed as this may negatively impact "
                                  "the sensitivities of other schools. Only personal and private ads for self employed or service providers are allowed.",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Wallet Balance: ',  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: _walletBalance, style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Budget is required.';
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
                                Icon(Icons.monetization_on, color: Colors.blue),
                                labelText: 'Budget',
                                labelStyle: new TextStyle(
                                    color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                            onChanged: (value){
                              if(value.isNotEmpty&& selectedDateFrom.day!=DateTime.now().day && selectedDateTo.day!=DateTime.now().day){
                                _advertBloc.add(ValidateAdvertEvent(budget: budgetController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal())));
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, right: 8.0, top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Campaign Duration*',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 30.0),
                                      child: Text("Start Date",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                              MyColors.primaryColor,
                                              fontWeight: FontWeight
                                                  .normal)),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 1.0),
                                      child: Container(
                                        width: double.maxFinite,
                                        padding:
                                        EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(
                                              25.0),
                                          border: Border.all(
                                              color: Colors
                                                  .deepPurpleAccent,
                                              style:
                                              BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: Text(formatDate.format(selectedDateFrom.toLocal()),
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                Colors.black87,
                                                fontWeight:
                                                FontWeight
                                                    .normal)),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    _selectDateFrom(context),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 30.0),
                                      child: Text("End Date",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                              MyColors.primaryColor,
                                              fontWeight: FontWeight
                                                  .normal)),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 8.0,
                                          top: 1.0),
                                      child: Container(
                                        width: double.maxFinite,
                                        padding:
                                        EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(
                                              25.0),
                                          border: Border.all(
                                              color: MyColors.primaryColor,
                                              style:
                                              BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: Text(formatDate.format(selectedDateTo.toLocal()),
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                Colors.black87,
                                                fontWeight:
                                                FontWeight
                                                    .normal)),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _selectDateTo(context),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: RichText(
                            text: TextSpan(text: _advertValidateStatement, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black)),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Traffic*',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: '\n Choose where you want to drive traffic to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new Radio(
                                  value: 'website',
                                  groupValue: _deriveTrafficTo,
                                  onChanged: _deriveTrafficToChanges,
                                ),
                                new Text(
                                  'Website',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 'whatsapp',
                                  groupValue: _deriveTrafficTo,
                                  onChanged: _deriveTrafficToChanges,
                                ),
                                new Text(
                                  'Whatsapp',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                new Radio(
                                  value: 'app',
                                  groupValue: _deriveTrafficTo,
                                  onChanged: _deriveTrafficToChanges,
                                ),
                                new Text(
                                  'App',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 8.0),
                              child: _deriveTrafficTo=='whatsapp'?Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 0.0),
                                    child: Stack(
                                      children: <Widget>[
                                        CountryCodePicker(
                                          onChanged: _onCountryChange,
                                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                          initialSelection: 'NG',
                                          favorite: ['+234','NG'],
                                          // optional. Shows only country name and flag
                                          showCountryOnly: false,
                                          // optional. Shows only country name and flag when popup is closed.
                                          showOnlyCountryWhenClosed: false,
                                          // optional. aligns the flag and the Text left
                                          alignLeft: true,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 15.0, right: 100.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.expand_more, size: 20.0, color: Colors.black87,)),
                                        )
                                      ],
                                    ),
                                  ),
                                  TextFormField(
                                    controller: whatsAppNumberController,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (_deriveTrafficTo=='whatsapp'&&value.isEmpty) {
                                        return 'Whatsapp number is required.';
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
                                        Icon(Icons.chat, color: Colors.blue),
                                        labelText: 'Whatsapp No',
                                        labelStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        filled: true,
                                        fillColor: Colors.white70),
                                  ),
                                ],
                              ):_deriveTrafficTo=='website'?TextFormField(
                                controller: webUrlController,
                                keyboardType: TextInputType.url,
                                validator: (value) {
                                  if (_deriveTrafficTo!='website'&&value.isEmpty) {
                                    return 'Website Url is required.';
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
                                    Icon(Icons.web, color: Colors.blue),
                                    labelText: 'Website Url',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ):TextFormField(
                                controller: appUrlController,
                                keyboardType: TextInputType.url,
                                validator: (value) {
                                  if (_deriveTrafficTo!='app'&&value.isEmpty) {
                                    return 'App Url is required.';
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
                                    Icon(Icons.web, color: Colors.blue),
                                    labelText: 'App url',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              )
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Upload Image*',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: '\nUpload an image that best describes your advert', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: imagePathController,
                            keyboardType: TextInputType.url,
                            readOnly: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ),
                                ),
                                //icon: Icon(Icons.email),
                                suffixIcon:IconButton(icon: Icon(Icons.attach_file),
                                    onPressed: () async{
                                      final pickedImage=await pickImage(context, true);
                                      File fileImage = await cropImage(File(pickedImage.path));
                                      _advertBloc.add(SelectImageEvent(fileImage.path));

                                }),
                                labelText: 'Image path',
                                labelStyle: new TextStyle(
                                    color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Caption*',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: '\nThe description will show in your ads. This is just little description of what your ads portrays. Not more than 100 Characters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            maxLength: 100,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Description is required.';
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
                                Icon(Icons.description, color: Colors.blue),
                                labelText: 'Description',
                                labelStyle: new TextStyle(
                                    color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _doneButtonFill(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ));
  }

  void _deriveTrafficToChanges(String value) {
    _advertBloc.add(ChangeDriveTrafficToEvent(value));
  }

  Widget _doneButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(edit){
              _advertBloc.add(UpdateAdCampaignEvent(addCampaignId: advert.userUniqueId, caption: descriptionController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal()), budget: budgetController.text, driveTrafficTo: _deriveTrafficTo, whatsAppNo: whatsAppNumberController.text, countryCode: _countryCode, webAppUrl: _deriveTrafficTo=='app'?appUrlController.text:_deriveTrafficTo=='website'?webUrlController.text:'', webUrl: webUrlController.text, appUrl: appUrlController.text, images: [imagePathController.text]));
            }else{
              _advertBloc.add(CreateAdCampaignEvent(caption: descriptionController.text, startDate: formatDate.format(selectedDateFrom.toLocal()), endDate: formatDate.format(selectedDateTo.toLocal()), budget: budgetController.text, driveTrafficTo: _deriveTrafficTo, whatsAppNo: whatsAppNumberController.text, countryCode: _countryCode, webAppUrl: _deriveTrafficTo=='app'?appUrlController.text:_deriveTrafficTo=='website'?webUrlController.text:'', webUrl: webUrlController.text, appUrl: appUrlController.text, images: [imagePathController.text]));
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
          child: const Text("Done", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
