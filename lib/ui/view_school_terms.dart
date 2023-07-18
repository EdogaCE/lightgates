import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/school/school.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_school_term_requests.dart';
import 'package:school_pal/requests/posts/add_edit_term_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/activate_term_dialog.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'general.dart';
import 'package:reorderables/reorderables.dart';

class ViewSchoolTerms extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSchoolTerms({this.firstTimeLogin});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SchoolBloc(viewSchoolTermRepository: ViewSchoolTermRequest(), addEditTermRepository: AddEditTermRequests()),
      child: ViewSchoolTermsPage(firstTimeLogin),
    );
  }
}

// ignore: must_be_immutable
class ViewSchoolTermsPage extends StatelessWidget {
  final bool firstTimeLogin;
  ViewSchoolTermsPage(this.firstTimeLogin);

  static SchoolBloc _schoolBloc;
  List<Terms> _schoolTerms;
  static void viewSchoolTerms() async {
    _schoolBloc.add(ViewTermsEvent(await getApiToken()));
  }

  bool completedFirstTimeLoginSetup=false;
  void _firstTimeLoginActions(BuildContext context){
    Future.delayed(const Duration(milliseconds: 500), () {
      if(firstTimeLogin){
        showAddOREditModalDialog(context: context, type: "Add").then((value){
          if(value!=null){
            _schoolBloc.add(AddTermEvent(value));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _schoolBloc = BlocProvider.of<SchoolBloc>(context);
    final RefreshController _refreshController = RefreshController();
    viewSchoolTerms();
    _firstTimeLoginActions(context);

    return WillPopScope(
      onWillPop: () =>_popNavigator(context, !firstTimeLogin),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              viewSchoolTerms();
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
                              delegate: CustomSearchDelegate(_schoolTerms));
                        })
                  ],
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text("Class Levels")),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text("School Terms"),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Center(
                              child: SvgPicture.asset("lib/assets/images/levels.svg")),
                        ),
                      )),
                ),
                _termsGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton(
          heroTag: "Add term",
          onPressed: () {
            showAddOREditModalDialog(context: context, type: "Add").then((value){
              if(value!=null){
                _schoolBloc.add(AddTermEvent(value));
              }
            });
          },
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _termsGrid(context) {
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
        }else if (state is ActivateError) {
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
        } else if (state is Processing) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator(state.message),
            ),
          );
        } else if (state is TermsLoaded) {
          Scaffold.of(context).removeCurrentSnackBar();
          _schoolTerms = state.terms;
        } else if (state is TermActivated) {
          Scaffold.of(context).removeCurrentSnackBar();
          _schoolTerms = state.terms;
          if(firstTimeLogin){
            completedFirstTimeLoginSetup=true;
          }
        }else if (state is TermAdded) {
          _schoolTerms = state.terms;
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Term was created successfully', textAlign: TextAlign.center),
              ),
            );
          showModalAlertOptionDialog(context: context, title: 'Activate Term', message: 'Do you wish to activate ${state.terms.last.term}', buttonYesText: 'Yes', buttonNoText: 'No').then((value){
            if(value!=null){
              if(value)
                _showActivateTermModalDialog(context: context, id: state.terms.last.id);
            }
          });

        }else if (state is TermUpdated) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          viewSchoolTerms();
        }else if(state is TermReordered){
          Terms terms=_schoolTerms[state.oldIndex];
          _schoolTerms.removeAt(state.oldIndex);
          _schoolTerms.insert(state.newIndex, terms);
          _schoolBloc.add(RearrangeTermEvent(_reorderedIds()));
        }
      },
      child: BlocBuilder<SchoolBloc, SchoolStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is SchoolInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _schoolTerms);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is TermsLoaded) {
            return _buildLoadedScreen(context, state.terms);
          }else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _schoolTerms);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          } else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _schoolTerms);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _schoolTerms);
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
          onTap: () => viewSchoolTerms(),
        ),
      ),
    ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Terms> terms) {
    return ReorderableSliverList(
         delegate: ReorderableSliverChildBuilderDelegate(
          (BuildContext context, int index) => _buildSchoolTerms(context, terms, index),
         childCount: terms.length),
      onReorder: _onReorder,
    );
    /*return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildSchoolTerms(context, terms, index);
      }, childCount: terms.length),
    );*/
  }

  void _onReorder(int oldIndex, int newIndex) {
    _schoolBloc.add(ReorderTermEvent(oldIndex, newIndex));
  }

  List<String> _reorderedIds(){
    List<String> ids=List();
    _schoolTerms.forEach((term) {
      ids.add(term.id);
      //print(term.term);
    });
    return ids;
  }

  static void showEditOrActivateModalBottomSheet(
      {BuildContext context, Terms terms, String id}) {
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
                    Icons.update,
                    color: MyColors.primaryColor,
                  ),
                  title: new Text('Activate'),
                  onTap: () {
                    Navigator.pop(context);
                    _showActivateTermModalDialog(context: context, id: id);
                  },
                ),
                ListTile(
                    leading: new Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                    title: new Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      showAddOREditModalDialog(context: context, type: "Edit", terms: terms).then((value){
                        if(value!=null){
                          _schoolBloc.add(UpdateTermEvent(terms.id, value));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }

  static Future<String> showAddOREditModalDialog(
      {BuildContext context, String type, Terms terms}) async{
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    if (type == 'Edit') _textController.text = terms.term;
    final data=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('$type Term',
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
                                return 'Please enter term.';
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
                                labelText: "Term",
                                labelStyle:
                                    new TextStyle(color: Colors.grey[800]),
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
                              if (_formKey.currentState.validate()) {
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

  static void _showActivateTermModalDialog({BuildContext context, id}) async {
    final data = await showDialog<List<String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: ActivateTermDialog(),
          );
        });
    if (data != null) {
      //TODO: Activate term here
      print(data.toString());
      _schoolBloc.add(ActivateTermEvent(id, data[0], data[1], data[2]));
    }
  }

  Future<bool> _popNavigator(BuildContext context, bool closeable) async {
    if (closeable) {
      print("onwill goback");
      return Future.value(true);
    } else {
      print("onwillNot goback");
      Navigator.pop(context, completedFirstTimeLoginSetup);
      return Future.value(false);
    }
  }


}

Widget _buildSchoolTerms(BuildContext context, List<Terms> terms, int index) {
  return Card(
    // margin: EdgeInsets.zero,
    key: Key('$index'),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                  child: RaisedButton(
                    /*onLongPress: () {
                      ViewSchoolTermsPage.showEditOrActivateModalBottomSheet(
                          context: context,
                          terms: terms[index],
                          id: terms[index].id);
                    },*/
                    onPressed: () {
                      ViewSchoolTermsPage.showEditOrActivateModalBottomSheet(
                          context: context,
                          terms: terms[index],
                          id: terms[index].id);
                    },
                    color: Colors.blue,
                    padding: const EdgeInsets.all(0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          width: 5.0,
                          style: BorderStyle.solid,
                          color: (index + 1 < 5)
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
                          child: Text(terms[index].term.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                )),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(toSentenceCase(terms[index].status),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14,
                        color: (terms[index].status != 'active')
                            ? Colors.black54
                            : Colors.green,
                        fontWeight: FontWeight.normal)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Terms> terms;
  CustomSearchDelegate(this.terms);

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
          ? terms
          : terms
              .where((p) => p.term.toUpperCase().contains(query.toUpperCase()))
              .toList();

      return ReorderableListView(
          children: List.generate(
            suggestionList.length,
                (index) {
              return _buildSchoolTerms(context, suggestionList, index);
            },
          ).toList(),
          onReorder: (int oldIndex, int newIndex) {
            showToast(message: 'Sorry you can\'t rearrange while searching.');
          }
      );
      /*return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildSchoolTerms(context, suggestionList, index);
        },
      );*/
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
          ? terms
          : terms
              .where((p) => p.term.toUpperCase().contains(query.toUpperCase()))
              .toList();

      return ReorderableListView(
          children: List.generate(
            suggestionList.length,
                (index) {
              return _buildSchoolTerms(context, suggestionList, index);
            },
          ).toList(),
          onReorder: (int oldIndex, int newIndex) {
            showToast(message: 'Sorry you can\'t rearrange while searching.');
          }
      );

      /*return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: suggestionList.length,
        scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildSchoolTerms(context, suggestionList, index);
        },
      );*/
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
