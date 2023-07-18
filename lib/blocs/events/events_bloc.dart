import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/events/events.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_school_events_request.dart';
import 'package:school_pal/requests/posts/add_edit_event_requests.dart';
import 'package:school_pal/res/strings.dart';

class EventsBloc extends Bloc<EventsEvents, EventsStates>{
  final ViewEventsRepository viewEventsRepository;
  final EventRepository eventRepository;
  EventsBloc({this.viewEventsRepository, this.eventRepository}) : super(EventsInitial());


  @override
  Stream<EventsStates> mapEventToState(EventsEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewEventsEvent){
      yield EventsLoading();
      try{
        final events=await viewEventsRepository.fetchEvents(event.apiToken);
        yield EventsLoaded(events);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeDateFromEvent){
      yield DateFromChanged(event.from);
    }else if(event is ChangeDateToEvent){
      yield DateToChanged(event.to);
    }else if(event is AddSchoolEvent){
      yield EventsLoading();
      try{
        final message=await eventRepository.addSchoolEvent(title: event.title, description: event.description, startDate: event.startDate, endDate: event.endDate);
        yield EventAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateSchoolEvent){
      yield EventsLoading();
      try{
        final message=await eventRepository.updateSchoolEvent(id:event.id, title: event.title, description: event.description, startDate: event.startDate, endDate: event.endDate);
        yield EventUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteSchoolEvent){
      yield EventsLoading();
      try{
        final message=await viewEventsRepository.deleteEvents(event.id);
        yield EventDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }
}