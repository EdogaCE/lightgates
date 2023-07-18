import 'package:equatable/equatable.dart';

class WalletRecord extends Equatable {
  final String id;
  final String uniqueId;
  final String amount;
  final String description;
  final String actionType;
  final String status;
  final String reference;
  final bool billPayment;
  final bool deleted;

  WalletRecord(
      {this.id,
        this.uniqueId,
        this.amount,
        this.description,
        this.actionType,
        this.status,
        this.reference,
        this.billPayment,
        this.deleted
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    amount,
    description,
    actionType,
    status,
    reference,
    billPayment,
    deleted
  ];
}
