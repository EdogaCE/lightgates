import 'package:equatable/equatable.dart';

abstract class NotificationEvents extends Equatable{
  const NotificationEvents();
}

class ViewNotificationsEvent extends NotificationEvents{
  final String apiToken;
  final String receiverType;
  final bool localDb;
  const ViewNotificationsEvent(this.apiToken, this.receiverType, this.localDb);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, receiverType, localDb];

}


class ViewNotificationEvent extends NotificationEvents {
  final String apiToken;
  final String notificationId;
  final String receiverType;
  const ViewNotificationEvent(this.apiToken, this.notificationId, this.receiverType);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, notificationId, receiverType];
}