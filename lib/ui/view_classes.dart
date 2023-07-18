import 'package:flutter/material.dart';
import 'package:school_pal/blocs/view_classes/classes.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_classes_request.dart';
import 'package:school_pal/requests/posts/add_edit_delete_class_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/view_class_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewClasses extends StatelessWidget {
  final bool firstTimeLogin;
  ViewClasses({this.firstTimeLogin});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClassesBloc(viewRepository: ViewClassesRequest(), addEditClassRepository: AddEditClassRequests()),
      child: ViewClassesPage(firstTimeLogin),
    );
  }
}

// ignore: must_be_immutable
class ViewClassesPage extends StatelessWidget {
  final bool firstTimeLogin;
  ViewClassesPage(this.firstTimeLogin);

  ClassesBloc _classesBloc;
  List<Classes> _classes;
  List<String> _classLabel = new List();
  void _viewClasses() async {
    _classesBloc.add(ViewClassesEvent(await getApiToken()));

  }

  void _firstTimeLoginActions(BuildContext context){
    Future.delayed(const Duration(milliseconds: 500), () {
      if(firstTimeLogin){
        showCreateOrEditClassModalDialog(context: context, type: "Add").then((value){
          if(value!=null)
            _classesBloc.add(AddClassEvent(value['level'], value['category'], value['label']));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _classesBloc = BlocProvider.of<ClassesBloc>(context);
    final RefreshController _refreshController = RefreshController();
    _viewClasses();
    _firstTimeLoginActions(context);

    return WillPopScope(
      onWillPop: () =>_popNavigator(context, !firstTimeLogin),
      child: Scaffold(
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
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text("Classes Categorized")),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text("Classes Categorized"),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child: Center(
                            child: SvgPicture.asset("lib/assets/images/classes.svg")
                        ),
                      )),
                ),
                _labelGrid(context)
              ],
            )),

        floatingActionButton: FloatingActionButton.extended(
          heroTag: "Add class",
          onPressed: () {
            showCreateOrEditClassModalDialog(context: context, type: "Add").then((value){
              if(value!=null)
              _classesBloc.add(AddClassEvent(value['level'], value['category'], value['label']));
            });
          },
          label: Text('Class'),
          icon: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _labelGrid(context) {
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
        } else if (state is ClassesLoaded) {
          Scaffold.of(context).removeCurrentSnackBar();
          _classes = state.classes;
          for (var labels in state.classes) {
            if (!_classLabel.contains(labels.label)) {
              _classLabel.add(labels.label);
            }
          }
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
        }

      },
      child: BlocBuilder<ClassesBloc, ClassesStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is ClassesInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return (_classes.isNotEmpty) ?_buildLoadedScreen(context, _classes) :buildLoadingScreen();
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is ClassesLoaded) {
            return _buildLoadedScreen(context, state.classes);
          }  else if (state is ViewError) {
            try{
              return (_classes.isNotEmpty) ?_buildLoadedScreen(context, _classes) :buildNODataScreen();
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return (_classes.isNotEmpty) ?_buildLoadedScreen(context, _classes) :buildNetworkErrorScreen();
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return (_classes.isNotEmpty) ?_buildLoadedScreen(context, _classes) :buildInitialScreen();
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
              onTap: () => _viewClasses(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Classes> classes) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildClassCategory(context, _classLabel, index);
      }, childCount: _classLabel.length),
    );
  }

  Widget _buildClassCategory(
      BuildContext context, List<String> classes, int index) {
    return Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: RaisedButton(
        onPressed: () {
          final categoryClassesList = _classes
              .where((p) => (p.label.contains(classes[index])))
              .toList();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewClassesDetailed(classes: categoryClassesList, classLabel: classes[index])),
          );
        },
        color:
            (index + 1 < 5) ? Colors.pink[200 * (index + 1 % 9)] : Colors.pink,
        padding: const EdgeInsets.all(0.0),
        shape: CircleBorder(
          side: BorderSide(width: 5.0, style: BorderStyle.solid, color: Colors.white),
         // borderRadius: new BorderRadius.circular(50.0),
        ),
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(classes[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      )),
    ));
  }

  Future<bool> _popNavigator(BuildContext context, bool closeable) async {
    if (closeable) {
      print("onwill goback");
      return Future.value(true);
    } else {
      print("onwillNot goback");
      Navigator.pop(context, (_classes!=null&&_classes.isNotEmpty));
      return Future.value(false);
    }
  }

}
