import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/events/events.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/requests/posts/add_edit_event_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/utils/system.dart';

class CreateEvent extends StatelessWidget {
  final List<String> event;
  CreateEvent({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventsBloc(eventRepository: EventRequests()),
      child: CreateEventPage(event),
    );
  }
}

// ignore: must_be_immutable
class CreateEventPage extends StatelessWidget {
  final List<String> event;
  CreateEventPage(this.event);
// ignore: close_sinks
  EventsBloc eventsBloc;
  DateTime selectedDateFrom = DateTime.now();
  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateFrom,
        firstDate: DateTime(selectedDateFrom.year - 500),
        lastDate: DateTime(selectedDateFrom.year + 500));
    if (picked != null && picked != selectedDateFrom)
      eventsBloc.add(ChangeDateFromEvent(picked));
  }
  DateTime selectedDateTo = DateTime.now();
  Future<Null> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTo,
        firstDate: DateTime(selectedDateTo.year - 5),
        lastDate: DateTime(selectedDateTo.year + 5));
    if (picked != null && picked != selectedDateTo)
      eventsBloc.add(ChangeDateToEvent(picked));
  }

  final titleController = TextEditingController();
  final eventController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    eventsBloc = BlocProvider.of<EventsBloc>(context);
    if(event.isNotEmpty){
      titleController.text=event[1];
      eventController.text=event[2];
      selectedDateFrom=convertDateFromString(event[3]);
      selectedDateTo=convertDateFromString(event[4]);
    }
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Event", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Animator(
                  repeats: 1,
                  duration: Duration(seconds: 2),
                  builder: (context, anim, child) => Opacity(
                    opacity: anim.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child:
                          SvgPicture.asset("lib/assets/images/schedule2.svg",
                          alignment: Alignment.topCenter,)
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  BlocListener<EventsBloc, EventsStates>(
                                    listener: (BuildContext context,
                                        EventsStates state) {
                                      if (state is DateFromChanged) {
                                        selectedDateFrom = state.from;
                                      }
                                    },
                                    child:
                                        BlocBuilder<EventsBloc, EventsStates>(
                                      builder: (BuildContext context,
                                          EventsStates state) {
                                        return Expanded(
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
                                        );
                                      },
                                    ),
                                  ),
                                  BlocListener<EventsBloc, EventsStates>(
                                    listener: (BuildContext context,
                                        EventsStates state) {
                                      if (state is DateToChanged) {
                                        selectedDateTo = state.to;
                                      }
                                    },
                                    child:
                                        BlocBuilder<EventsBloc, EventsStates>(
                                      builder: (BuildContext context,
                                          EventsStates state) {
                                        return Expanded(
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: titleController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter event title.';
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
                                          Icon(Icons.title, color: Colors.blue),
                                      labelText: 'Title',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: eventController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter event.';
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
                                          Icon(Icons.event, color: Colors.blue),
                                      labelText: 'Event',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _doneButtonFill(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    }else if(state is EventAdded){
                       Navigator.pop(context, state.message);
                    }else if(state is EventUpdated){
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
        ));
  }

  Widget _doneButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          print(selectedDateFrom.toLocal().toString());
          print(selectedDateTo.toLocal().toString());
          if (_formKey.currentState.validate()) {
            if(event.isEmpty){
              eventsBloc.add(AddSchoolEvent(titleController.text, eventController.text, selectedDateFrom.toLocal().toString().split(".")[0], selectedDateTo.toLocal().toString().split(".")[0]));
            }else{
              eventsBloc.add(UpdateSchoolEvent(event[0], titleController.text, eventController.text, selectedDateFrom.toLocal().toString().split(".")[0], selectedDateTo.toLocal().toString().split(".")[0]));
            }
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
          child: const Text("Done", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
