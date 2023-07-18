import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/notification/notification.dart';
import 'package:school_pal/requests/get/view_notifications_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class NotificationBloc extends Bloc<NotificationEvents, NotificationStates>{
  final ViewNotificationsRepository viewNotificationsRepository;
  NotificationBloc({this.viewNotificationsRepository}) : super(NotificationInitial());


  @override
  Stream<NotificationStates> mapEventToState(NotificationEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewNotificationsEvent){
      yield NotificationsLoading();
      try{
        final notifications=await viewNotificationsRepository.fetchNotifications(apiToken: event.apiToken, receiverType: event.receiverType, localDb: event.localDb);
        yield NotificationsLoaded(notifications);
      } on NetworkError{
        yield NotificationsNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield NotificationsViewError(e.toString());
      }on SystemError{
        yield NotificationsNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewNotificationEvent){
      yield NotificationsLoading();
      try{
        final notification=await viewNotificationsRepository.fetchNotification(apiToken: event.apiToken, notificationId: event.notificationId, receiverType: event.receiverType);
        yield NotificationLoaded(notification);
      } on NetworkError{
        yield NotificationsNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield NotificationsViewError(e.toString());
      }on SystemError{
        yield NotificationsNetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}