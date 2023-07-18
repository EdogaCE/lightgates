import 'package:flutter/material.dart';
import 'package:school_pal/blocs/salary/salary_bloc.dart';
import 'package:school_pal/blocs/salary/salary_events.dart';
import 'package:school_pal/blocs/salary/salary_states.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_salary_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_salary_record.dart';
import 'package:school_pal/ui/view_teachers_salary.dart';
import 'package:school_pal/utils/system.dart';

class ViewSalaryRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SalaryBloc(viewSalaryRepository: ViewSalaryRequest()),
      child: ViewSalaryRecordPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewSalaryRecordPage extends StatelessWidget {
  static SalaryBloc _salaryBloc;
  List<SalaryRecord> _salaryRecord;
  static _viewSalaryRecords() async {
    _salaryBloc.add(ViewSalaryRecordEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _salaryBloc = BlocProvider.of<SalaryBloc>(context);
    _viewSalaryRecords();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewSalaryRecords();
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
                            delegate: CustomSearchDelegate(_salaryRecord));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('Salary Records'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child:  Center(
                          child: SvgPicture.asset("lib/assets/images/payment.svg")
                      ),
                    )),
              ),
              _buildSalaryRecord(context)
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Add record",
        onPressed: () {
          _navigateToSalaryEditScreen(context: context, event: 'Create');
        },
        label: Text('Create'),
        icon: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<SalaryBloc, SalaryStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is SalaryNetworkErr) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is SalaryViewError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is SalaryRecordLoaded) {
          _salaryRecord = state.salaryRecord;
        }
      },
      child: BlocBuilder<SalaryBloc, SalaryStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          //Todo: note builder returns widget
          if (state is SalaryInitial) {
            return buildInitialScreen();
          } else if (state is SalaryLoading) {
            try{
              return _buildLoadedScreen(context, _salaryRecord);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is SalaryRecordLoaded) {
            return _buildLoadedScreen(context, state.salaryRecord);
          } else if (state is SalaryViewError) {
            try{
              return _buildLoadedScreen(context, _salaryRecord);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is SalaryNetworkErr) {
            try{
              return _buildLoadedScreen(context, _salaryRecord);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _salaryRecord);
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
              onTap: () => _viewSalaryRecords(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<SalaryRecord> salaryRecord) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, salaryRecord, index);
      }, childCount: salaryRecord.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context, SalaryRecord salaryRecord}) {
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
                  child: Text(salaryRecord.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: new Icon(
                    Icons.view_agenda,
                    color: Colors.amber,
                  ),
                  title: new Text('View'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewTeachersSalary(salaryRecord: salaryRecord)),
                    );
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
                      _navigateToSalaryEditScreen(context: context, salaryRecord: salaryRecord, event: 'Update');
                    }),
              ],
            ),
          );
        });
  }

  static _navigateToSalaryEditScreen({BuildContext context, SalaryRecord salaryRecord, String event}) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateSalaryRecord(salaryRecord: salaryRecord, event: event)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      /* Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));*/

      //Refresh after update
      _viewSalaryRecords();
    }
  }

  static _navigateToViewTeachersScreen(BuildContext context, SalaryRecord salaryRecord, String from) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewTeachersSalary(salaryRecord: salaryRecord)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _viewSalaryRecords();
    }
  }

}

Widget _buildRow(BuildContext context, List<SalaryRecord> salaryRecord, int index) {
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(salaryRecord[index].frequency),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(salaryRecord[index].date,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(salaryRecord[index].title),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(salaryRecord[index].description),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(salaryRecord[index].terms.term),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: (salaryRecord[index].terms.status=='active')?Colors.green:Colors.black,
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(toSentenceCase(salaryRecord[index].sessions.sessionDate),
                              style: TextStyle(
                                  fontSize: 16,
                                  color:(salaryRecord[index].sessions.status=='active') ?Colors.green:Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            ViewSalaryRecordPage._navigateToViewTeachersScreen(context, salaryRecord[index], 'salary');
            // Add 9 lines from here...
          },
          onLongPress: (){
            ViewSalaryRecordPage.showOptionsModalBottomSheet(context: context, salaryRecord: salaryRecord[index]);
          },// ... to here.// ... to here.
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<SalaryRecord> salaryRecord;
  CustomSearchDelegate(this.salaryRecord);

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
          ? salaryRecord
          : salaryRecord
          .where((p) =>
      (p.frequency.contains(query)) || (p.title.contains(query)))
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
          ? salaryRecord
          : salaryRecord
          .where((p) =>
      (p.frequency.contains(query)) || (p.title.contains(query)))
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
