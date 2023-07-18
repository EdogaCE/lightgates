import 'package:equatable/equatable.dart';

class AdImpression extends Equatable {
  final String id;
  final String uniqueId;
  final String adUniqueId;
  final String reactorUniqueId;
  final String impression;
  final String amountCharged;
  final String chargeStatus;
  final String dateCreated;
  final bool deleted;

  AdImpression({this.id, this.uniqueId, this.adUniqueId, this.reactorUniqueId, this.impression, this.amountCharged, this.chargeStatus, this.dateCreated, this.deleted});

  @override
  // TODO: implement props
  List<Object> get props => [id, uniqueId, adUniqueId, reactorUniqueId, impression, amountCharged, chargeStatus, dateCreated, deleted];
}
