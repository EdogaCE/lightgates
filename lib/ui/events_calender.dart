import 'package:flutter/material.dart';
import 'package:school_pal/blocs/events/events.dart';
import 'package:school_pal/blocs/navigatoins/navigation.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_school_events_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/create_event.dart';
import 'package:school_pal/ui/event_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

class EventsCalender extends StatelessWidget {
  final String loggedInAs;
  EventsCalender({this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    //Show status bar
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventsBloc>(
          create: (context) =>
              EventsBloc(viewEventsRepository: ViewEventsRequest()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
      ],
      child: EventsCalenderPage(loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class EventsCalenderPage extends StatelessWidget {
  final String loggedInAs;
  EventsCalenderPage(this.loggedInAs);
  NavigationBloc navigationBloc;
  EventsBloc eventsBloc;
  Map<DateTime, List> _events = Map();
  final _selectedDate = DateTime.now();
  List _selectedEvents = [];
  final _calendarController = CalendarController();
  void viewEvents() async {
    eventsBloc.add(ViewEventsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);*/
    navigationBloc = BlocProvider.of<NavigationBloc>(context);
    eventsBloc = BlocProvider.of<EventsBloc>(context);
    viewEvents();
    /* _events = {
      _selectedDate: [
        'Holiday A1',
        'Holiday A2',
      ],
      convertDateFromString('2020-02-20 01:30:40'): [
        'Holiday A1',
        'Holiday A2',
        'Holiday A1',
        'Holiday A2',
      ]
    };*/
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        //Todo: to change back button color
        iconTheme: IconThemeData(color: MyColors.primaryColor),
        title: Text("Events", style: TextStyle(color: MyColors.primaryColor)),
      ),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Stack(
          children: <Widget>[
            Center(
                child: SvgPicture.asset("lib/assets/images/schedule3.svg")
            ),
            Container(
              color: Colors.white70,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  BlocListener<EventsBloc, EventsStates>(
                    listener: (BuildContext context, EventsStates state) {
                      if (state is EventsLoaded) {
                        _events.clear();
                        for (var event in state.events) {
                          if (_events.containsKey(convertDateFromString(event.date.split(",")[0].split(' ')[0]))) {
                            _events[convertDateFromString(event.date.split(",")[0].split(' ')[0])]
                                .add('${event.id},${event.titleOfEvent},${event.description},${event.date}');
                          } else {
                            _events[convertDateFromString(event.date.split(",")[0].split(' ')[0])] =
                                ['${event.id},${event.titleOfEvent},${event.description},${event.date}'];
                          }
                        }
                        _selectedEvents = _events[convertDateFromString(_selectedDate.toLocal().toString().split( ' ')[0])] ?? [];
                      }
                    },
                    child: BlocBuilder<EventsBloc, EventsStates>(
                        builder: (BuildContext context, EventsStates state) {
                      return _buildTableCalendar();
                    }),
                  ),
                  const SizedBox(height: 8.0),
                  BlocListener<NavigationBloc, NavigationStates>(
                    listener: (BuildContext context, NavigationStates state) {
                      if (state is SelectedDateChanged) {
                        _selectedEvents = state.events;
                      }
                    },
                    child: BlocBuilder<NavigationBloc, NavigationStates>(
                        builder: (BuildContext context, NavigationStates state) {
                      return Expanded(child: _buildEventList(context));
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (loggedInAs=='school')?FloatingActionButton(
        heroTag: "Add Event",
        onPressed: ()=>_navigateToCreateEventScreen(context),
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ):Container(),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue[400],
        todayColor: Colors.blue[200],
        markersColor: Colors.teal[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: MyColors.primaryColorShade400,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList(BuildContext context) {
    return ListView(
      children: _selectedEvents
          .map((event) => ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white30
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(event.toString().split(",")[1],
                        style: TextStyle(
                            fontSize: 18,
                            color: MyColors.primaryColor,
                            fontWeight: FontWeight.bold)),
                    onTap: () => _navigateToEventDetailScreen(context, event.toString().split(","), loggedInAs)
                  ),
                ),
              ))
          .toList(),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    navigationBloc.add(ChangeSelectedDateEvent(events));
    //_selectedEvents = events;
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  _navigateToCreateEventScreen(BuildContext context) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEvent(event: [])),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      /*Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));*/

      //Refresh after update
      viewEvents();
    }
  }

  _navigateToEventDetailScreen(BuildContext context, List list, String loggedInAs) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetails(list, loggedInAs)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

      //Refresh after update
      viewEvents();
      navigationBloc.add(ChangeSelectedDateEvent([]));
    }
  }

}
