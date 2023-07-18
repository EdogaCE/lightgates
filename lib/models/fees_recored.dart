import 'package:equatable/equatable.dart';

class FeesRecord extends Equatable {
  final String id;
  final String uniqueId;
  final String title;
  final String type;
  final String description;
  final String date;
  final String sessionId;
  final String termId;
  final bool deleted;

  FeesRecord(
      {this.id,
        this.uniqueId,
        this.title,
        this.description,
        this.type,
        this.date,
        this.sessionId,
        this.termId,
        this.deleted
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    title,
    description,
    type,
    date,
    sessionId,
    termId,
    deleted
  ];
}
