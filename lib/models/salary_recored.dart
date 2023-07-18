import 'package:equatable/equatable.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/terms.dart';

class SalaryRecord extends Equatable {
  final String id;
  final String uniqueId;
  final String frequency;
  final String title;
  final String description;
  final String date;
  final Terms terms;
  final Sessions sessions;

  SalaryRecord(
      {this.id,
        this.uniqueId,
        this.frequency,
        this.title,
        this.description,
        this.date,
      this.terms,
      this.sessions});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    frequency,
    title,
    description,
    date,
    terms,
    sessions
  ];
}
