import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_fees_requests.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_fee.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ViewFees extends StatelessWidget {
  final FeesRecord feesRecord;
  ViewFees({this.feesRecord});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeesBloc(viewFeesRepository: ViewFeesRequest(), createFeesRepository: CreateFeesRequests()),
      child: ViewFeesPage(feesRecord),
    );
  }
}

// ignore: must_be_immutable
class ViewFeesPage extends StatelessWidget {
  FeesRecord feesRecord;
  ViewFeesPage(this.feesRecord);
  static FeesBloc _feesBloc;
  List<Fees> _fees;

   _viewFees() async {
    _feesBloc.add(ViewFeesEvent(await getApiToken(), feesRecord.id));
  }

  @override
  Widget build(BuildContext context) {
    _feesBloc = BlocProvider.of<FeesBloc>(context);
    _viewFees();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewFees();
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
                            delegate: CustomSearchDelegate(_fees));
                      })
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Add record",
        onPressed: () {
          _navigateToFeesEditScreen(context: context, feesRecord: feesRecord, event: 'Create');
        },
        label: Text('Create'),
        icon: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
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
        } else if (state is FeesLoaded) {
          _fees = state.fees;
        }else if (state is Processing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if (state is FeeDeleted) {
          _viewFees();
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
              return _buildLoadedScreen(context, _fees);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is FeesLoaded) {
            return _buildLoadedScreen(context, state.fees);
          } else if (state is FeesViewError) {
            try{
              return _buildLoadedScreen(context, _fees);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          } else if (state is FeesNetworkErr) {
            try{
              return _buildLoadedScreen(context, _fees);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _buildLoadedScreen(context, _fees);
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
              onTap: () => _viewFees(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Fees> fees) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, fees, index);
      }, childCount: fees.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context, Fees fees}) {
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
                      _navigateToFeesEditScreen(context: context, fees: fees, event: 'Update');
                    }),
                ListTile(
                    leading: new Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: new Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      _feesBloc.add(DeleteFeeEvent(fees.id, fees.recordId));
                    }),
              ],
            ),
          );
        });
  }

   static _navigateToFeesEditScreen({BuildContext context, Fees fees, FeesRecord feesRecord, String event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          CreateFee(fees: fees, feesRecord: feesRecord, event: event)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      /* Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));*/

      //Refresh after update
      _feesBloc.add(ViewFeesEvent(await getApiToken(), feesRecord.id));
    }
  }
}


Widget _buildRow(BuildContext context, List<Fees> fees, int index) {
  return !fees[index].deleted?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: fees[index].deleted?Colors.red:Colors.white,
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
                        child: Text(toSentenceCase(fees[index].division.replaceAll('_', ' ')),
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
                      child: Text(toSentenceCase(fees[index].title),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('Amount: ${convertPrice(currency: fees[index].currency, amount: fees[index].amount)}',
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
            //ViewFeesRecordPage._navigateToViewTeachersScreen(context, feesRecord[index], 'salary');
            // Add 9 lines from here...
          },
          onLongPress: (){
            ViewFeesPage.showOptionsModalBottomSheet(context: context, fees: fees[index]);
          },// ... to here.// ... to here.
        ),
      ),
    ),
  ):Container();
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Fees> fees;
  CustomSearchDelegate(this.fees);

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
          ? fees
          : fees
          .where((p) =>
      (p.division.contains(query)) || (p.title.contains(query)))
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
          ? fees
          : fees
          .where((p) =>
      (p.division.contains(query)) || (p.title.contains(query)))
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
