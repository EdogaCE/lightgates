import 'package:equatable/equatable.dart';
import 'package:school_pal/models/top_up.dart';

abstract class BillStates extends Equatable{
  const BillStates();
}

class InitialState extends BillStates{
  const InitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class Loading extends BillStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends BillStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BillCategoriesLoaded extends BillStates{
  final List<TopUp> topUp;
  const BillCategoriesLoaded(this.topUp);
  @override
  // TODO: implement props
  List<Object> get props => [topUp];
}

class BillCategorySelected extends BillStates{
  final TopUp topUp;
  const BillCategorySelected(this.topUp);
  @override
  // TODO: implement props
  List<Object> get props => [topUp];
}

class BillPaid extends BillStates{
  final String message;
  const BillPaid(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends BillStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends BillStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}
