import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class SubPayment extends Equatable {
  final String id;
  final String uniqueId;
  final String salary;
  String bonus;
  final String paymentStatus;
  final String bankAccountNumber;
  final String bankCode;
  final String datePaid;
  bool payAccount;

  SubPayment(
      {this.id,
        this.uniqueId,
        this.salary,
        this.bonus='0',
        this.paymentStatus,
        this.bankAccountNumber,
        this.bankCode,
        this.datePaid,
        this.payAccount=false
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    salary,
    bonus,
    paymentStatus,
    bankAccountNumber,
    bankCode,
    datePaid,
    payAccount
  ];
}
