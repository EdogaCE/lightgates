import 'package:flutter/material.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'general.dart';

class EditStudentProfile extends StatelessWidget {
  final String editing;
  final Students students;
  EditStudentProfile({this.students, this.editing});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(updateProfileRepository: UpdateProfileRequest()),
      child: EditStudentProfilePage(students, editing),
    );
  }
}

// ignore: must_be_immutable
class EditStudentProfilePage extends StatelessWidget {
  final String editing;
  final Students students;
  EditStudentProfilePage(this.students, this.editing);
  String _country = "Nigeria";
  String _countryCode;
  ProfileBloc _profileBloc;
  bool otherTile=false;
  bool _boardingStatus;
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final oNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final healthHistoryController= TextEditingController();
  final parentNameController= TextEditingController();
  final parenTitleController= TextEditingController();
  final parentPhoneController= TextEditingController();
  final parentEmailController= TextEditingController();
  final parentAddressController= TextEditingController();
  final parentOccupationController= TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final formatDate = DateFormat("yyyy-MM-dd");
  String genderDropdownValue = '---gender---';
  List<String> genderSpinnerItems = ["---gender---", "male", "female"];

  String bloodGroupDropdownValue = '---blood group---';
  List<String> bloodGroupSpinnerItems = ["---blood group---", "A+", "A-", "AB+", "AB-", "B+", "B-", "O+", "O-"];

  String genotypeDropdownValue = '---genotype---';
  List<String> genotypeSpinnerItems = ["---genotype---", "AA", "AS", "SS"];

  String parentTitleDropdownValue = '---title---';
  List<String> parentTitleSpinnerItems = ["---title---", 'Mr', 'Mrs', "Dr", "Engr", "Others"];

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

  void _viewCurrencies() async {
    if(editing=='currency'){
    _profileBloc.add(GetCurrenciesEvent(await getApiToken()));
    }
  }

  void _populateForm(){
    _country = students.nationality;
    fNameController.text = students.fName;
    lNameController.text = students.lName;
    oNameController.text = students.mName;
    emailController.text=students.email;
    phoneController.text = students.phone;
    addressController.text = students.residentAddress;
    cityController.text = students.city;
    stateController.text = students.state;
    healthHistoryController.text=students.healthHistory;
    parenTitleController.text=toSentenceCase(students.parentTitle);
    parentNameController.text=students.parentName;
    parentPhoneController.text=students.parentPhone;
    parentEmailController.text=students.parentEmail;
    parentAddressController.text=students.parentAddress;
    parentOccupationController.text=students.parentOccupation;
    selectedDate=convertDateFromString(students.dob);
    _boardingStatus=students.boardingStatus;
    if(genderSpinnerItems.contains(students.gender.toLowerCase()))
      genderDropdownValue=students.gender.toLowerCase();
    if(bloodGroupSpinnerItems.contains(students.bloodGroup.toUpperCase()))
      bloodGroupDropdownValue=students.bloodGroup.toUpperCase();
    if(genotypeSpinnerItems.contains(students.genotype.toUpperCase()))
      genotypeDropdownValue=students.genotype.toUpperCase();
    if(parentTitleSpinnerItems.contains(students.parentTitle.toUpperCase()))
      parentTitleDropdownValue=toSentenceCase(students.parentTitle);
  }

  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _populateForm();
    _viewCurrencies();
    try{
      parentTitleDropdownValue=toSentenceCase(students.parentTitle);
    }on NoSuchMethodError{
      otherTile=true;
    }

    return Scaffold(
        appBar: AppBar(
          title:
          Text("Edit ${toSentenceCase(editing)}", style: TextStyle(color: MyColors.primaryColor)),
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: MyColors.primaryColor),
        ),
        //backgroundColor: Colors.white,
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: (editing == 'name')
                          ? nameForm(context)
                          : (editing == 'email')
                          ? emailForm(context)
                          : (editing == 'phone')
                          ? phoneForm(context)
                          : (editing == 'address')
                          ? addressForm(context)
                          : (editing == 'gender')
                          ? genderForm(context)
                          : (editing == 'dob')
                          ? dobForm(context)
                          :(editing == 'blood group')
                          ? bloodGroupForm(context)
                          : (editing == 'genotype')
                          ? genotypeForm(context)
                          : (editing == 'health history')
                          ? healthHistoryForm(context)
                          : (editing == 'boarding status')
                          ? boardingStatusForm(context)
                          : (editing == 'parent name')
                          ? parentNameForm(context)
                          : (editing == 'parent email')
                          ? parentEmailForm(context)
                          : (editing == 'parent phone')
                          ? parentPhoneForm(context)
                          : (editing == 'parent address')
                          ? parentAddressForm(context)
                          : (editing == 'currency')
                          ? currencyForm(context)
                          : parentOccupationForm(context)//'parent occupation'
                  ),
                ),
              ),
              BlocListener<ProfileBloc, ProfileStates>(
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
                  }
                },
                child: BlocBuilder<ProfileBloc, ProfileStates>(
                  builder: (BuildContext context, ProfileStates state) {
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget nameForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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

  Widget bloodGroupForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is BloodGroupChanged) {
                bloodGroupDropdownValue = state.bloodGroup;
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
                      child: Text("Select your blood group",
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
                            value: bloodGroupDropdownValue,
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
                              _profileBloc.add(ChangeBloodGroupEvent(data));
                            },
                            items: bloodGroupSpinnerItems
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

  Widget genotypeForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is GenotypeChanged) {
                genotypeDropdownValue = state.genotype;
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
                      child: Text("Select your genotype",
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
                            value: genotypeDropdownValue,
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
                              _profileBloc.add(ChangeGenotypeEvent(data));
                            },
                            items: genotypeSpinnerItems
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
                                          child: Text(selectedDate!=DateTime.now()
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

  Widget healthHistoryForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              controller: healthHistoryController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your health history.';
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
                  prefixIcon: Icon(Icons.history, color: Colors.teal),
                  labelText: 'Health history',
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

  Widget emailForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              validator: validateEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.email, color: Colors.teal),
                  labelText: 'Email',
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

  Widget parentNameForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: BlocListener<ProfileBloc, ProfileStates>(
                    listener: (BuildContext context,
                        ProfileStates state) {
                      if (state is TileChanged) {
                        parentTitleDropdownValue = state.title;
                        if(state.title=='Others'){
                          otherTile=true;
                        }else{
                          otherTile=false;
                          parenTitleController.text=state.title;
                        }
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
                                    value: parentTitleDropdownValue,
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
                                    items: parentTitleSpinnerItems
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
              ),
              BlocBuilder<ProfileBloc, ProfileStates>(
                  builder: (BuildContext context,
                      ProfileStates state) {
                    return otherTile?Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: parenTitleController,
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
                    ):Container();
                  },
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: parentNameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter name.';
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
                  labelText: 'Parent name',
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

  Widget parentEmailForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: parentEmailController,
              validator: validateEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(25.0),
                    ),
                  ),
                  //icon: Icon(Icons.email),
                  prefixIcon: Icon(Icons.email, color: Colors.teal),
                  labelText: 'Parent email',
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

  Widget parentPhoneForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: parentPhoneController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter phone number';
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
                  prefixIcon: Icon(Icons.phone, color: Colors.teal),
                  labelText: 'Parent phone',
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

  Widget parentAddressForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: parentAddressController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter address';
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
                  prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                  labelText: 'Parent address',
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

  Widget parentOccupationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: parentOccupationController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter occupation';
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
                  prefixIcon: Icon(Icons.work, color: Colors.teal),
                  labelText: 'Parent occupation',
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
                  _profileBloc.add(SelectCurrencyEvent(currencySpinnerItems[currencySpinnerIds.indexOf(students.currency.id)]));
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

  Widget boardingStatusForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (BuildContext context,
                ProfileStates state) {
              if (state is BoardingStatusChanged) {
                _boardingStatus = state.value;
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (BuildContext context,
                  ProfileStates state) {
                return ListTile(
                  title: Text("Boarding status",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18,
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Is ${students.lName} ${students.fName} a boarding student?",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ),
                      Switch(
                          value: _boardingStatus,
                          activeColor: MyColors.primaryColor,
                          onChanged: _useBoardingStatusChanged)
                    ],
                  ),
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

  void _useBoardingStatusChanged(bool value){
    _profileBloc.add(ChangeBoardingStatusEvent(value));
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
    if(editing=='gender' && genderDropdownValue == '---gender---'){
      valid=false;
      showToast(message: 'Please select gender');
    }
    if(editing=='blood group' && bloodGroupDropdownValue == '---blood group---'){
      valid=false;
      showToast(message: 'Please select blood group');
    }
    if(editing=='genotype' && genotypeDropdownValue == '---genotype---'){
      valid=false;
      showToast(message: 'Please select genotype');
    }
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
          if(validateSpinner()){
            if (_formKey.currentState.validate()) {
              if(editing.contains('parent')){
                _profileBloc.add(UpdateParentProfileEvent(students.id, students.parentId, parentNameController.text, parenTitleController.text, parentAddressController.text, parentOccupationController.text));
              }else{
                _profileBloc.add(UpdateStudentProfileEvent(students.id, fNameController.text, lNameController.text, oNameController.text, genderDropdownValue, emailController.text, phoneController.text, addressController.text, cityController.text, stateController.text, _country, formatDate.format(selectedDate), bloodGroupDropdownValue, genotypeDropdownValue, healthHistoryController.text, (currencyDropdownValue == '---currency---')?students.currency.id:currencySpinnerIds[currencySpinnerItems.indexOf(currencyDropdownValue)], _boardingStatus?'yes':'no'));

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
          child: const Text("Done", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

