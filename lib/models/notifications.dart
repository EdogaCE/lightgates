import 'package:equatable/equatable.dart';

class Notifications extends Equatable {
  final String id;
  final String uniqueId;
  final String title;
  final String description;
  final String link;
  final String notificationType;
  final String typeOfReceiver;
  final bool read;
  final bool deleted;

  Notifications(
      {this.id,
        this.uniqueId,
        this.title,
        this.description,
        this.link,
        this.notificationType,
        this.typeOfReceiver,
        this.read,
        this.deleted
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    title,
    description,
    link,
    notificationType,
    typeOfReceiver,
    read,
    deleted
  ];
}
