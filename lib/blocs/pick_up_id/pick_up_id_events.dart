import 'package:equatable/equatable.dart';

abstract class PickUpIdEvents extends Equatable{
  const PickUpIdEvents();
}

class IdVisibilityEvent extends PickUpIdEvents{
  final bool visibility;
  IdVisibilityEvent(this.visibility);
  @override
  // TODO: implement props
  List<Object> get props => [visibility];
}

class VerifyPickUpIdEvent extends PickUpIdEvents{
  final String pickUpId;
  VerifyPickUpIdEvent(this.pickUpId);
  @override
  // TODO: implement props
  List<Object> get props => [pickUpId];
}

class GeneratePickUpIdEvent extends PickUpIdEvents{
  final String studentId;
  final String password;
  GeneratePickUpIdEvent(this.studentId, this.password);
  @override
  // TODO: implement props
  List<Object> get props => [studentId, password];
}