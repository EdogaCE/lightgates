import 'package:equatable/equatable.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_payment_detail.dart';

class FeesPayment extends Equatable {
  final String id;
  final String uniqueId;
  final String studentId;
  final String recordId;
  final String totalAmount;
  final String amountPaid;
  final String balance;
  final String status;
  final bool deleted;
  final List<Fees> fees;
  final List<FeesPaymentDetail> paymentDetails;

  FeesPayment(
      {this.id,
        this.uniqueId,
        this.studentId,
        this.recordId,
        this.totalAmount,
        this.amountPaid,
        this.balance,
        this.status,
        this.deleted,
        this.fees,
        this.paymentDetails
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    studentId,
    recordId,
    totalAmount,
    amountPaid,
    balance,
    status,
    deleted,
    fees,
    paymentDetails
  ];
}
