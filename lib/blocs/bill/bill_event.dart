import 'package:equatable/equatable.dart';
import 'package:school_pal/models/top_up.dart';

abstract class BillEvents extends Equatable{
  const BillEvents();
}


class ViewBillCategoriesEvent extends BillEvents{
  final String apiToken;
  const ViewBillCategoriesEvent({this.apiToken});
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectBillCategoryEvent extends BillEvents{
  final TopUp topUp;
  const SelectBillCategoryEvent({this.topUp});
  @override
  // TODO: implement props
  List<Object> get props => [topUp];

}

class PayBillEvent extends BillEvents{
  final String customer;
  final String amount;
  final String billCategoryKey;
  const PayBillEvent({this.customer, this.amount, this.billCategoryKey});
  @override
  // TODO: implement props
  List<Object> get props => [customer, amount, billCategoryKey];

}