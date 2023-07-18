import 'package:flutter/material.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';

class EditSchoolProfile extends StatelessWidget {
  final String editing;
  final School school;
  EditSchoolProfile({this.editing, this.school});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(updateProfileRepository: UpdateProfileRequest()),
      child: EditSchoolProfilePage(editing, school),
    );
  }
}

// ignore: must_be_immutable
class EditSchoolProfilePage extends StatelessWidget {
  final String editing;
  final School school;
  EditSchoolProfilePage(this.editing, this.school);
  String _country="Nigeria";
  String _countryCode;
  ProfileBloc _profileBloc;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final townController = TextEditingController();
  final cityController = TextEditingController();
  final lgaController = TextEditingController();
  final sloganController = TextEditingController();
  final poBoxController = TextEditingController();
  final websiteController = TextEditingController();
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();

  String currencyDropdownValue = '---currency---';
  List<String> currencySpinnerItems = ["---currency---"];
  List<String> currencySpinnerIds = ['0'];

  void _viewCurrencies() async {
    if(editing=='currency'){
      _profileBloc.add(GetCurrenciesEvent(await getApiToken()));
    }
  }

  void _populateForm(){
    _country=school.nationality;
    nameController.text=school.name;
    phoneController.text=school.phone;
    addressController.text=school.address;
    townController.text=school.town;
    cityController.text=school.city;
    lgaController.text=school.lga;
    sloganController.text=school.slogan;
    poBoxController.text=school.poBox;
    websiteController.text=school.website;
    facebookController.text=school.facebook;
    instagramController.text=school.instagram;
    twitterController.text=school.twitter;
  }

  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _populateForm();
    _viewCurrencies();
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Contacts", style: TextStyle(color: MyColors.primaryColor)),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
            color: MyColors.primaryColor
        ),
      ),
      //backgroundColor: Colors.white,
        body:CustomPaint(
          painter: BackgroundPainter(),
          child:Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child:  Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: (editing=='name')
                        ?nameForm(context)
                        :(editing=='phone')
                        ?phoneForm(context)
                        :(editing=='address')
                        ?addressForm(context)
                        :(editing=='slogan')
                        ?sloganForm(context)
                        :(editing=='poBox')
                        ?poBoxForm(context)
                        :(editing=='website')
                        ?websiteForm(context)
                        :(editing=='facebook')
                        ?facebookForm(context)
                        :(editing=='instagram')
                        ?instagramForm(context)
                        :(editing=='twitter')
                        ?twitterForm(context)
                        :currencyForm(context)//'currency'
                  ),
                ),
              ),
              BlocListener<ProfileBloc, ProfileStates>(
                listener: (BuildContext context, ProfileStates state) {
                  if(state is ProfileUpdating){
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Updating..."),
                      ),
                    );
                  }else if(state is NetworkErr){
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content: Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  } else if(state is UpdateError){
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content: Text(state.message, textAlign: TextAlign.center),
                      ),
                    );
                  }else if(state is ProfileUpdated){
                    Navigator.pop(context, state.message);
                  }

                },
                child: BlocBuilder<ProfileBloc, ProfileStates>(builder:
                    (BuildContext context, ProfileStates state) {
                  return Container();
                },
                ),
              ),
            ],
          ),
        )
    );
  }
  Widget nameForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: nameController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school\'s name.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.business, color: MyColors.primaryColor),
                  labelText: 'School name',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget phoneForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[

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

          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 8.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: phoneController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your phone number.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.phone, color: MyColors.primaryColor),
                  labelText: 'Phone',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget addressForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: addressController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter school address.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  labelText: 'Address',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: townController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter town or city.';
                }
                return null;
              },
              decoration: InputDecoration(
                border:OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(25.0),
                  ),
                ),
                //icon: Icon(Icons.email),
                prefixIcon: Icon(Icons.location_on, color: MyColors.primaryColor),
                labelText: 'Town/City',
                labelStyle: new TextStyle(color: Colors.grey[800]),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: cityController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter state province or region.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.location_city, color: Colors.pink),
                  labelText: 'State/Province/Region',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),

          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: lgaController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter lga.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.location_city, color: Colors.black),
                  labelText: 'LGA',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget sloganForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: sloganController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school slogan.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.business, color: MyColors.primaryColor),
                  labelText: 'Slogan',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget poBoxForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: poBoxController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school P.O Box.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.polymer, color: MyColors.primaryColor),
                  labelText: 'P.O. Box',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget websiteForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: websiteController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school website.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.web, color: MyColors.primaryColor),
                  labelText: 'Website',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget facebookForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: facebookController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school facebook handle.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.chat, color: MyColors.primaryColor),
                  labelText: 'Facebook',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget instagramForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: instagramController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school instagram handle.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.chat, color: MyColors.primaryColor),
                  labelText: 'Instagram',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget twitterForm(BuildContext context){
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: twitterController,
              validator:  (value) {
                if(value.isEmpty){
                  return 'Please enter your school twitter handle.';
                }
                return null;
              },
              decoration: InputDecoration(
                  border:OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.chat, color: MyColors.primaryColor),
                  labelText: 'Twitter',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget currencyForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is CurrencySelected) {
                currencyDropdownValue = state.currency;
              } else if (state is CurrenciesLoaded) {
                currencySpinnerItems.addAll(state.currencies[0]);
                currencySpinnerIds.addAll(state.currencies[1]);
                try{
                  _profileBloc.add(SelectCurrencyEvent(currencySpinnerItems[currencySpinnerIds.indexOf(school.currency.id)]));
                } on NoSuchMethodError{}
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (BuildContext context,
                  ProfileStates state) {
                return Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0),
                          child: Text("Select currency",
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
                              borderRadius:
                              BorderRadius.circular(
                                  25.0),
                              border: Border.all(color: MyColors.primaryColor,
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
                                value: currencyDropdownValue,
                                icon: Icon(
                                    Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18),
                                underline: Container(
                                  height: 0,
                                  color: Colors
                                      .deepPurpleAccent,
                                ),
                                onChanged: (String data) {
                                  _profileBloc.add(SelectCurrencyEvent(data));
                                },
                                items: currencySpinnerItems.map<DropdownMenuItem<String>>((String value) {
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
                    (state is ProfileLoading)
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
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    //Todo : manipulate the selected country code here
    _country=countryCode.name;
    _countryCode=countryCode.toString();

    print("New Country selected: " + countryCode.toString()+" "+countryCode.name);

  }

  bool validateSpinner(){
    bool valid=true;
    if(editing=='currency' && currencyDropdownValue == '---currency---'){
      valid=false;
      showToast(message: 'Please select currency');
    }
    return valid;
  }

  Widget _doneButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(validateSpinner()){
              if(editing=='currency'||editing=='poBox'){
                _profileBloc.add(UpdateSchoolSettingsEvent(school.id, poBoxController.text, (currencyDropdownValue == '---currency---')?school.currency.id:currencySpinnerIds[currencySpinnerItems.indexOf(currencyDropdownValue)], school.resultCommentSwitch, school.keyToTraitRating.split(':').first.split(','), school.keyToTraitRating.split(':').last.split(','), school.numOfTerm, school.initialAdmissionNum, school.numOfCumulativeTest, school.testExamScoreLimit.split(','), school.behaviouralSkillTestsHeadings.split(','), school.useCumulativeResult?'yes':'no', school.useCustomAdmissionNum?'yes':'no', school.useClassCategoryStatus?'yes':'no', school.useOfSignatureOnResults?'yes':'no'));
              }else{
          _profileBloc.add(UpdateSchoolProfileEvent(school.id, nameController.text, phoneController.text, addressController.text, townController.text, lgaController.text, cityController.text, _country, sloganController.text, websiteController.text, facebookController.text, instagramController.text, twitterController.text));
          }


              print('$_country, ${nameController.text},  ${phoneController.text},  ${addressController.text}, ${townController.text} ${cityController.text}, ${lgaController.text}, ${sloganController.text}, ${poBoxController.text}, $currencyDropdownValue, ${school.currency.id}, ${currencySpinnerIds[currencySpinnerItems.indexOf(currencyDropdownValue)]}');
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
          padding: const EdgeInsets.only(left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
          child: const Text(
              "Done",
              style: TextStyle(fontSize: 20)
          ),
        ),
      ),
    );
  }
}
