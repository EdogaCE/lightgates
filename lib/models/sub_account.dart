import 'package:equatable/equatable.dart';

class SubAccount extends Equatable {
  final String id;
  final String accountNumber;
  final String accountBank;
  final String businessName;
  final String fullName;
  final String bankName;
  final String country;
  final String email;
  final String address;
  final String phoneOne;
  final String phoneTwo;

  SubAccount(
      {this.id,
        this.accountNumber,
        this.accountBank,
        this.businessName,
        this.fullName,
        this.bankName,
        this.country,
        this.email,
        this.address,
        this.phoneOne,
        this.phoneTwo
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    accountNumber,
    accountBank,
    businessName,
    fullName,
    bankName,
    country,
    email,
    address,
    phoneOne,
    phoneTwo
  ];
}
