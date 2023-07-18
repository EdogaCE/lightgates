import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/subjects/subjects.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_subjects_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_subject_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewSubjects extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSubjects({this.firstTimeLogin});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SubjectsBloc(viewSubjectsRepository: ViewSubjectsRequest(), addEditSubjectRepository: AddEditSubjectRequests()),
      child: ViewSubjectsPage(firstTimeLogin),
    );
  }
}

// ignore: must_be_immutable
class ViewSubjectsPage extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSubjectsPage(this.firstTimeLogin);

  static SubjectsBloc _subjectsBloc;
  List<Subjects> _subjects;
  void _viewSubjects() async {
    _subjectsBloc.add(ViewSubjectsEvent(await getApiToken()));
  }

  void _firstTimeLoginActions(BuildContext context){
    Future.delayed(const Duration(milliseconds: 500), () {
      if(firstTimeLogin){
        showAddOREditModalDialog(context: context, type: "Add").then((value){
          if(value!=null){
            _subjectsBloc.add(AddSubjectEvent(value));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _subjectsBloc = BlocProvider.of<SubjectsBloc>(context);
    final RefreshController _refreshController = RefreshController();
    _viewSubjects();
    _firstTimeLoginActions(context);

    return WillPopScope(
      onWillPop: () =>_popNavigator(context, !firstTimeLogin),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewSubjects();
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
                              delegate: CustomSearchDelegate(_subjects));
                        })
                  ],
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text("Subjects")),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text("Subjects"),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child: Center(
                            child: SvgPicture.asset("lib/assets/images/subjects.svg")
                        ),
                      )),
                ),
                _studentsGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton(
          heroTag: "Add subject",
          onPressed: () {
            showAddOREditModalDialog(context: context, type: "Add").then((value){
              if(value!=null){
                _subjectsBloc.add(AddSubjectEvent(value));
              }
            });
          },
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _studentsGrid(context) {
    return BlocListener<SubjectsBloc, SubjectsStates>(
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
        } else if (state is SubjectsLoaded) {
          _subjects = state.subjects;
        }else if (state is SubjectAdded) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSubjects();
        }else if (state is SubjectEdited) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSubjects();
        }else if (state is SubjectsProcessing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator('Processing...'),
            ),
          );
        }else if (state is SubjectDeleted) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewSubjects();
        }
      },
      child: BlocBuilder<SubjectsBloc, SubjectsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is SubjectsInitial) {
            return buildInitialScreen();
          } else if (state is SubjectsLoading) {
            try{
              return _buildLoadedScreen(context, _subjects);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is SubjectsLoaded) {
            return _buildLoadedScreen(context, state.subjects);
          } else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _subjects);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _subjects);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _subjects);
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
                      valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
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
              onTap: () => _viewSubjects(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(
      BuildContext context, List<Subjects> subjects) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildSubjects(context, subjects, index);
      }, childCount: _subjects.length),
    );
  }

  static Future<String> showAddOREditModalDialog({BuildContext context, String type, String level}) async{
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    if(type=='Edit')
      _textController.text=level;
    final data= await showDialog(
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
                        child: Text('$type Subject',
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
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter subject.';
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
                                labelText: "Subject",
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
                              child: const Text("Done",
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

  static void _showEditOrDeleteModalBottomSheet({BuildContext context, String level, String id}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                      showAddOREditModalDialog(context: context, type: 'Edit', level: level).then((value){
                        if(value!=null){
                          _subjectsBloc.add(EditSubjectEvent(id, value));
                        }
                      });
                    }),
                /*ListTile(
                  leading: new Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: new Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    showConfirmDeleteModalAlertDialog(context: context, title: "Subject").then((value){
                      if(value!=null){
                        if(value)
                          _subjectsBloc.add(DeleteSubjectEvent(id));
                      }
                    });
                  },
                ),*/
              ],
            ),
          );
        });
  }

  Future<bool> _popNavigator(BuildContext context, bool closeable) async {
    if (closeable) {
      print("onwill goback");
      return Future.value(true);
    } else {
      print("onwillNot goback");
      Navigator.pop(context, (_subjects!=null&&_subjects.isNotEmpty));
      return Future.value(false);
    }
  }

}


Widget _buildSubjects(
    BuildContext context, List<Subjects> subjects, int index) {
  return Card(
    // margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: RaisedButton(
          onLongPress: (){
            ViewSubjectsPage._showEditOrDeleteModalBottomSheet(context: context, level: subjects[index].title, id:  subjects[index].id);
          },
          onPressed: () {
            ViewSubjectsPage._showEditOrDeleteModalBottomSheet(context: context, level: subjects[index].title, id:  subjects[index].id);
          },
          color: Colors.blue,
          padding: const EdgeInsets.all(0.0),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            side: BorderSide(
                width: 5.0, style: BorderStyle.solid, color:(index + 1 < 5)
                ? Colors.pink[200 * (index + 1 % 9)]
                : Colors.pink),
            // borderRadius: new BorderRadius.circular(50.0),
          ),
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(subjects[index].title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Subjects> subjects;
  CustomSearchDelegate(this.subjects);

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
          ? subjects
          : subjects
          .where((p) =>
          p.title.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildSubjects(context, suggestionList, index);
        },
      );
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
          ? subjects
          : subjects
          .where((p) =>
          p.title.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildSubjects(context, suggestionList, index);
        },
      );
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


