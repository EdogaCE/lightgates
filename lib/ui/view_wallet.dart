import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/wallet/wallet.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/wallet_record.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_wallet_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';

class ViewWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(viewWalletRepository: ViewWalletRequest()),
      child: ViewWalletPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewWalletPage extends StatelessWidget with WidgetsBindingObserver {
  WalletBloc _walletBloc;
  List<School> _foundHistory;
  String _currency;
  String _apiToken;

   _viewFoundHistory() async {
     _currency=await getUserCurrency();
     _apiToken=await getApiToken();
    _walletBloc.add(ViewTransactionHistoriesEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      /// Restart page on resume
      _viewFoundHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    _walletBloc = BlocProvider.of<WalletBloc>(context);
    _viewFoundHistory();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewFoundHistory();
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
                            delegate: CustomSearchDelegate(_foundHistory));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text('History'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: BlocBuilder<WalletBloc, WalletStates>(
                        builder: (context, state) {
                          //Todo: note builder returns widget
                          if (state is TransactionHistoriesLoaded) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                  child: Text('BALANCE',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                  child: Text(convertPrice(amount: state.school.first.walletBalance, currency: state.school.first.currency),
                                    style: TextStyle(
                                        fontSize: 35,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Center(
                                child: SvgPicture.asset(
                                    "lib/assets/images/payment.svg")
                            );
                          }
                        },
                      ),
                    )),
              ),
              _buildSalaryRecord(context)
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Fund wallet",
        onPressed: () {
          showAmountModalDialog(context: context).then((value){
            if(value!=null){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewLoader(
                      url: '${MyStrings.domain}${MyStrings.foundSchoolWalletUrl}$_apiToken/${base64Encode(utf8.encode(value))}/top_up',
                      downloadLink: '',
                      title: 'Card Details',
                    )),
              );
            }
          });
        },
        label: Text('Fund Wallet'),
        icon: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<WalletBloc, WalletStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is ViewError) {
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
        } else if (state is TransactionHistoriesLoaded) {
          _foundHistory = state.school;
        }else if (state is WalletProcessing) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }else if(state is TransactionHistoryLoaded){
          Scaffold.of(context).removeCurrentSnackBar();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewLoader(
                  url: 'https://docs.google.com/viewer?url=${state.url}',
                  downloadLink: state.url,
                  title: 'Transaction Receipt',
                )),
          );
        }
      },
      child: BlocBuilder<WalletBloc, WalletStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          //Todo: note builder returns widget
          if (state is WalletInitial) {
            return buildInitialScreen();
          } else if (state is WalletLoading) {
            try{
              return _buildLoadedScreen(context, _foundHistory);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is TransactionHistoriesLoaded) {
            return _buildLoadedScreen(context, state.school);
          } else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _foundHistory);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          } else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _foundHistory);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _buildLoadedScreen(context, _foundHistory);
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
              onTap: () => _viewFoundHistory(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<School> foundHistory) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, foundHistory, index);
      }, childCount: foundHistory.length),
    );
  }

  Future<String> showAmountModalDialog({BuildContext context})async{
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final data=await showDialog(
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
                        child: Text('Fund Wallet',
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
                                return 'Please enter amount($_currency)';
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
                                Icon(Icons.monetization_on, color: MyColors.primaryColor),
                                labelText: "Amount($_currency)",
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
                              child: const Text("Continue",
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

}


Widget _buildRow(BuildContext context, List<School> foundHistory, int index) {
  return !foundHistory[index].walletRecord.deleted?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: foundHistory[index].walletRecord.deleted?Colors.red:Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(foundHistory[index].walletRecord.actionType),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(foundHistory[index].walletRecord.status),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: (foundHistory[index].walletRecord.status=='confirmed')
                                      ?Colors.green:Colors.orange,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(convertPrice(currency: foundHistory[index].currency, amount: foundHistory[index].walletRecord.amount),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(foundHistory[index].walletRecord.description),
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
          onTap: ()=>showOptionsModalBottomSheet(context: context, walletRecord: foundHistory[index].walletRecord),
          onLongPress: ()=>showOptionsModalBottomSheet(context: context, walletRecord: foundHistory[index].walletRecord),
        ),
      ),
    ),
  ):Container();
}

void showOptionsModalBottomSheet({BuildContext context, WalletRecord walletRecord}) {
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
                  Icons.print,
                  color: MyColors.primaryColor,
                ),
                title: new Text('Print Receipt'),
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<WalletBloc>(context).add(ViewTransactionHistoryEvent(walletRecord.id));
                },
              ),
            ],
          ),
        );
      });
}

class CustomSearchDelegate extends SearchDelegate {
  final List<School> foundHistory;
  CustomSearchDelegate(this.foundHistory);

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
          ? foundHistory
          : foundHistory
          .where((p) =>
      (p.walletRecord.status.contains(query)) || (p.walletRecord.actionType.contains(query)))
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
          ? foundHistory
          : foundHistory
          .where((p) =>
      (p.walletRecord.status.contains(query)) || (p.walletRecord.actionType.contains(query)))
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

