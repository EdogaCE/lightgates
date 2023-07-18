import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String id;
  final String uniqueId;
  final String baseCurrency;
  final String secondCurrency;
  final String rateOfConversion;
  final String expression;
  final String countryName;
  final String countryAbr;
  final String currencyName;
  final bool deleted;

  Currency(
      {this.id,
        this.uniqueId,
        this.baseCurrency,
        this.secondCurrency,
        this.rateOfConversion,
        this.expression,
        this.countryName,
        this.countryAbr,
        this.currencyName,
        this.deleted
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    baseCurrency,
    secondCurrency,
    rateOfConversion,
    expression,
    countryName,
    countryAbr,
    currencyName,
    deleted
  ];
}
