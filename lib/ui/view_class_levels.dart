import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_classes/classes.dart';
import 'package:school_pal/models/class_levels.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_class_levels_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_level_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewClassLevels extends StatelessWidget {
  final bool firstTimeLogin;
  ViewClassLevels({this.firstTimeLogin});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClassesBloc(viewRepository: ViewClassLevelsRequest(),
              addEditClassLevelRepository: AddEditClassLevelRequests()),
      child: ViewClassLevelsPage(firstTimeLogin),
    );
  }
}

// ignore: must_be_immutable
class ViewClassLevelsPage extends StatelessWidget {
  final bool firstTimeLogin;
  ViewClassLevelsPage(this.firstTimeLogin);

  static ClassesBloc _classesBloc;
  List<ClassLevels> _classLevels;
  void _viewClassLevels() async {
    _classesBloc.add(ViewClassLevelsEvent(await getApiToken()));
  }

  void _firstTimeLoginActions(BuildContext context){
    Future.delayed(const Duration(milliseconds: 500), () {
      if(firstTimeLogin){
        showAddOREditModalDialog(context: context, type: "Add").then((value){
          if(value!=null){
            _classesBloc.add(AddClassLevelEvent(value));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _classesBloc = BlocProvider.of<ClassesBloc>(context);
    final RefreshController _refreshController = RefreshController();
    _viewClassLevels();
    _firstTimeLoginActions(context);

    return WillPopScope(
      onWillPop: () =>_popNavigator(context, !firstTimeLogin),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewClassLevels();
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
                              delegate: CustomSearchDelegate(_classLevels));
                        })
                  ],
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text("Class Levels")),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text("Class Levels"),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Center(
                              child: SvgPicture.asset("lib/assets/images/levels.svg")
                          ),
                        ),
                      )),
                ),
                _studentsGrid(context)
              ],
            )),
        /*floatingActionButton: FloatingActionButton(
          heroTag: "Add level",
          onPressed: () {
            showAddOREditModalDialog(context: context, type: "Add").then((value){
              if(value!=null){
                _classesBloc.add(AddClassLevelEvent(value));
              }
            });
          },
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),*/
      ),
    );
  }

  Widget _studentsGrid(context) {
    return BlocListener<ClassesBloc, ClassesStates>(
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
        } else if (state is ClassLevelsLoaded) {
          Scaffold.of(context).removeCurrentSnackBar();
          _classLevels = state.classLevels;
        }else if (state is Processing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator('Processing...'),
            ),
          );
        }else if (state is ClassLevelAdded) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewClassLevels();
        }else if (state is ClassLevelUpdated) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewClassLevels();
        }else if (state is ClassLevelDeleted) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewClassLevels();
        }
      },
      child: BlocBuilder<ClassesBloc, ClassesStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is ClassesInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _classLevels);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is ClassLevelsLoaded) {
            return _buildLoadedScreen(context, state.classLevels);
          }  else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _classLevels);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _classLevels);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _classLevels);
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
              onTap: () => _viewClassLevels(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(
      BuildContext context, List<ClassLevels> classLevels) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildLevel(context, classLevels, index);
      }, childCount: _classLevels.length),
    );
  }

  static Future<String> showAddOREditModalDialog({BuildContext context, String type, ClassLevels classLevels}) async{
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    if(type=='Edit')
      _textController.text=classLevels.level;
    final data=await showDialog<String>(
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
                        child: Text('$type Level',
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
                                return 'Please enter level.';
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
                                labelText: "Level",
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

  static void _showEditOrDeleteModalBottomSheet({BuildContext context, ClassLevels classLevels}) {
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
                      showAddOREditModalDialog(context: context, type: 'Edit', classLevels: classLevels)
                          .then((value){
                            if(value!=null){
                              _classesBloc.add(UpdateClassLevelEvent(classLevels.id, value));
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
                    showConfirmDeleteModalAlertDialog(context: context, title: "Level").then((value){
                      if(value!=null){
                        if(value)
                          _classesBloc.add(DeleteClassLevelEvent(classLevels.id));
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
      Navigator.pop(context, (_classLevels!=null&&_classLevels.isNotEmpty));
      return Future.value(false);
    }
  }

}


Widget _buildLevel(
    BuildContext context, List<ClassLevels> classLevels, int index) {
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
            ViewClassLevelsPage._showEditOrDeleteModalBottomSheet(context: context, classLevels: classLevels[index]);
          },
          onPressed: () {
            ViewClassLevelsPage._showEditOrDeleteModalBottomSheet(context: context, classLevels: classLevels[index]);
          },
          color: Colors.blue,
          padding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
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
                child: Text(classLevels[index].level.toUpperCase(),
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
  final List<ClassLevels> classLevels;
  CustomSearchDelegate(this.classLevels);

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
          ? classLevels
          : classLevels
          .where((p) =>
          p.level.toUpperCase().contains(query.toUpperCase()))
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
          return _buildLevel(context, suggestionList, index);
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
          ? classLevels
          : classLevels
          .where((p) =>
          p.level.toUpperCase().contains(query.toUpperCase()))
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
          return _buildLevel(context, suggestionList, index);
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


