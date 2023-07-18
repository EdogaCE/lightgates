import 'package:flutter/material.dart';
import 'package:school_pal/blocs/advert/advert.dart';
import 'package:school_pal/models/advert.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/get/view_adverts_request.dart';
import 'package:school_pal/requests/posts/update_advert_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_advert.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';

class ViewAdvert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertBloc(viewAdvertsRepository: ViewAdvertsRequest(),
          updateAdvertRepository: UpdateAdvertRequests()),
      child: ViewAdvertPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewAdvertPage extends StatelessWidget {
  AdvertBloc _advertBloc;
  List<Advert> _adCampaigns=List();

  _viewAdCampaigns() async {
    _advertBloc.add(ViewUserAdvertsEvent());
  }


  @override
  Widget build(BuildContext context) {
    _advertBloc = BlocProvider.of<AdvertBloc>(context);
    _viewAdCampaigns();
    final _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewAdCampaigns();
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
                            delegate: CustomSearchDelegate(_adCampaigns));
                      })
                ],
                pinned: true,
                expandedHeight: 250.0,
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(
                        'Adverts'),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: Padding(
                      padding: const EdgeInsets.only(bottom: 45.0),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/contact_developer.svg")
                      ),
                    )),
              ),
              _buildAdCampaigns(context)
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Create Ad",
        onPressed: () {
          _navigateToCreateAdScreen(context: context, edit: false).then((value) {
            if(value!=null)
              _viewAdCampaigns();
          });
        },
        label: Text('Create Ad'),
        icon: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _buildAdCampaigns(context) {
    return BlocListener<AdvertBloc, AdvertStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is AdvertNetworkErr) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is AdvertViewError) {
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
        } else if (state is AdvertsLoaded) {
          _adCampaigns=state.adverts;
        } else if (state is AdvertPausedOrCancelled) {
          _viewAdCampaigns();
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }else if (state is AdvertRestarted) {
          _viewAdCampaigns();
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }else if(state is AdvertsProcessing){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              duration: Duration(minutes: 30),
              content: General.progressIndicator("Processing..."),
            ),
          );
        }
      },
      child: BlocBuilder<AdvertBloc, AdvertStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is AdvertInitialState) {
            return buildInitialScreen();
          } else if (state is AdvertsLoading) {
            return _adCampaigns.isNotEmpty
                ? _buildLoadedScreen(context, _adCampaigns)
                : buildLoadingScreen();
          } else if (state is AdvertsLoaded) {
            return _adCampaigns.isNotEmpty
                ? _buildLoadedScreen(context, _adCampaigns)
                : buildNODataScreen();
          } else if (state is AdvertViewError) {
            return _adCampaigns.isNotEmpty
                ? _buildLoadedScreen(context, _adCampaigns)
                : buildNODataScreen();
          } else if (state is AdvertNetworkErr) {
            return _adCampaigns.isNotEmpty
                ? _buildLoadedScreen(context, _adCampaigns)
                : buildNetworkErrorScreen();
          } else {
            return _adCampaigns.isNotEmpty
                ? _buildLoadedScreen(context, _adCampaigns)
                : buildInitialScreen();
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
              onTap: () => _viewAdCampaigns(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Advert> adverts) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, adverts, index);
      }, childCount: adverts.length),
    );
  }

}


Widget _buildRow(BuildContext context, List<Advert> adverts, int index) {
  return !adverts[index].deleted?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shadowColor: adverts[index].deleted?Colors.red:Colors.white,
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
                            child: Text(toSentenceCase(adverts[index].driveTrafficTo),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(adverts[index].status),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: (adverts[index].status=='running')
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
                      child: Text(toSentenceCase(adverts[index].title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 18,
                            color: MyColors.primaryColor,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(convertPrice(currency: adverts[index].preferredCurrency, amount: adverts[index].budget),
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase(adverts[index].description),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
              )
            ],
          ),
          onTap: ()=>showOptionsModalBottomSheet(context: context, advert: adverts[index]),
          onLongPress: ()=>showOptionsModalBottomSheet(context: context, advert: adverts[index]),
        ),
      ),
    ),
  ):Container();
}

void showOptionsModalBottomSheet({BuildContext context, Advert advert}) {
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
                    _navigateToCreateAdScreen(context: context, edit: true, advert: advert).then((value) {
                      if(value!=null)
                        BlocProvider.of<AdvertBloc>(context).add(ViewUserAdvertsEvent());
                    });
                  }),
              (advert.status=='running')
                  ?ListTile(
                leading: new Icon(
                  Icons.pause_circle_filled,
                  color: Colors.yellow,
                ),
                title: new Text('Pause Ad'),
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<AdvertBloc>(context).add(PauseOrCancelAdvertEvent(adCampaignId: advert.uniqueId, option: 'paused'));
                },
              ):(advert.status=='paused')
                  ?ListTile(
                leading: new Icon(
                  Icons.play_circle_filled,
                  color: Colors.green,
                ),
                title: new Text('Resume Ad'),
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<AdvertBloc>(context).add(RestartAdvertEvent(adCampaignId: advert.uniqueId));
                },
              ):Container(),
              ListTile(
                leading: new Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: new Text('Cancel Ad'),
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<AdvertBloc>(context).add(PauseOrCancelAdvertEvent(adCampaignId: advert.uniqueId, option: 'cancelled'));
                },
              ),
            ],
          ),
        );
      });
}

Future<String> _navigateToCreateAdScreen({BuildContext context, bool edit, Advert advert}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CreateAdvert(edit: edit, advert: advert)),
  );
  return result;
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Advert> adverts;
  CustomSearchDelegate(this.adverts);

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
          ? adverts
          : adverts
          .where((p) =>
      (p.title.contains(query)) || (p.driveTrafficTo.contains(query)))
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
          ? adverts
          : adverts
          .where((p) =>
      (p.title.contains(query)) || (p.driveTrafficTo.contains(query)))
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

