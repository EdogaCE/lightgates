import 'package:flutter/material.dart';
import 'package:school_pal/blocs/tickets/tickets.dart';
import 'package:school_pal/models/tickets.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_tickets_with_comments.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_ticket.dart';
import 'package:school_pal/ui/view_ticket_comments.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewTickets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TicketsBloc(viewTicketsRepository: ViewTicketsRequest()),
      child: ViewTicketsPage(),
    );
  }
}

// ignore: must_be_immutable
class ViewTicketsPage extends StatelessWidget {
  TicketsBloc _ticketsBloc;
  List<Tickets> _tickets;

  void _viewTickets() async {
    _ticketsBloc.add(ViewTicketsEvent(await getApiToken()));

  }

  @override
  Widget build(BuildContext context) {
    _ticketsBloc = BlocProvider.of<TicketsBloc>(context);
    _viewTickets();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewTickets();
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
                            delegate: CustomSearchDelegate(_tickets));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                //title: SABT(child: Text("Classes Categorized")),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text("Tickets"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/contact_alert.svg")
                      ),
                    )),
              ),
              _ticketList(context)
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "Create Ticket",
        onPressed: () {
          _navigateToCreateTicketScreen(context);
        },
        label: Text('Ticket'),
        icon: Icon(Icons.create),
        backgroundColor: MyColors.primaryColor,
      ),
    );
  }

  Widget _ticketList(context) {
    return BlocListener<TicketsBloc, TicketsStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is ViewError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is TicketsLoaded) {
          _tickets = state.tickets;
        }
      },
      child: BlocBuilder<TicketsBloc, TicketsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is TicketsInitial) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, _tickets);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is TicketsLoaded) {
            return _buildLoadedScreen(context, state.tickets);
          }  else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _tickets);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _tickets);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _tickets);
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
              onTap: () => _viewTickets(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Tickets> tickets) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context, tickets, index);
      }, childCount: tickets.length),
    );
  }

  _navigateToCreateTicketScreen(BuildContext context) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTicket()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      /*Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));*/

      //Refresh after update
      _viewTickets();
    }
  }
}

Widget _buildRow(
    BuildContext context, List<Tickets> tickets, int index) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListTile(
        leading: new Icon(
          Icons.comment,
          color: Colors.teal,
        ),
        title:Text(toSentenceCase(tickets[index].title),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                fontSize: 18,
                color: MyColors.primaryColor,
                fontWeight: FontWeight.bold)),
        subtitle: Column(
          children: <Widget>[
            Text(toSentenceCase(tickets[index].message),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.normal)),
            Divider(
              color: Colors.black54,
            )
          ],
        ),
        onTap: () {
           Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ViewTicketComments(tickets: tickets, index: index,)),
            );
        }),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Tickets> tickets;
  CustomSearchDelegate(this.tickets);

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
          ? tickets
          : tickets
          .where((p) =>
      (p.title.contains(query)) || (p.message.contains(query)))
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
          ? tickets
          : tickets
          .where((p) =>
      (p.title.contains(query)) || (p.message.contains(query)))
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

