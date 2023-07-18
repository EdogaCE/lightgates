import 'package:flutter/material.dart';
import 'package:school_pal/blocs/tickets/tickets.dart';
import 'package:school_pal/models/ticket_comments.dart';
import 'package:school_pal/models/tickets.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_tickets_with_comments.dart';
import 'package:school_pal/requests/posts/create_ticket_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';

class ViewTicketComments extends StatelessWidget {
  final List<Tickets> tickets;
  final int index;
  ViewTicketComments({Key key, this.tickets, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketsBloc(
          viewTicketsRepository: ViewTicketsRequest(),
          createTicketRepository: CreateTicketRequests()),
      child: ViewTicketCommentsPage(tickets, index),
    );
  }
}

// ignore: must_be_immutable
class ViewTicketCommentsPage extends StatelessWidget {
  final List<Tickets> tickets;
  final int commentIndex;
  ViewTicketCommentsPage(this.tickets, this.commentIndex);
  TicketsBloc ticketsBloc;
  final commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Tickets> renderTickets;
  void _viewTickets() async {
    ticketsBloc.add(ViewTicketsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    renderTickets = tickets;
    ticketsBloc = BlocProvider.of<TicketsBloc>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Comments", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                BlocListener<TicketsBloc, TicketsStates>(
                  listener: (BuildContext context, TicketsStates state) {
                    if(state is Processing){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    } else if (state is TicketsLoaded) {
                      renderTickets = state.tickets;
                    } else if (state is NetworkErr) {
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
                    } else if (state is CommentCreated) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      commentController.clear();
                      _viewTickets();
                    }
                  },
                  child: BlocBuilder<TicketsBloc, TicketsStates>(
                    builder: (BuildContext context, TicketsStates state) {
                      return Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount:
                                    renderTickets[commentIndex].comments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildRow(
                                      context,
                                      renderTickets[commentIndex].comments,
                                      index);
                                }),
                          ),
                          /*(state is Processing)
                              ? Row(
                                  children: <Widget>[
                                    Expanded(child: Container()),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        child: Container(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Text(
                                                  commentController.text,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            )),
                                      ),
                                    ),
                                  ],
                                ) : Container()*/
                        ],
                      ));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextFormField(
                            controller: commentController,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '';
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
                                    Icon(Icons.comment, color: Colors.blue),
                                labelText: 'Message',
                                labelStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: FloatingActionButton(
                          heroTag: "Send comment",
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              ticketsBloc.add(CreateTicketCommentEvent(
                                  tickets[commentIndex].senderId,
                                  tickets[commentIndex].id,
                                  commentController.text));
                            }
                          },
                          child: Icon(Icons.send),
                          backgroundColor: MyColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildRow(
      BuildContext context, List<TicketComments> comments, int index) {
    return ListTile(
        title: (renderTickets[commentIndex].senderId ==
                comments[index].senderId)
            ? Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                          color: Colors.green.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                      toSentenceCase(comments[index].comment),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal)),
                                ),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(Icons.check_circle,
                                        size: 15,
                                        color:
                                            MyColors.primaryColor.withOpacity(1)))
                              ],
                            ),
                          )),
                    ),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                          color: MyColors.primaryColor.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(toSentenceCase(comments[index].comment),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal)),
                          )),
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
        onTap: () {});
  }
}
