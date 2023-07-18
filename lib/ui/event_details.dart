import 'package:flutter/material.dart';
import 'package:school_pal/blocs/events/events.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/get/view_school_events_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/create_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'general.dart';

class EventDetails extends StatelessWidget {
  final List<String> event;
  final String loggedInAs;
  EventDetails(this.event, this.loggedInAs);
  @override
  Widget build(BuildContext context) {
    //Show status bar
    return BlocProvider(
        create: (context) =>
            EventsBloc(viewEventsRepository: ViewEventsRequest()),
      child: EventDetailsPage(event, loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class EventDetailsPage extends StatelessWidget {
  final List<String> event;
  final String loggedInAs;
  EventDetailsPage(this.event, this.loggedInAs);
  EventsBloc eventsBloc;
  @override
  Widget build(BuildContext context) {
    eventsBloc = BlocProvider.of<EventsBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions:(loggedInAs=='school')? <Widget>[
              IconButton(icon: Icon(Icons.edit, color: Colors.white,), onPressed: () {
                _navigateToEditEventScreen(context, event);
              }),
              IconButton(icon: Icon(Icons.delete_forever, color: Colors.red,), onPressed: () {
                showDeleteAlertDialog(context);
              })
            ]:<Widget>[],
            pinned: true,
            floating: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                centerTitle: true,
                title: Text(event[1]),
                titlePadding: const EdgeInsets.all(15.0),
                background: CustomPaint(
                  painter: CustomScrollPainter(),
                  child: Center(
                      child: SvgPicture.asset("lib/assets/images/schedule1.svg")),
                )),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  // margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(("Description:  "),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(event[2],
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.blue)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  // margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(("Date:  "),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: MyColors.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Icon(Icons.date_range,
                                    color: Colors.green, size: 15.0),
                              ),
                              Text('From: ${event[3]}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Icon(Icons.date_range,
                                    color: Colors.red, size: 15.0),
                              ),
                              Text('To: ${event[4]}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        BlocListener<EventsBloc, EventsStates>(
                          listener: (BuildContext context, EventsStates state) {
                            if(state is EventsLoading){
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(minutes: 30),
                                  content: General.progressIndicator("Processing..."),
                                ),
                              );
                            }else if(state is NetworkErr){
                              Scaffold.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(
                                SnackBar(
                                  content: Text(state.message, textAlign: TextAlign.center),
                                ),
                              );
                            } else if(state is ViewError){
                              Scaffold.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(
                                SnackBar(
                                  content: Text(state.message, textAlign: TextAlign.center),
                                ),
                              );
                            }else if(state is EventDeleted){
                              Navigator.pop(context, state.message);
                            }
                          },
                          child: BlocBuilder<EventsBloc, EventsStates>(
                            builder: (BuildContext context, EventsStates state) {
                              return Container();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  void showDeleteAlertDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete", style: TextStyle(
                fontSize: 18,
                color: MyColors.primaryColor,
                fontWeight: FontWeight.bold)),
            content: Text("Do you want to delete this event?"),
            actions: [
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop();
                  eventsBloc.add(DeleteSchoolEvent(event[0]));
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _navigateToEditEventScreen(BuildContext context, List list) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEvent(event: list,)),
    );

    if(result!=null){
      //Navigate to main page
      Navigator.pop(context, result);
    }
  }

}
