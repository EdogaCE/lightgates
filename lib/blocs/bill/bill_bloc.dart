import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/bill/bill.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/posts/bill_payment_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class BillBloc extends Bloc<BillEvents, BillStates>{
  BillPaymentRepository billPaymentRepository;
  BillBloc({this.billPaymentRepository}) : super(InitialState());

  @override
  Stream<BillStates> mapEventToState(BillEvents event) async* {
    // TODO: implement mapEventToState
    if(event is ViewBillCategoriesEvent){
      yield Loading();
      try{
        final categories=await getBillCategoriesSpinnerValue(event.apiToken);
        yield BillCategoriesLoaded(categories);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectBillCategoryEvent){
      yield BillCategorySelected(event.topUp);
    }else if(event is PayBillEvent){
      yield Processing();
      try{
        final message=await billPaymentRepository.makePayment(customer: event.customer, amount: event.amount, billCategoryKey: event.billCategoryKey);
        yield BillPaid(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}