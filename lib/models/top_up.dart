import 'package:equatable/equatable.dart';

class TopUp extends Equatable {
  final String id;
  final String uniqueId;
  final String billerCode;
  final String name;
  final String defaultCommission;
  final String country;
  final bool isAirtime;
  final String billerName;
  final String itemCode;
  final String shortName;
  final String fee;
  final String commissionOnFee;
  final String labelName;
  final String amount;
  final String description;

  TopUp(
      {this.id,
      this.uniqueId,
      this.billerCode,
      this.name,
      this.defaultCommission,
      this.country,
      this.isAirtime,
      this.billerName,
      this.itemCode,
      this.shortName,
      this.fee,
      this.commissionOnFee,
      this.labelName,
      this.amount,
      this.description});

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        uniqueId,
        billerCode,
        name,
        defaultCommission,
        country,
        isAirtime,
        billerName,
        itemCode,
        shortName,
        fee,
        commissionOnFee,
        labelName,
        amount,
        description
      ];
}
