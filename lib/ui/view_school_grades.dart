import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/school/school.dart';
import 'package:school_pal/models/grade.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_school_grades_request.dart';
import 'package:school_pal/requests/posts/add_edit_grade_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewSchoolGrades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SchoolBloc(viewSchoolGradesRepository: ViewSchoolGradeRequest(), addEditGradeRepository: AddEditGradeRequests()),
      child: ViewViewSchoolGradesPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewViewSchoolGradesPage extends StatelessWidget {
  static SchoolBloc _schoolBloc;
  List<Grade> _schoolGrades;
  void _viewSchoolGrades() async {
    _schoolBloc.add(ViewGradesEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _schoolBloc = BlocProvider.of<SchoolBloc>(context);
    _viewSchoolGrades();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewSchoolGrades();
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(_schoolGrades));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text("Class Levels")),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text("School Grades"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Center(
                            child:
                            SvgPicture.asset("lib/assets/images/result2.svg")),
                      ),
                    )),
              ),
              _gradeGrid(context)
            ],
          )),
      floatingActionButton: FloatingActionButton(
        heroTag: "Add grade",
        onPressed: () {
          _showAddOREditModalDialog(context: context, grade: _schoolGrades, type: 'Add').then((value){
            if(value!=null){
              ViewViewSchoolGradesPage._schoolBloc.add(AddGradeEvent(value['grade'], value['startLimit'], value['endLimit'], value['remark']));
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _gradeGrid(context) {
    return BlocListener<SchoolBloc, SchoolStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is ViewError) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        }else if (state is GradesLoaded) {
          _schoolGrades = state.grades;
        } else if (state is Processing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator(state.message),
            ),
          );
        }else if(state is GradeAdded){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSchoolGrades();
        }else if(state is GradeUpdated){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSchoolGrades();
        }else if(state is GradeDeleted){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSchoolGrades();
        }else if(state is GradeRestored){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSchoolGrades();
        }
      },
      child: BlocBuilder<SchoolBloc, SchoolStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is SchoolInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _schoolGrades);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is GradesLoaded) {
            return _buildLoadedScreen(context, state.grades);
          }else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _schoolGrades);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          } else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _schoolGrades);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _schoolGrades);
            }on NoSuchMethodError{
              return buildInitialScreen();
            }

          }
        },
      ),
    );
  }

  Widget buildInitialScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Scaffold(),
          ),
        ));
  }

  Widget buildLoadingScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor:
                      new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                      backgroundColor: Colors.pink,
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget buildNODataScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              MyStrings.noData,
              height: 150.0,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }

  Widget buildNetworkErrorScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: SvgPicture.asset(
                MyStrings.networkError,
                height: 150.0,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => _viewSchoolGrades(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Grade> grades) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, grades, index);
      }, childCount: grades.length),
    );
  }
}

Widget _buildRow(BuildContext context, List<Grade> grade, int index) {
  return !grade[index].deleted?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: grade[index].deleted?Colors.red:Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 1,
        child: ListTile(
          title: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Container(
                  color: (index + 1 < 10)
                      ? Colors.pink[100 * (index + 1 % 9)]
                      : Colors.pink,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('${index+1}',
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
                    Container(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                        child:  Text('${toSentenceCase(grade[index].startLimit)}-${toSentenceCase(grade[index].endLimit)}',
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
                      child: Text('${toSentenceCase(grade[index].remark)} (${toSentenceCase(grade[index].grade)})',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            _showEditOrDeleteModalBottomSheet(context: context, grade: grade, index: index);
          },
          onLongPress: (){
            _showEditOrDeleteModalBottomSheet(context: context, grade: grade, index: index);
          },// ... to here.// ... to here.
        ),
      ),
    ),
  ):Container();
}

void _showEditOrDeleteModalBottomSheet({BuildContext context, List<Grade> grade, int index}) {
  showModalBottomSheet(
      context: context,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text('Options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  leading: new Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  title: new Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddOREditModalDialog(context: context, grade: grade, index: index, type: 'Edit').then((value){
                      if(value!=null){
                        ViewViewSchoolGradesPage._schoolBloc.add(UpdateGradeEvent(grade[index].id, value['grade'], value['startLimit'], value['endLimit'], value['remark']));
                      }
                    });
                  }),
              grade[index].deleted?ListTile(
                leading: new Icon(
                  Icons.restore,
                  color: Colors.blue,
                ),
                title: new Text('Restore'),
                onTap: () {
                  Navigator.pop(context);
                  ViewViewSchoolGradesPage._schoolBloc.add(RestoreGradeEvent(grade[index].id));
                },
              ) :ListTile(
                leading: new Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: new Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  showConfirmDeleteModalAlertDialog(context: context, title: 'Grade').then((value){
                    if(value!=null){
                      if(value)
                        ViewViewSchoolGradesPage._schoolBloc.add(DeleteGradeEvent(grade[index].id));
                    }
                  });
                },
              ),
            ],
          ),
        );
      });
}

Future<Map<String, String>> _showAddOREditModalDialog({BuildContext context, List<Grade> grade, int index, String type}) async{
  final _gradeController = TextEditingController();
  final _remarkController = TextEditingController();
  final _startLimitController = TextEditingController();
  final _endLimitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  if(type=='Edit'){
    _gradeController.text=grade[index].grade;
    _remarkController.text=grade[index].remark;
    _startLimitController.text=grade[index].startLimit;
    _endLimitController.text=grade[index].endLimit;
  }

  final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 450,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('$type Grade',
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
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _gradeController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter grade.';
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
                                    Icon(Icons.grade, color: MyColors.primaryColor),
                                    labelText: "Grade",
                                    labelStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 2.0),
                                      child: TextFormField(
                                        controller: _startLimitController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            showToast(message: 'Enter start limit.');
                                            return 'Enter start limit.';
                                          }
                                          if(int.parse(value)==int.parse(_endLimitController.text)){
                                            showToast(message: 'Can\'t be equal to end limit');
                                            return 'Can\'t be equal to end limit';
                                          }
                                          if(int.parse(value)>int.parse(_endLimitController.text)){
                                            showToast(message: 'Can\'t be greater than end limit');
                                            return 'Can\'t be greater than end limit';
                                          }
                                          /*try{
                                            if((type!='Edit')&&(int.parse(value)<=int.parse(grade[grade.length-1].endLimit))){
                                              showToast(message: 'Can\'t be less than previous end limit');
                                              return 'Can\'t be less than previous end limit';
                                            }
                                            if((type=='Edit')&&(int.parse(value)<=int.parse(grade[index+1].endLimit))){
                                              showToast(message: 'Can\'t be less than previous end limit');
                                              return 'Can\'t be less than previous end limit';
                                            }
                                          }on RangeError{
                                            return null;
                                          }*/
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
                                            Icon(Icons.arrow_right, color: MyColors.primaryColor),
                                            labelText: "From",
                                            labelStyle:
                                            new TextStyle(color: Colors.grey[800]),
                                            filled: true,
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: TextFormField(
                                        controller: _endLimitController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            showToast(message: 'Enter end limit');
                                            return 'Enter end limit.';
                                          }
                                          if(int.parse(value)>100){
                                            showToast(message: 'Can\'t be grater than 100');
                                            return 'Can\'t be grater than 100';
                                          }
                                          /*try{
                                            if((type=='Edit')&&(int.parse(value)>=int.parse(grade[index-1].startLimit))){
                                              showToast(message: 'Can\'t be greater than next start limit');
                                              return 'Can\'t be greater than next start limit';
                                            }
                                          }on RangeError{
                                            return null;
                                          }*/
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
                                            Icon(Icons.arrow_left, color: MyColors.primaryColor),
                                            labelText: "To",
                                            labelStyle:
                                            new TextStyle(color: Colors.grey[800]),
                                            filled: true,
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _remarkController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter remark.';
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
                                    labelText: "Remark",
                                    labelStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                          ],
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
                            if (_formKey.currentState.validate()) {
                              Navigator.pop(context, {'grade':_gradeController.text, 'startLimit':_startLimitController.text, 'endLimit':_endLimitController.text, 'remark':_remarkController.text});
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
                                left: 8.0,
                                top: 15.0,
                                right: 8.0,
                                bottom: 15.0),
                            child: const Text("Done",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
      });
  return data;
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Grade> grade;
  CustomSearchDelegate(this.grade);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    try {
      final suggestionList = query.isEmpty
          ? grade
          : grade
          .where((p) => (p.grade.contains(query)) || (p.remark.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, index);
          });
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    try {
      final suggestionList = query.isEmpty
          ? grade
          : grade
          .where((p) => (p.grade.contains(query)) || (p.remark.contains(query)))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context, suggestionList, index);
          });
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }
}

