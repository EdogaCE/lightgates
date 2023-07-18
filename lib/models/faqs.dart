import 'package:equatable/equatable.dart';

class FAQs extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String question;
  final String answer;
  final String date;

  FAQs(
      {this.id,
        this.uniqueId,
        this.schoolId,
        this.question,
        this.answer,
        this.date,});

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    schoolId,
    question,
    answer,
    date,
  ];
}
