import 'package:flutter/material.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/blocs/fees/fees_bloc.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_fees_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/view_students_fee_payments.dart';
import 'package:school_pal/utils/system.dart';

class ViewStudentsFeeRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeesBloc(viewFeesRepository: ViewFeesRequest()),
      child: ViewStudentsFeeRecordsPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewStudentsFeeRecordsPage extends StatelessWidget {
  FeesBloc _feesBloc;
  List<Students> _feesRecord;

  _viewFeesRecords() async {
    _feesBloc.add(ViewStudentFeesEvent(await getApiToken(), await getUserId()));
  }

  @override
  Widget build(BuildContext context) {
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _viewFeesRecords();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewFeesRecords();
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
                            delegate: CustomSearchDelegate(_feesRecord));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('Fees Records'),
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
          _feesRecord = state.students;
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
              return _buildLoadedScreen(context, _feesRecord);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is FeesPaymentsLoaded) {
            return _buildLoadedScreen(context, state.students);
          } else if (state is FeesViewError) {
            try{
              return _buildLoadedScreen(context, _feesRecord);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          } else if (state is FeesNetworkErr) {
            try{
              return _buildLoadedScreen(context, _feesRecord);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _buildLoadedScreen(context, _feesRecord);
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
              onTap: () => _viewFeesRecords(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Students> feesRecord) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, feesRecord, index);
      }, childCount: feesRecord.length),
    );
  }
}


Widget _buildRow(BuildContext context, List<Students> feesRecord, int index) {
  return !feesRecord[index].feesPayment.fees[0].feesRecord.deleted?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: feesRecord[index].feesPayment.fees[0].feesRecord.deleted?Colors.red:Colors.white,
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
                        child: Text(toSentenceCase(feesRecord[index].feesPayment.fees[0].feesRecord.type),
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
                      child: Text(toSentenceCase(feesRecord[index].feesPayment.fees[0].feesRecord.title),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(feesRecord[index].feesPayment.fees[0].feesRecord.description),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewStudentsFeePayments(feesRecord[index])),
            );
          },
        ),
      ),
    ),
  ):Container();
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Students> feesRecord;

  CustomSearchDelegate(this.feesRecord);

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
          ? feesRecord
          : feesRecord
          .where((p) =>
      (p.feesPayment.fees[0].feesRecord.type.contains(query)) || (p.feesPayment.fees[0].feesRecord.title.contains(query)))
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
          ? feesRecord
          : feesRecord
          .where((p) =>
      (p.feesPayment.fees[0].feesRecord.type.contains(query)) || (p.feesPayment.fees[0].feesRecord.title.contains(query)))
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
