import 'package:equatable/equatable.dart';
import 'package:school_pal/models/notifications.dart';

abstract class NotificationStates extends Equatable{
  const NotificationStates();
}

class NotificationInitial extends NotificationStates{
  const NotificationInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class NotificationsLoading extends NotificationStates{
  const NotificationsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class NotificationsProcessing extends NotificationStates{
  const NotificationsProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}


class NotificationsLoaded extends NotificationStates{
  final List<Notifications> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  // TODO: implement props
  List<Object> get props => [notifications];
}

class NotificationLoaded extends NotificationStates{
  final Notifications notification;
  const NotificationLoaded(this.notification);
  @override
  // TODO: implement props
  List<Object> get props => [notification];
}

class NotificationsViewError extends NotificationStates{
  final String message;
  const NotificationsViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NotificationsNetworkErr extends NotificationStates{
  final String message;
  const NotificationsNetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}