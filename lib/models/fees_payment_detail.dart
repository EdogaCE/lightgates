import 'package:equatable/equatable.dart';
import 'package:school_pal/models/fees.dart';

class FeesPaymentDetail extends Equatable {
  final String id;
  final String uniqueId;
  final String feeId;
  final String amountPaid;
  final String paymentOption;
  final String paymentProof;
  final String status;
  final bool deleted;
  final String paymentProofLink;

  FeesPaymentDetail(
      {this.id,
        this.uniqueId,
        this.feeId,
        this.amountPaid,
        this.paymentOption,
        this.paymentProof,
        this.status,
        this.deleted,
        this.paymentProofLink
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    feeId,
    amountPaid,
    paymentOption,
    paymentProof,
    status,
    deleted,
    paymentProofLink
  ];
}
