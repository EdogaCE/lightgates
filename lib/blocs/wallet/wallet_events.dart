import 'package:equatable/equatable.dart';

abstract class WalletEvents extends Equatable{
  const WalletEvents();
}

class ViewTransactionHistoriesEvent extends WalletEvents{
  const ViewTransactionHistoriesEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class GetFlutterWaveBankCodes extends WalletEvents{
  const GetFlutterWaveBankCodes();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class GetPayStackBankCodes extends WalletEvents{
  const GetPayStackBankCodes();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class SelectBankEvent extends WalletEvents{
  final String bank;
  const SelectBankEvent(this.bank);
  @override
  // TODO: implement props
  List<Object> get props => [bank];

}

class RegisterFlutterWaveSubAccountEvent extends WalletEvents{
  final String accountBank;
  final String accountNumber;
  final String businessName;
  final String businessEmail;
  final String businessAddress;
  final String businessContact1;
  final String businessContact2;
  const RegisterFlutterWaveSubAccountEvent(this.accountBank, this.accountNumber, this.businessName, this.businessEmail, this.businessAddress, this.businessContact1, this.businessContact2);
  @override
  // TODO: implement props
  List<Object> get props => [accountBank, accountNumber, businessName, businessEmail, businessAddress, businessContact1, businessContact2];

}

class RegisterPayStackSubAccountEvent extends WalletEvents{
  final String accountBank;
  final String accountNumber;
  final String businessName;
  final String percentageCharge;
  const RegisterPayStackSubAccountEvent(this.accountBank, this.accountNumber, this.businessName, this.percentageCharge);
  @override
  // TODO: implement props
  List<Object> get props => [accountBank, accountNumber, businessName, percentageCharge];

}


class ViewTransactionHistoryEvent extends WalletEvents{
  final String transactionId;
  const ViewTransactionHistoryEvent(this.transactionId);
  @override
  // TODO: implement props
  List<Object> get props => [transactionId];

}


class ViewFlutterWaveSubAccountEvent extends WalletEvents {
  const ViewFlutterWaveSubAccountEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ViewPayStackSubAccountEvent extends WalletEvents {
  const ViewPayStackSubAccountEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}