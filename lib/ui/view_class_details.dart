import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_classes/classes.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/get/view_classes_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_class_dialog.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'modals.dart';


class ViewClassesDetailed extends StatelessWidget {
  final List<Classes> classes;
  final String classLabel;
  ViewClassesDetailed({this.classes, this.classLabel});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClassesBloc(viewRepository: ViewClassesRequest(), addEditClassRepository: AddEditClassRequests()),
      child: ViewClassesDetailedPage(classes, classLabel),
    );
  }
}

// ignore: must_be_immutable
class ViewClassesDetailedPage extends StatelessWidget {
  List<Classes> _classes;
  final String classLabel;
  ViewClassesDetailedPage(this._classes, this.classLabel);

  static ClassesBloc _classesBloc;
  void _viewClasses() async {
    _classesBloc.add(ViewClassesEvent(await getApiToken()));

  }

  @override
  Widget build(BuildContext context) {
    _classesBloc = BlocProvider.of<ClassesBloc>(context);
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewClasses();
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
                            delegate: CustomSearchDelegate(_classes));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text(_classes[0].label.toUpperCase())),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(_classes[0].label.toUpperCase()),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/classes.svg")
                      ),
                    )),
              ),
              BlocListener<ClassesBloc, ClassesStates>(
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
                  } else if (state is ClassesLoaded) {
                    Scaffold.of(context).removeCurrentSnackBar();
                    _classes = state.classes.where((p) => (p.label.contains(classLabel))).toList();

                  } else if (state is Processing) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator('Processing...'),
                      ),
                    );
                  } if (state is ClassAdded) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    _viewClasses();
                  } if (state is ClassUpdated) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    _viewClasses();
                  } if (state is ClassDeleted) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    _viewClasses();
                  }
                },
                child: BlocBuilder<ClassesBloc, ClassesStates>(
                  builder: (context, state) {
                    //Todo: note builder returns widget
                    return _buildLoadedScreen(context, _classes);
                  }
                ),
              )

            ],
          )),
      floatingActionButton: FloatingActionButton(
        heroTag: "Add classes",
        onPressed: () {
          showCreateOrEditClassModalDialog(context: context, type: "Add").then((value){
            if(value!=null){
              _classesBloc.add(AddClassEvent(value['level'], value['category'], value['label']));
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context, List<Classes> classes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, classes, index);
      }, childCount: classes.length),
    );
  }

  static void _showEditOrDeleteClassBottomSheet({BuildContext context, Classes classes}) {
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
                      showCreateOrEditClassModalDialog(context: context, type: "Edit", classes: classes).then((value){
                        if(value!=null){
                          _classesBloc.add(UpdateClassEvent(classes.id, value['level'], value['category'], value['label']));
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
                    showConfirmDeleteModalAlertDialog(context: context, title: 'Class').then((value){
                      if(value!=null){
                        if(value)
                          _classesBloc.add(DeleteClassEvent(classes.id));
                      }
                    });
                  },
                ),*/
              ],
            ),
          );
        });
  }

}

Widget _buildRow(BuildContext context, List<Classes> classes, int index) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: Text('${toSentenceCase(classes[index].label)} ${toSentenceCase(classes[index].category)} (${toSentenceCase(classes[index].level)})',
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Text('${classes[index].numberOfTeachers} Teachers',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text('${classes[index].numberOfStudents} Students',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          onLongPress: (){
            ViewClassesDetailedPage._showEditOrDeleteClassBottomSheet(context: context, classes: classes[index]);
          },
          onTap: () {
            ViewClassesDetailedPage._showEditOrDeleteClassBottomSheet(context: context, classes: classes[index]);
          }, // ... to here.// ... to here.
        ),
      ),
    ),
  );
}


Future<Map<String, String>> showCreateOrEditClassModalDialog({BuildContext context, Classes classes, String type}) async{
  final data=await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: CreateClassDialog(classes, type),
        );
      });
  return data;
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Classes> classes;
  CustomSearchDelegate(this.classes);

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
          ? classes
          : classes
          .where((p) =>
      (p.label.toLowerCase().contains(query.toLowerCase()))
          || (p.category.toLowerCase().contains(query.toLowerCase()))
          || (p.level.toLowerCase().contains(query.toLowerCase())) )
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
          ? classes
          : classes
          .where((p) =>
      (p.label.toLowerCase().contains(query.toLowerCase()))
          || (p.category.toLowerCase().contains(query.toLowerCase()))
          || (p.level.toLowerCase().contains(query.toLowerCase())) )
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
