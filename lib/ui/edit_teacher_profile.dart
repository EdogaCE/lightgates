import 'package:flutter/material.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'modals.dart';

class EditTeacherProfile extends StatelessWidget {
  final String editing;
  final Teachers teachers;
  EditTeacherProfile({this.editing, this.teachers});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(updateProfileRepository: UpdateProfileRequest()),
      child: EditTeacherProfilePage(editing, teachers),
    );
  }
}

// ignore: must_be_immutable
class EditTeacherProfilePage extends StatelessWidget {
  final String editing;
  final Teachers teachers;
  EditTeacherProfilePage(
      this.editing,
      this.teachers);
  String _country = "Nigeria";
  String _countryCode;
  String _currency;
  ProfileBloc _profileBloc;

  final titleController= TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final oNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final roleController = TextEditingController();
  final salaryController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final formatDate = DateFormat("yyyy-MM-dd");
  String genderDropdownValue = '---gender---';
  List<String> genderSpinnerItems = ["---gender---", "male", "female"];
  DateTime selectedDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year - 500),
        lastDate: DateTime(selectedDate.year + 200));
    if (picked != null && picked != selectedDate)
      _profileBloc.add(ChangeDateEvent(picked));
  }

  String currencyDropdownValue = '---currency---';
  List<String> currencySpinnerItems = ["---currency---"];
  List<String> currencySpinnerIds = ['0'];

  String bankDropdownValue = '---Bank---';
  List<String> bankSpinnerItems = ["---Bank---"];
  List<String> bankSpinnerIds = ['0'];

  bool otherTile=false;
  String titleDropdownValue = '---title---';
  List<String> titleSpinnerItems = ["---title---", 'Mr', 'Mrs', "Dr", "Engr", "Others"];

  void _viewSpinners() async {
    if(editing=='currency'){
      _profileBloc.add(GetCurrenciesEvent(await getApiToken()));
    }
    if(editing=='bank detail'){
      _profileBloc.add(GetFlutterWaveBankCodes());
    }

  }

  void populateForm()async{
    _country = teachers.nationality;
    titleController.text=toSentenceCase(teachers.title);
    fNameController.text = teachers.fName;
    lNameController.text = teachers.lName;
    oNameController.text = teachers.mName;
    phoneController.text = teachers.phone;
    addressController.text = teachers.address;
    cityController.text = teachers.city;
    stateController.text = teachers.state;
    selectedDate=convertDateFromString(teachers.dob);
    roleController.text=teachers.role;
    bankAccountNumberController.text=teachers.bankAccountNumber;
    salaryController.text=convertPrice(currency: teachers.school.currency, amount: teachers.salary).split(' ').last;
    _currency=await getUserCurrency();
    if(genderSpinnerItems.contains(teachers.gender.toLowerCase()))
      genderDropdownValue=teachers.gender.toLowerCase();
    if(titleSpinnerItems.contains(teachers.title.toUpperCase()))
      titleDropdownValue=toSentenceCase(teachers.title);
  }

  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    populateForm();
    _viewSpinners();
    return Scaffold(
        appBar: AppBar(
          title:
              Text("Edit ${toSentenceCase(editing)}", style: TextStyle(color: MyColors.primaryColor)),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MyColors.primaryColor),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context, ProfileStates state) {
              if (state is ProfileUpdating) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(minutes: 30),
                    content: General.progressIndicator("Updating..."),
                  ),
                );
              } else if (state is NetworkErr) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                  SnackBar(
                    content:
                        Text(state.message, textAlign: TextAlign.center),
                  ),
                );
              } else if (state is UpdateError) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                  SnackBar(
                    content:
                        Text(state.message, textAlign: TextAlign.center),
                  ),
                );
              } else if (state is ProfileUpdated) {
                Navigator.pop(context, state.message);
              }else if (state is TileChanged) {
                titleDropdownValue = state.title;
                titleController.text=state.title;
                if(state.title=='Others'){
                  otherTile=true;
                }else{
                  otherTile=false;
                }
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (BuildContext context, ProfileStates state) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: (editing == 'name')
                            ? nameForm(context)
                            : (editing == 'phone')
                            ? phoneForm(context)
                            : (editing == 'address')
                            ? addressForm(context)
                            : (editing == 'gender')
                            ? genderForm(context)
                            : (editing == 'dob')
                            ? dobForm(context)
                            : (editing == 'role')
                            ? roleForm(context)
                            : (editing == 'salary')
                            ? salaryForm(context)
                            : (editing == 'currency')
                            ?currencyForm(context)
                            :bankDetailsForm(context)/// 'bank detail'
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Widget nameForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text("Select title",
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
                              left: 10.0, right: 20.0, top: 3.0, bottom: 3.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: titleDropdownValue,
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
                              _profileBloc.add(ChangeTitleEvent(data));
                            },
                            items: titleSpinnerItems
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
              ),
              otherTile?Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: titleController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please title.';
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
                        //prefixIcon: Icon(Icons.title, color: Colors.orange),
                        labelText: 'Title',
                        labelStyle: new TextStyle(color: Colors.grey[800]),
                        filled: true,
                        fillColor: Colors.white70),
                  ),
                ),
              ):Container(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: fNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your first name.';
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
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  labelText: 'Firstname',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: lNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your last name.';
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
                  prefixIcon: Icon(Icons.person, color: Colors.red),
                  labelText: 'Lastname',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: oNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your other name.';
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
                  prefixIcon: Icon(Icons.person, color: Colors.teal),
                  labelText: 'Other name',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
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

  Widget phoneForm(BuildContext context) {
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
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 0.0, bottom: 8.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: phoneController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your phone number.';
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
                  prefixIcon: Icon(Icons.phone, color: MyColors.primaryColor),
                  labelText: 'Phone',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
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

  Widget addressForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: addressController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your address.';
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
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  labelText: 'Address',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: stateController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your state.';
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
                prefixIcon: Icon(Icons.location_on, color: MyColors.primaryColor),
                labelText: 'State',
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
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter city.';
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
                  prefixIcon: Icon(Icons.location_city, color: Colors.pink),
                  labelText: 'City',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
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

  Widget genderForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is GenderChanged) {
                genderDropdownValue = state.gender;
              }
            },
            child:
            BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (BuildContext context,
                  ProfileStates state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text("Select your gender",
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
                            value: genderDropdownValue,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                                color: Colors.black, fontSize: 18),
                            underline: Container(
                              height: 0,
                              color: MyColors.primaryColor,
                            ),
                            onChanged: (String gender) {
                              _profileBloc.add(ChangeGenderEvent(gender));
                            },
                            items: genderSpinnerItems
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

  Widget dobForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    children: <Widget>[
                      BlocListener<ProfileBloc, ProfileStates>(
                        listener: (BuildContext context,
                            ProfileStates state) {
                          if (state is DateChanged) {
                            selectedDate = state.date;
                          }
                        },
                        child:
                        BlocBuilder<ProfileBloc, ProfileStates>(
                          builder: (BuildContext context,
                              ProfileStates state) {
                            return Expanded(
                              child: GestureDetector(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 30.0),
                                        child: Text("Date Of Birth",
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
                                          child: Text(
                                              selectedDate!=DateTime.now()
                                                  ?"${selectedDate.toLocal()}".split(' ').first:"yyyy-MM-dd",
                                              textAlign:
                                              TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                  Colors.black87,
                                                  fontWeight:
                                                  FontWeight
                                                      .normal)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () =>_selectDate(context)
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
              ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _doneButtonFill(context),
          )
        ],
      ),
    );
  }

  Widget roleForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: roleController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter role.';
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
            prefixIcon: Icon(Icons.map, color: Colors.orange),
            labelText: 'Role',
            labelStyle: new TextStyle(color: Colors.grey[800]),
            filled: true,
            fillColor: Colors.white70),
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

  Widget salaryForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocBuilder<ProfileBloc, ProfileStates>(
            builder: (BuildContext context, ProfileStates state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: salaryController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter salary ($_currency).';
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
                      prefixIcon: Icon(Icons.monetization_on, color: Colors.teal),
                      labelText: 'Salary ($_currency)',
                      labelStyle: new TextStyle(color: Colors.grey[800]),
                      filled: true,
                      fillColor: Colors.white70),
                ),
              );
            },
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
                  _profileBloc.add(SelectCurrencyEvent(currencySpinnerItems[currencySpinnerIds.indexOf(teachers.currency.id)]));
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
                                  color: MyColors.primaryColor,
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

  Widget bankDetailsForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is BankSelected) {
                bankDropdownValue = state.bank;
              } else if (state is BanksLoaded) {
                bankSpinnerItems.addAll(state.banks[0]);
                bankSpinnerIds.addAll(state.banks[1]);
                try{
                  _profileBloc.add(SelectBankEvent(bankSpinnerItems[bankSpinnerIds.indexOf(teachers.bankCode)]));
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
                                value: bankDropdownValue,
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
                                  _profileBloc.add(SelectBankEvent(data));
                                },
                                items: bankSpinnerItems.map<DropdownMenuItem<String>>((String value) {
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
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: bankAccountNumberController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter account number';
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
                  prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.teal),
                  labelText: 'Account number',
                  labelStyle: new TextStyle(color: Colors.grey[800]),
                  filled: true,
                  fillColor: Colors.white70),
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
    _country = countryCode.name;
    _countryCode = countryCode.toString();

    print("New Country selected: " +
        countryCode.toString() +
        " " +
        countryCode.name);
  }

  bool validateSpinner(){
    bool valid=true;

    if(editing=='name' && titleController.text.isEmpty){
      valid=false;
      showToast(message: 'Please select title');
    }

    if(editing=='gender' && genderDropdownValue == '---gender---'){
      valid=false;
      showToast(message: 'Please select gender');
    }
    if(editing=='currency' && currencyDropdownValue == '---currency---'){
      valid=false;
      showToast(message: 'Please select currency');
    }
    if(editing=='bank detail' && bankDropdownValue == '---Bank---'){
      valid=false;
      showToast(message: 'Please select bank');
    }
    return valid;
  }

  Widget _doneButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if(validateSpinner()){
            if (_formKey.currentState.validate()) {
              _profileBloc.add(UpdateTeacherProfileEvent(teachers.id, titleController.text, fNameController.text, lNameController.text, oNameController.text, genderDropdownValue, phoneController.text, addressController.text, cityController.text, stateController.text, _country, formatDate.format(selectedDate), roleController.text, salaryController.text.replaceAll(',', ''), (currencyDropdownValue == '---currency---')?teachers.currency.id:currencySpinnerIds[currencySpinnerItems.indexOf(currencyDropdownValue)], (bankDropdownValue == '---Bank---')?teachers.bankCode:bankSpinnerIds[bankSpinnerItems.indexOf(bankDropdownValue)], (bankDropdownValue == '---Bank---')?teachers.bankName:bankDropdownValue, bankAccountNumberController.text));

              print('$_country, ${fNameController.text}, ${lNameController.text}, ${oNameController.text},  $genderDropdownValue, ${phoneController.text},  ${addressController.text}, ${cityController.text}, ${stateController.text}, $_country, ${formatDate.format(selectedDate)}');
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
