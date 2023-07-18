import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/tickets/tickets.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_tickets_with_comments.dart';
import 'package:school_pal/requests/posts/create_ticket_request.dart';
import 'package:school_pal/res/strings.dart';

class TicketsBloc extends Bloc<TicketsEvents, TicketsStates>{
  final ViewTicketsRepository viewTicketsRepository;
  final CreateTicketRepository createTicketRepository;
  TicketsBloc({this.viewTicketsRepository, this.createTicketRepository}) : super(TicketsInitial());


  @override
  Stream<TicketsStates> mapEventToState(TicketsEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewTicketsEvent){
      yield Loading();
      try{
        final tickets=await viewTicketsRepository.fetchTicket(event.apiToken);
        yield TicketsLoaded(tickets);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewTicketCategoriesEvent){
      yield Loading();
      try{
        final ticketCategories=await viewTicketsRepository.fetchTicketCategories(event.apiToken);
        yield TicketCategoriesLoaded(ticketCategories);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    } else if(event is SelectSpinnerDataEvent){
      yield SpinnerDataSelected(event.selectedData);
    }else if(event is CreateTicketEvent){
      yield Processing();
      try{
        final message=await createTicketRepository.createTicket(title: event.title, categoryId: event.categoryId, message: event.message);
        yield TicketCreated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is CreateTicketCommentEvent){
      yield Processing();
      try{
        final message=await createTicketRepository.createComment(senderId: event.senderId, ticketId: event.ticketId, comment: event.comment);
        yield CommentCreated(message);
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