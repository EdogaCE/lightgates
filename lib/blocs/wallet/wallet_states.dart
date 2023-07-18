import 'package:equatable/equatable.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sub_account.dart';

abstract class WalletStates extends Equatable{
  const WalletStates();
}

class WalletInitial extends WalletStates{
  const WalletInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WalletLoading extends WalletStates{
  const WalletLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WalletProcessing extends WalletStates{
  const WalletProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class TransactionHistoriesLoaded extends WalletStates{
  final List<School> school;
  const TransactionHistoriesLoaded(this.school);
  @override
  // TODO: implement props
  List<Object> get props => [school];
}

class TransactionHistoryLoaded extends WalletStates{
  final String url;
  const TransactionHistoryLoaded(this.url);
  @override
  // TODO: implement props
  List<Object> get props => [url];
}

class BanksLoaded extends WalletStates{
  final List<List<String>> banks;
  const BanksLoaded(this.banks);
  @override
  // TODO: implement props
  List<Object> get props => [banks];
}

class BankSelected extends WalletStates{
  final String bank;
  const BankSelected(this.bank);
  @override
  // TODO: implement props
  List<Object> get props => [bank];

}

class SubAccountRegistered extends WalletStates{
  final String message;
  const SubAccountRegistered(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class SubAccountLoaded extends WalletStates{
  final SubAccount subAccount;
  const SubAccountLoaded(this.subAccount);
  @override
  // TODO: implement props
  List<Object> get props => [subAccount];
}

class ViewError extends WalletStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends WalletStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}