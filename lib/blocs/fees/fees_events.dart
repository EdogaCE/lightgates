import 'package:equatable/equatable.dart';

abstract class FeesEvents extends Equatable{
  const FeesEvents();
}

class ViewFeesRecordEvent extends FeesEvents{
  final String apiToken;
  const ViewFeesRecordEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewParticularFeeRecordEvent extends FeesEvents{
  final String recordId;
  const ViewParticularFeeRecordEvent(this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId];

}

class CreateFeeRecordEvent extends FeesEvents{
  final String title;
  final String type;
  final String description;
  final String termId;
  final String sessionId;
  const CreateFeeRecordEvent(this.title, this.type, this.description, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [title, type, description, termId, sessionId];

}

class UpdateFeeRecordEvent extends FeesEvents{
  final String recordId;
  final String title;
  final String type;
  final String description;
  final String termId;
  final String sessionId;
  const UpdateFeeRecordEvent(this.recordId, this.title, this.type, this.description, this.termId, this.sessionId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId, title, type, description, termId, sessionId];

}

class DeleteFeeRecordEvent extends FeesEvents{
  final String recordId;
  const DeleteFeeRecordEvent(this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId];

}

class RestoreFeeRecordEvent extends FeesEvents{
  final String recordId;
  const RestoreFeeRecordEvent(this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId];

}


class GetSessionsEvent extends FeesEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends FeesEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetTermsEvent extends FeesEvents{
  final String apiToken;
  const GetTermsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectTermEvent extends FeesEvents{
  final String term;
  const SelectTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class GetClassEvent extends FeesEvents{
  final String apiToken;
  const GetClassEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectClassEvent extends FeesEvents{
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class SelectTypeEvent extends FeesEvents{
  final String type;
  const SelectTypeEvent(this.type);
  @override
  // TODO: implement props
  List<Object> get props => [type];

}

class SelectDivisionEvent extends FeesEvents{
  final String division;
  const SelectDivisionEvent(this.division);
  @override
  // TODO: implement props
  List<Object> get props => [division];

}

class ViewFeesEvent extends FeesEvents{
  final String apiToken;
  final String recordId;
  const ViewFeesEvent(this.apiToken, this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, recordId];

}

class DeleteFeeEvent extends FeesEvents{
  final String recordId;
  final String feeId;
  const DeleteFeeEvent(this.feeId, this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [feeId];

}

class CreateFeeEvent extends FeesEvents{
  final String recordId;
  final String title;
  final String division;
  final String amount;
  final String classId;
  const CreateFeeEvent(this.recordId, this.title, this.division, this.amount, this.classId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId, title, division, amount, classId];
}

class UpdateFeeEvent extends FeesEvents{
  final String recordId;
  final String feeId;
  final String title;
  final String division;
  final String amount;
  final String classId;
  const UpdateFeeEvent(this.feeId, this.recordId, this.title, this.division, this.amount, this.classId);
  @override
  // TODO: implement props
  List<Object> get props => [feeId, recordId, title, division, amount, classId];
}

class ViewFeesPaymentsEvent extends FeesEvents{
  final String apiToken;
  final String recordId;
  const ViewFeesPaymentsEvent(this.apiToken, this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, recordId];

}

class ViewOutstandingFeesPaymentsEvent extends FeesEvents{
  final String apiToken;
  final String recordId;
  const ViewOutstandingFeesPaymentsEvent(this.apiToken, this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, recordId];

}

class ViewFeesPaymentsByDateEvent extends FeesEvents{
  final String apiToken;
  final String recordId;
  final String dateFrom;
  final String dateTo;
  const ViewFeesPaymentsByDateEvent(this.apiToken, this.recordId, this.dateFrom, this.dateTo);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, recordId, dateFrom, dateTo];

}

class ViewStudentFeesEvent extends FeesEvents{
  final String apiToken;
  final String studentId;
  const ViewStudentFeesEvent(this.apiToken, this.studentId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, studentId];

}

class ConfirmFeesPaymentEvent extends FeesEvents{
  final String recordId;
  final String feePaymentId;
  const ConfirmFeesPaymentEvent(this.recordId, this.feePaymentId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId, feePaymentId];

}

class DeactivateDefaultStudentEvent extends FeesEvents{
  final String recordId;
  final String studentId;
  const DeactivateDefaultStudentEvent(this.recordId, this.studentId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId, studentId];

}