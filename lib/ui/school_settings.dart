import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/view_school_grades.dart';
import 'package:school_pal/utils/system.dart';

class SchoolSettings extends StatelessWidget {
  final School school;
  SchoolSettings({this.school});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(viewProfileRepository: ViewProfileRequest(),
              updateProfileRepository: UpdateProfileRequest()),
      child: SchoolSettingsPage(school),
    );
  }
}

// ignore: must_be_immutable
class SchoolSettingsPage extends StatelessWidget {
  final School school;
  SchoolSettingsPage(this.school);
  ProfileBloc _profileBloc;
  bool _madeChanges=false;
  bool _useCumulative;
  bool _useCustomAdmissionNum;
  bool _useClassCategory;
  bool _useOfSignatureOnResults;
  int _numberOfTerms;
  int _numberOfCumulativeTest;
  String _resultComment;
  String _initialAdmissionNumber;
  List<String> _scoreLimits;
  List<String> _behaviouralSkills;
  List<String> _traits;
  List<String> _traitRatings;

  void initSettings(){
    _resultComment=school.resultCommentSwitch;
    _useCumulative=school.useCumulativeResult;
    _useCustomAdmissionNum=school.useCustomAdmissionNum;
    _useClassCategory=school.useClassCategoryStatus;
    _useOfSignatureOnResults=school.useOfSignatureOnResults;
    _numberOfTerms=int.parse(school.numOfTerm);
    _numberOfCumulativeTest=int.parse(school.numOfCumulativeTest);
    _initialAdmissionNumber=school.initialAdmissionNum;
    _scoreLimits=school.testExamScoreLimit.split(',');
    _behaviouralSkills=school.behaviouralSkillTestsHeadings.split(',');
    _traits=school.keyToTraitRating.split(':').first.split(',');
    _traitRatings=school.keyToTraitRating.split(':').last.split(',');
  }
  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    initSettings();
    // TODO: implement build
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  _profileBloc.add(UpdateSchoolSettingsEvent(school.id, school.poBox, school.preferredCurrencyId, _resultComment, _traits, _traitRatings, _numberOfTerms.toString(), _initialAdmissionNumber, _numberOfCumulativeTest.toString(), _scoreLimits, _behaviouralSkills, _useCumulative?'yes':'no', _useCustomAdmissionNum?'yes':'no', _useClassCategory?'yes':'no', _useOfSignatureOnResults?'yes':'no'));

                  print('SETTINGS $_resultComment, $_traits, $_traitRatings, ${_numberOfTerms.toString()}, $_initialAdmissionNumber, ${_numberOfCumulativeTest.toString()}, $_scoreLimits, $_behaviouralSkills, ${_useCumulative?'yes':'no'}, ${_useCustomAdmissionNum?'yes':'no'}, ${_useClassCategory?'yes':'no'}');
                },
                child: Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.primaryColor),),
              )
            ],
            elevation: 0.0,
            backgroundColor: Colors.white,
            //Todo: to change back button color
            iconTheme: IconThemeData(color: MyColors.primaryColor),
            title: Text("Settings",
                style: TextStyle(color: MyColors.primaryColor)),
          ),
          body: CustomPaint(
              painter: BackgroundPainter(),
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: BlocListener<ProfileBloc, ProfileStates>(
                  listener: (BuildContext context,
                      ProfileStates state) {
                    if (state is UseCustomAdmissionNumChanged) {
                      _madeChanges=true;
                      _useCustomAdmissionNum = state.value;
                    }else if (state is InitialAdmissionNumChanged) {
                      _madeChanges=true;
                      _initialAdmissionNumber = state.value;
                    }else if (state is NumberOfTermsChanged) {
                      _madeChanges=true;
                      _numberOfTerms = state.count;
                    }else if (state is UseCumulativeChanged) {
                      _madeChanges=true;
                      _useCumulative = state.value;
                    }else if (state is UseClassCategoryChanged) {
                      _madeChanges=true;
                      _useClassCategory = state.value;
                    }else if(state is UseOfSignatureOnResultsChanged){
                      _madeChanges=true;
                      _useOfSignatureOnResults= state.value;
                    }else if (state is NumberOfCumulativeTestChanged) {
                      _madeChanges=true;
                      _numberOfCumulativeTest = state.count;
                    }else if (state is ResultCommentTypeChanged) {
                      _madeChanges=true;
                      _resultComment = state.value;
                    }else if (state is ScoreLimitChanged) {
                      _madeChanges=true;
                      _scoreLimits[state.position]=state.limit;
                    }else if (state is BehaviouralSkillChanged) {
                      _madeChanges=true;
                      _behaviouralSkills[state.position] = state.skill;
                    }else if (state is BehaviouralSkillsAdded) {
                      _madeChanges=true;
                      _behaviouralSkills.add(state.skill);
                    }else if (state is BehaviouralSkillsRemoved) {
                      _madeChanges=true;
                      _behaviouralSkills.removeLast();
                    } else if (state is TraitRatingChanged) {
                      _madeChanges=true;
                      _traits[state.position] = state.trait;
                      _traitRatings[state.position]=state.rating;
                    }else if (state is TraitRatingAdded) {
                      _madeChanges=true;
                      _traits.add(state.trait);
                      _traitRatings.add(state.rating);
                    }else if (state is TraitRatingRemoved) {
                      _madeChanges=true;
                      _traits.removeLast();
                      _traitRatings.removeLast();
                    }else if(state is ProfileUpdating){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Saving Changes..."),
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
                  child: BlocBuilder<ProfileBloc, ProfileStates>(
                    builder: (BuildContext context,
                        ProfileStates state) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Custom Admission Number",
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
                                            child: Text("Use custom admission number",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal)),
                                          ),
                                        ),
                                        Switch(
                                            value: _useCustomAdmissionNum,
                                            activeColor: MyColors.primaryColor,
                                            onChanged: _useCustomAdmissionNumChanged)
                                      ],
                                    ),
                                  ),
                                  _useCustomAdmissionNum?
                                  Divider(
                                    color: Colors.black87,
                                  ):Container(),
                                  _useCustomAdmissionNum?
                                  ListTile(
                                    title: Text("Initial Admission Number",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MyColors.primaryColor,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(_initialAdmissionNumber,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal)),
                                    ),
                                    onTap: (){
                                      showModalInputDialog(context: context, title: 'Change Initial Admission Number', value: _initialAdmissionNumber, textInputType: TextInputType.text)
                                          .then((value){
                                        if(value!=null)
                                          _profileBloc.add(ChangeInitialAdmissionNumEvent(value));
                                      });
                                    },
                                  ):Container(),
                                ],
                              ),
                            ),
                          ),
                          /*Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Card(
                            // margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            elevation: 2,
                            child: ListTile(
                              title: Text("Class category",
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
                                      child: Text("Use class category",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  ),
                                  Switch(
                                      value: _useClassCategory,
                                      activeColor: MyColors.primaryColor,
                                      onChanged: _useClassCategoryChanged)
                                ],
                              ),
                            ),
                          ),
                        ),*/
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text("Number of terms",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.remove_circle,
                                          color: MyColors.primaryColor,),
                                            onPressed: (){
                                              if(_numberOfTerms>0)
                                                _profileBloc.add(ChangeNumberOfTermsEvent(--_numberOfTerms));
                                            }),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Text(_numberOfTerms.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.normal)),
                                          ),
                                        ),
                                        IconButton(icon: Icon(Icons.add_circle,
                                          color: MyColors.primaryColor,),
                                            onPressed: (){
                                              if(_numberOfTerms<10)
                                                _profileBloc.add(ChangeNumberOfTermsEvent(++_numberOfTerms));
                                            }),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text("Maximum number of term in school",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text("Cumulative result",
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
                                        child: Text("Use cumulative result",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal)),
                                      ),
                                    ),
                                    Switch(
                                        value: _useCumulative,
                                        activeColor: MyColors.primaryColor,
                                        onChanged: _useCumulativeChanges)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text("Use signature on results",
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
                                        child: Text("Use teacher's signature on results",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal)),
                                      ),
                                    ),
                                    Switch(
                                        value: _useOfSignatureOnResults,
                                        activeColor: MyColors.primaryColor,
                                        onChanged: _useOfSignatureOnResultsChanges)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Number of cumulative test",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MyColors.primaryColor,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(icon: Icon(Icons.remove_circle,
                                              color: MyColors.primaryColor,),
                                                onPressed: (){
                                                  if(_numberOfCumulativeTest>0){
                                                    _scoreLimits.removeAt(0);

                                                    int totalTestScore=0;
                                                    for(int i=0; i<_scoreLimits.length-1; i++){
                                                      totalTestScore+=int.parse(_scoreLimits[i]);
                                                    }
                                                    if((100-totalTestScore)<=100){
                                                      _scoreLimits.last='${100-totalTestScore}';
                                                      _profileBloc.add(ChangeNumberOfCumulativeTestEvent(--_numberOfCumulativeTest));
                                                    }else{
                                                      showToast(message: 'Exam score cant\'n be more than 100');
                                                    }
                                                  }
                                                }),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Text(_numberOfCumulativeTest.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal)),
                                              ),
                                            ),
                                            IconButton(icon: Icon(Icons.add_circle,
                                              color: MyColors.primaryColor,),
                                                onPressed: (){
                                                  if(_numberOfCumulativeTest<10)
                                                    showModalInputDialog(context: context, title: 'Add Score Limit', value: '', textInputType: TextInputType.number)
                                                        .then((value){
                                                      if(value!=null){
                                                        List<String> newScoreLimits=List();
                                                        newScoreLimits.add(value);
                                                        newScoreLimits.addAll(_scoreLimits);
                                                        int totalTestScore=0;
                                                        for(int i=0; i<newScoreLimits.length-1; i++){
                                                          totalTestScore+=int.parse(newScoreLimits[i]);
                                                        }
                                                        if((100-totalTestScore)>=30){
                                                          newScoreLimits.last='${100-totalTestScore}';

                                                          _scoreLimits=newScoreLimits;
                                                          _profileBloc.add(ChangeNumberOfCumulativeTestEvent(++_numberOfCumulativeTest));
                                                        }else{
                                                          showToast(message: 'Exam score cant\'n be less than 30');
                                                        }
                                                      }
                                                    });
                                                }),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text("Maximum number of cumulative test in school",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.black87,
                                  ),
                                  ListTile(
                                    title: Text("Score Limits",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MyColors.primaryColor,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: _buildScoreLimitsList(context, _scoreLimits),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text("Result Comment",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        new Radio(
                                          value: 'individually',
                                          groupValue: _resultComment,
                                          onChanged: _resultCommentChanges,
                                        ),
                                        new Text(
                                          'Individually',
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                        new Radio(
                                          value: 'average',
                                          groupValue: _resultComment,
                                          onChanged: _resultCommentChanges,
                                        ),
                                        new Text(
                                          'Average',
                                          style: new TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text("Set result comments by $_resultComment",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Behavioural skill(s)",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MyColors.primaryColor,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: _buildBehaviouralSkillList(context, _behaviouralSkills),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.remove_circle,
                                        color: MyColors.primaryColor,),
                                          onPressed: (){
                                            _profileBloc.add(RemoveBehaviouralSkillsEvent(_behaviouralSkills.length));
                                          }),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(_behaviouralSkills.length.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal)),
                                        ),
                                      ),
                                      IconButton(icon: Icon(Icons.add_circle,
                                        color: MyColors.primaryColor,),
                                          onPressed: (){
                                            showModalInputDialog(context: context, title: 'Add Behavioural Skill', value: '', textInputType: TextInputType.text)
                                                .then((value){
                                              if(value!=null)
                                                _profileBloc.add(AddBehaviouralSkillsEvent(value));
                                            });
                                          }),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Add or Remove Behavioural skill",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Trait rating(s)",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MyColors.primaryColor,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text('Traits',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold)),
                                                ),
                                                Expanded(
                                                  child: Text('Ratings',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold)),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.black54,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: _buildTraitRatingsList(context, _traits, _traitRatings),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.remove_circle,
                                        color: MyColors.primaryColor,),
                                          onPressed: (){
                                            _profileBloc.add(RemoveTraitRatingEvent(_traitRatings.length));
                                          }),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(_traits.length.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal)),
                                        ),
                                      ),
                                      IconButton(icon: Icon(Icons.add_circle,
                                        color: MyColors.primaryColor,),
                                          onPressed: (){
                                            showTraitRatingInputDialog(context: context, title: "Add Trait Rating", trait: '', rating: '').then((value){
                                              if(value!=null){
                                                _profileBloc.add(AddTraitRatingEvent(value['trait'], value['rating']));
                                              }
                                            });
                                          }),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Add or Remove Trait rating",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              // margin: EdgeInsets.zero,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text("Grading system",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text("School grading system setup",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal)),
                                ),
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewSchoolGrades()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
          )),
    );
  }

  _buildScoreLimitsList(BuildContext context, List<String> scoreLimits) {
    List<Widget> choices = List();
    int _counter=0;
    scoreLimits.forEach((item) {
      int _position=_counter;
      _counter++;
      choices.add(Container(
          padding: const EdgeInsets.all(0.0),
          child:Column(
            children: <Widget>[
              ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text((_counter!=scoreLimits.length)?"Test $_counter:":"Exam:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal)),
                    ),
                    Expanded(
                      child: Text(item,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
                onTap: (){
                  if(_position!=scoreLimits.length-1)
                    showModalInputDialog(context: context, title: 'Change Score Limit', value: item, textInputType: TextInputType.number)
                        .then((value){
                      if(value!=null){
                        scoreLimits[_position] = value;
                        int totalTestScore=0;
                        for(int i=0; i<scoreLimits.length-1; i++){
                          totalTestScore+=int.parse(scoreLimits[i]);
                        }
                        if((100-totalTestScore)>=30){
                          _scoreLimits.last='${100-totalTestScore}';
                          _profileBloc.add(ChangeScoreLimitEvent(value, _position));
                        }else{
                          showToast(message: 'Exam score cant\'n be less than 30');
                        }
                      }
                    });
                },
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          )
      ));
    });    return choices;
  }


  _buildTraitRatingsList(BuildContext context, List<String> traits, List<String> ratings) {
    List<Widget> choices = List();
    int _counter=0;
    traits.forEach((item) {
      int _position=_counter;
      _counter++;
      choices.add(Container(
          padding: const EdgeInsets.all(0.0),
          child:Column(
            children: <Widget>[
              ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(item,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ),
                    Expanded(
                      child: Text(ratings[_position],
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
                onTap: (){
                  showTraitRatingInputDialog(context: context, title: "Change Trait Rating", trait: traits[_position], rating: ratings[_position]).then((value){
                    if(value!=null){
                      _profileBloc.add(ChangeTraitRatingEvent(value['trait'], value['rating'], _position));
                    }
                  });
                },
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          )
      ));
    });    return choices;
  }

  _buildBehaviouralSkillList(BuildContext context, List<String> behaviouralSkills) {
    List<Widget> choices = List();
    int _counter=0;
    behaviouralSkills.forEach((item) {
      int _position=_counter;
      _counter++;
      choices.add(Container(
          padding: const EdgeInsets.all(0.0),
          child:Column(
            children: <Widget>[
              ListTile(
                title: Text(toSentenceCase(item),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal)),
                onTap: (){
                  showModalInputDialog(context: context, title: 'Change Behavioural Skill', value: item, textInputType: TextInputType.text)
                      .then((value){
                    if(value!=null)
                      _profileBloc.add(ChangeBehaviouralSkillEvent(value, _position));
                  });
                },
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          )
      ));
    });    return choices;
  }

  Future<String>  showModalInputDialog({context, title, String value, TextInputType textInputType}) async{
    final _textController = TextEditingController();
    _textController.text=value;
    final _formKey = GlobalKey<FormState>();
    final data=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title, style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold),),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _textController,
                keyboardType: textInputType,
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a $title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25.0),
                        ),
                        borderSide: BorderSide(width: 0.5)
                    ),
                    prefixIcon:
                    Icon(Icons.label, color: MyColors.primaryColor),
                    labelText: title,
                    labelStyle: new TextStyle(color: Colors.grey[800]),
                    filled: true,
                    fillColor: Colors.white70),
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                textColor: MyColors.primaryColor,
                color: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Cancel",
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              FlatButton(
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
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Ok",
                      style: TextStyle(fontSize: 20)),
                ),
              )
            ],
          );
        });
    return data;
  }

  Future<Map<String, String>>  showTraitRatingInputDialog({context, title, String trait, String rating}) async{
    final _traitController = TextEditingController();
    final _ratingController = TextEditingController();
    _traitController.text=trait;
    _ratingController.text=rating;
    final _formKey = GlobalKey<FormState>();
    final data=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title, style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold),),
            content: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _traitController,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.start,
                      autofocus: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a trait';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(25.0),
                              ),
                              borderSide: BorderSide(width: 0.5)
                          ),
                          labelText: 'Trait',
                          labelStyle: new TextStyle(color: Colors.grey[800]),
                          filled: true,
                          fillColor: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextFormField(
                        controller: _ratingController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a rating';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(25.0),
                                ),
                                borderSide: BorderSide(width: 0.5)
                            ),
                            labelText: 'Rating',
                            labelStyle: new TextStyle(color: Colors.grey[800]),
                            filled: true,
                            fillColor: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                textColor: MyColors.primaryColor,
                color: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Cancel",
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  if(_formKey.currentState.validate()){
                    Navigator.pop(context,{'trait': _traitController.text, 'rating': _ratingController.text});
                  }
                },
                textColor: Colors.white,
                color: MyColors.primaryColor,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Ok",
                      style: TextStyle(fontSize: 20)),
                ),
              )
            ],
          );
        });
    return data;
  }

  void _resultCommentChanges(String value) {
    _profileBloc.add(ChangeResultCommentTypeEvent(value));
  }

  void _useCumulativeChanges(bool value){
    _profileBloc.add(ChangeUseCumulativeEvent(value));
  }


  void _useOfSignatureOnResultsChanges(bool value){
    _profileBloc.add(ChangeUseOfSignatureOnResultsEvent(value));
  }

  void _useCustomAdmissionNumChanged(bool value){
    _profileBloc.add(ChangeUseCustomAdmissionNumEvent(value));
  }

  void _useClassCategoryChanged(bool value){
    _profileBloc.add(ChangeUseClassCategoryEvent(value));
  }

  Future<bool> _showModalAlertDialog(context) async{
    final data=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.info),
                ),
                Text('System message'),
              ],
            ),
            content: Text('Save changes before exiting?'),
            actions: [
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                textColor: MyColors.primaryColor,
                color: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Exit",
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                textColor: MyColors.primaryColor,
                color: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Cancel",
                      style: TextStyle(fontSize: 20)),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context, false);
                },
                textColor: Colors.white,
                color: MyColors.primaryColor,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: const Text("Ok",
                      style: TextStyle(fontSize: 20)),
                ),
              )
            ],
          );
        });
    return data;
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_madeChanges) {
      print("onwill goback");
      _showModalAlertDialog(context).then((value){
        if(value!=null){
          if(!value){
            _profileBloc.add(UpdateSchoolSettingsEvent(school.id, school.poBox, school.preferredCurrencyId, _resultComment, _traits, _traitRatings, _numberOfTerms.toString(), _initialAdmissionNumber, _numberOfCumulativeTest.toString(), _scoreLimits, _behaviouralSkills, _useCumulative?'yes':'no', _useCustomAdmissionNum?'yes':'no', _useClassCategory?'yes':'no', _useOfSignatureOnResults?'yes':'no'));
          }else{
            Navigator.pop(context);
          }
        }
        return Future.value(value);
      });

    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }
}

