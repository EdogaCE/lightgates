import 'package:equatable/equatable.dart';

abstract class SalaryEvents extends Equatable{
  const SalaryEvents();
}

class ViewSalaryRecordEvent extends SalaryEvents{
  final String apiToken;
  const ViewSalaryRecordEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class ViewParticularSalaryRecordEvent extends SalaryEvents{
  final String recordId;
  const ViewParticularSalaryRecordEvent(this.recordId);
  @override
  // TODO: implement props
  List<Object> get props => [recordId];

}

class CreateSalaryRecordEvent extends SalaryEvents{
  final String paymentFrequency;
  final String sessionId;
  final String termId;
  final String startDate;
  final String endDate;
  final String title;
  final String description;
  const CreateSalaryRecordEvent(this.paymentFrequency, this.sessionId, this.termId, this.startDate, this.endDate, this.title, this.description);
  @override
  // TODO: implement props
  List<Object> get props => [paymentFrequency, sessionId, termId, startDate, endDate, title, description];

}

class UpdateSalaryRecordEvent extends SalaryEvents{
  final String recordId;
  final String paymentFrequency;
  final String sessionId;
  final String termId;
  final String startDate;
  final String endDate;
  final String title;
  final String description;
  const UpdateSalaryRecordEvent(this.recordId, this.paymentFrequency, this.sessionId, this.termId, this.startDate, this.endDate, this.title, this.description);
  @override
  // TODO: implement props
  List<Object> get props => [recordId, paymentFrequency, sessionId, termId, startDate, endDate, title, description];

}

class UpdateTeacherSalaryRecordEvent extends SalaryEvents{
  final String paymentId;
  final String paymentStatus;
  const UpdateTeacherSalaryRecordEvent(this.paymentId, this.paymentStatus);
  @override
  // TODO: implement props
  List<Object> get props => [paymentId, paymentStatus];

}

class PayTeachersSalaryEvent extends SalaryEvents{
  final String paymentId;
  final List<String> idForPaymentsToBeUpdated;
  final List<String> salary;
  final List<String> bonus;
  final List<String> paymentStatus;
  const PayTeachersSalaryEvent(
      {this.paymentId,
      this.idForPaymentsToBeUpdated,
      this.salary,
      this.bonus,
      this.paymentStatus});
  @override
  // TODO: implement props
  List<Object> get props => [paymentId, idForPaymentsToBeUpdated, salary, bonus, paymentStatus];

}

class GetSessionsEvent extends SalaryEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends SalaryEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetTermsEvent extends SalaryEvents{
  final String apiToken;
  const GetTermsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectTermEvent extends SalaryEvents{
  final String term;
  const SelectTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ChangeDateFromEvent extends SalaryEvents{
  final DateTime from;
  const ChangeDateFromEvent(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class ChangeDateToEvent extends SalaryEvents{
  final DateTime to;
  const ChangeDateToEvent(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class SelectFrequencyEvent extends SalaryEvents{
  final String frequency;
  const SelectFrequencyEvent(this.frequency);
  @override
  // TODO: implement props
  List<Object> get props => [frequency];

}

class SelectTeacherEvent extends SalaryEvents{
  final bool isSelected;
  final int index;
  const SelectTeacherEvent({this.isSelected, this.index});
  @override
  // TODO: implement props
  List<Object> get props => [isSelected, index];

}