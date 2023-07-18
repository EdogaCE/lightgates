import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_fees_requests.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:intl/intl.dart';
import 'package:school_pal/ui/student_details.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ViewFeesPayments extends StatelessWidget {
  final FeesRecord feesRecord;
  ViewFeesPayments({this.feesRecord});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeesBloc(viewFeesRepository: ViewFeesRequest(), createFeesRepository: CreateFeesRequests()),
      child: ViewFeesPaymentsPage(feesRecord),
    );
  }
}

// ignore: must_be_immutable
class ViewFeesPaymentsPage extends StatelessWidget {
  FeesRecord feesRecord;
  ViewFeesPaymentsPage(this.feesRecord);
  static FeesBloc _feesBloc;
  List<Students> _students;
  String filter='All Payments', dateFrom, dateTo;

  _viewFeesPayments() async {
    switch(filter){
      case 'All Payments':{
        _feesBloc.add(ViewFeesPaymentsEvent(await getApiToken(), feesRecord.id));
        break;
      }
      case 'Outstanding Payments':{
        _feesBloc.add(ViewOutstandingFeesPaymentsEvent(await getApiToken(), feesRecord.id));
        break;
      }
      case 'Filter By Date':{
        _feesBloc.add(ViewFeesPaymentsByDateEvent(await getApiToken(), feesRecord.id, dateFrom, dateTo));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _viewFeesPayments();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewFeesPayments();
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  DropdownButton<String>(
                    icon: Icon( Icons.more_vert, color: Colors.white,),
                    items: <String>['All Payments', 'Outstanding Payments', 'Filter By Date', 'Search'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      filter=value;
                      if(value=='Filter By Date'){
                       showFilterByDateModalBottomSheet(context: context, feesRecord: feesRecord);
                      }else if(value=='Search'){
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(_students));
                      }else{
                        _viewFeesPayments();
                      }
                    },
                  )
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(feesRecord.title),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset(
                              "lib/assets/images/payment.svg")
                      ),
                    )),
              ),
              _buildSalaryRecord(context)
            ],
          )),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<FeesBloc, FeesStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is FeesNetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is FeesViewError) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is FeesPaymentsLoaded) {
          _students = state.students;
        }else if (state is Processing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if (state is StudentDeactivated) {
          _viewFeesPayments();
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }
      },
      child: BlocBuilder<FeesBloc, FeesStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          //Todo: note builder returns widget
          if (state is FeesInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _students);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is FeesPaymentsLoaded) {
            return _buildLoadedScreen(context, state.students);
          } else if (state is FeesViewError) {
            try{
              return _buildLoadedScreen(context, _students);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          } else if (state is FeesNetworkErr) {
            try{
              return _buildLoadedScreen(context, _students);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _buildLoadedScreen(context, _students);
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
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          MyColors.primaryColor),
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
              onTap: () => _viewFeesPayments(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Students> students) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, students, index);
      }, childCount: students.length),
    );
  }


  static void showOptionsModalBottomSheet({BuildContext context, List<Students> students, int index}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
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
                    Icons.view_agenda,
                    color: Colors.amber,
                  ),
                  title: new Text('View'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToViewStudentsDetailScreen(context, students, index, true);
                  },
                ),
                ListTile(
                    leading: new Icon(
                      Icons.pause_circle_filled,
                      color: Colors.red,
                    ),
                    title: new Text('Deactivate Student'),
                    onTap: () {
                      Navigator.pop(context);
                      _feesBloc.add(DeactivateDefaultStudentEvent(students[index].feesPayment.recordId, students[index].id));
                    }),
              ],
            ),
          );
        });
  }

  void showFilterByDateModalBottomSheet({BuildContext context, FeesRecord feesRecord}) async{
    final data = await showModalBottomSheet<List<String>>(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        builder: (BuildContext bc) {
          return BlocProvider(
            create: (bc) => FeesBloc(),
            child: Container(
              child: PickDate()
            ),
          );
        });
    if (data != null) {
      dateFrom=data.first;
      dateTo=data.last;
      _feesBloc.add(ViewFeesPaymentsByDateEvent(await getApiToken(), feesRecord.id, dateFrom, dateTo));
    }
  }

  static _navigateToViewStudentsDetailScreen(BuildContext context,List<Students> students, int index, bool fees) async {

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              StudentDetails(students: students, index: index, fees: fees, pickUpId: false)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
       Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      _feesBloc.add(ViewFeesPaymentsEvent(await getApiToken(), students[index].feesPayment.recordId));
    }
  }
}


Widget _buildRow(BuildContext context, List<Students> students, int index) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: students[index].feesPayment.deleted?Colors.red.withOpacity(0.1):Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 1,
        child: ListTile(
          title: Row(
            children: <Widget>[
              Hero(
                tag: "student passport tag $index",
                transitionOnUserGestures: true,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: FadeInImage.assetNetwork(
                      placeholderScale: 5,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(seconds: 1),
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: 'lib/assets/images/avatar.png',
                      image: students[index].passportLink +
                          students[index].passport,
                    ),
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
                        child: Text(toSentenceCase(students[index].feesPayment.status.replaceAll('_', ' ')),
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
                      child: Text('${toSentenceCase(students[index].lName)} ${toSentenceCase(students[index].fName)} ${toSentenceCase(students[index].mName)}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(
                          (students[index].admissionNumber.isEmpty
                              ? '${students[index].sessions.admissionNumberPrefix}${students[index].genAdmissionNumber}'
                              : '${students[index].sessions.admissionNumberPrefix}${students[index].admissionNumber}'),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Divider(
                      color: MyColors.primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('Total: ${convertPrice(currency: students[index].school.currency, amount: students[index].feesPayment.totalAmount)}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('Paid: ${convertPrice(currency: students[index].school.currency, amount: students[index].feesPayment.amountPaid)}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('Balance: ${convertPrice(currency: students[index].school.currency, amount:  students[index].feesPayment.balance)}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            ViewFeesPaymentsPage._navigateToViewStudentsDetailScreen(context, students, index, true);
            // Add 9 lines from here...
          },
          onLongPress: (){
            ViewFeesPaymentsPage.showOptionsModalBottomSheet(context: context, students: students, index: index);
          },
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Students> students;
  CustomSearchDelegate(this.students);

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
          ? students
          : students
          .where((p) =>
      (p.feesPayment.status.contains(query))
          || (p.fName.contains(query))
          || (p.lName.contains(query))
          || (p.mName.contains(query))
      )
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
          ? students
          : students
          .where((p) =>
      (p.feesPayment.status.contains(query))
          || (p.fName.contains(query))
          || (p.lName.contains(query))
          || (p.mName.contains(query))
      )
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

class PickDate extends StatefulWidget {
  PickDate({Key key}) : super(key: key);

  @override
  _PickDateState createState() => _PickDateState();
}

class _PickDateState extends State<PickDate> {
  final formatDate = DateFormat("yyyy-MM-dd");
  DateTime selectedDateFrom = DateTime.now();
  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year - 5),
        lastDate: DateTime(selectedDateFrom.year + 5));
    if (picked != null && picked != selectedDateFrom)
      setState(() {
        selectedDateFrom=picked;
      });
  }
  DateTime selectedDateTo = DateTime.now();
  Future<Null> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year - 5),
        lastDate: DateTime(selectedDateTo.year + 5));
    if (picked != null && picked != selectedDateTo)
      setState(() {
        selectedDateTo=picked;
      });
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(
                          left: 30.0),
                      child: Text("From",
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
                            "${selectedDateFrom.toLocal()}"
                                .split(' ')[0],
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                Colors.black87,
                                fontWeight:
                                FontWeight
                                    .normal)),
                      ),
                    ),
                  ],
                ),
                onTap: () =>
                    _selectDateFrom(context),
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(
                          left: 30.0),
                      child: Text("To",
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
                              color: MyColors.primaryColor,
                              style:
                              BorderStyle.solid,
                              width: 0.80),
                        ),
                        child: Text(
                            "${selectedDateTo.toLocal()}"
                                .split(' ')[0],
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                Colors.black87,
                                fontWeight:
                                FontWeight
                                    .normal)),
                      ),
                    ),
                  ],
                ),
                onTap: () => _selectDateTo(context),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.maxFinite,
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context, [
                  formatDate.format(selectedDateFrom.toLocal()),
                  formatDate.format(selectedDateTo.toLocal())]);
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
          ),
        ),
      ],
    );
  }
}
