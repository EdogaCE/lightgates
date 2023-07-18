import 'package:equatable/equatable.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/fees_recored.dart';

class Fees extends Equatable {
  final String id;
  final String uniqueId;
  final String title;
  final String division;
  final String amount;
  final String date;
  final bool deleted;
  final String classId;
  final String recordId;
  final FeesRecord feesRecord;
  final Currency currency;

  Fees(
      {this.id,
        this.uniqueId,
        this.title,
        this.division,
        this.amount,
        this.date,
        this.deleted,
        this.classId,
        this.recordId,
        this.feesRecord,
        this.currency,
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    title,
    division,
    amount,
    date,
    deleted,
    classId,
    recordId,
    feesRecord,
    currency
  ];
}
