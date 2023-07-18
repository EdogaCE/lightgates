import 'package:equatable/equatable.dart';
import 'package:school_pal/models/students.dart';

abstract class PickUpIdStates extends Equatable{
  const PickUpIdStates();
}

class PickUpIdInitialState extends PickUpIdStates{
  const PickUpIdInitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}
class IdVisibilityState extends PickUpIdStates{
  final bool visibility;
  const IdVisibilityState(this.visibility);
  @override
  // TODO: implement props
  List<Object> get props => [visibility];
}

class VerifyingPickUpId extends PickUpIdStates{
  const VerifyingPickUpId();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GeneratingPickUpId extends PickUpIdStates{
  const GeneratingPickUpId();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PickUpIdVerified extends PickUpIdStates{
  final Students student;
  const PickUpIdVerified(this.student);
  @override
  // TODO: implement props
  List<Object> get props => [student];
}

class PickUpIdGenerated extends PickUpIdStates{
  final String pickUpId;
  const PickUpIdGenerated(this.pickUpId);
  @override
  // TODO: implement props
  List<Object> get props => [pickUpId];
}

class VerificationError extends PickUpIdStates{
  final String message;
  const VerificationError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends PickUpIdStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}
