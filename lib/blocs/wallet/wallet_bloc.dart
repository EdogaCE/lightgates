import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/wallet/wallet.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/get/view_wallet_request.dart';
import 'package:school_pal/requests/posts/wallet_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class WalletBloc extends Bloc<WalletEvents, WalletStates>{
  final ViewWalletRepository viewWalletRepository;
  final WalletRepository walletRepository;
  WalletBloc({this.viewWalletRepository, this.walletRepository}) : super(WalletInitial());

  @override
  Stream<WalletStates> mapEventToState(WalletEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewTransactionHistoriesEvent){
      yield WalletLoading();
      try{
        final school=await viewWalletRepository.fetchTransactionHistories();
        yield TransactionHistoriesLoaded(school);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetFlutterWaveBankCodes){
      yield WalletLoading();
      try{
        final banks=await getFlutterWaveBankCodesSpinnerValue();
        yield BanksLoaded(banks);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is GetPayStackBankCodes){
      yield WalletLoading();
      try{
        final banks=await getPayStackBankCodesSpinnerValue();
        yield BanksLoaded(banks);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectBankEvent){
      yield BankSelected(event.bank);
    }else if(event is RegisterFlutterWaveSubAccountEvent){
      yield WalletProcessing();
      try{
        final message=await walletRepository.createFlutterWaveSubAccount(accountBank: event.accountBank, accountNumber: event.accountNumber, businessName: event.businessName, businessEmail: event.businessEmail, businessAddress: event.businessAddress, businessContact1: event.businessContact1, businessContact2: event.businessContact2);
        yield SubAccountRegistered(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is RegisterPayStackSubAccountEvent){
      yield WalletProcessing();
      try{
        final message=await walletRepository.createPayStackSubAccount(accountBank: event.accountBank, accountNumber: event.accountNumber, businessName: event.businessName, percentageCharge: event.percentageCharge);
        yield SubAccountRegistered(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }

    }else if(event is ViewTransactionHistoryEvent){
      yield WalletProcessing();
      try{
        final url=await viewWalletRepository.fetchTransactionHistory(transactionId: event.transactionId);
        yield TransactionHistoryLoaded(url);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewFlutterWaveSubAccountEvent){
      yield WalletLoading();
      try{
        final subAccount=await viewWalletRepository.fetchFlutterWaveSubAccount();
        yield SubAccountLoaded(subAccount);
      }   on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewPayStackSubAccountEvent){
      yield WalletLoading();
      try{
        final subAccount=await viewWalletRepository.fetchPayStackSubAccount();
        yield SubAccountLoaded(subAccount);
      }   on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}