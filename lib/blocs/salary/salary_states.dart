import 'package:equatable/equatable.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/models/teachers.dart';

abstract class SalaryStates extends Equatable{
  const SalaryStates();
}

class SalaryInitial extends SalaryStates{
  const SalaryInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SalaryLoading extends SalaryStates{
  const SalaryLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends SalaryStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SalaryRecordLoaded extends SalaryStates{
  final List<SalaryRecord> salaryRecord;
  const SalaryRecordLoaded(this.salaryRecord);
  @override
  // TODO: implement props
  List<Object> get props => [salaryRecord];
}

class ParticularSalaryRecordLoaded extends SalaryStates{
  final List<Teachers> salaryRecord;
  const ParticularSalaryRecordLoaded(this.salaryRecord);
  @override
  // TODO: implement props
  List<Object> get props => [salaryRecord];
}

class SalaryRecordCreated extends SalaryStates{
  final String message;
  const SalaryRecordCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SalaryRecordUpdated extends SalaryStates{
  final String message;
  const SalaryRecordUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class TeacherSalaryRecordUpdated extends SalaryStates{
  final String message;
  const TeacherSalaryRecordUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SessionsLoaded extends SalaryStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends SalaryStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class TermsLoaded extends SalaryStates{
  final List<List<String>> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermSelected extends SalaryStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class DateFromChanged extends SalaryStates{
  final DateTime from;
  const DateFromChanged(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class DateToChanged extends SalaryStates{
  final DateTime to;
  const DateToChanged(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class FrequencySelected extends SalaryStates{
  final String frequency;
  const FrequencySelected(this.frequency);
  @override
  // TODO: implement props
  List<Object> get props => [frequency];

}

class TeacherSelected extends SalaryStates{
  final bool isSelected;
  final int index;
  const TeacherSelected({this.isSelected, this.index});
  @override
  // TODO: implement props
  List<Object> get props => [isSelected, index];

}

class TeachersSalaryPaid extends SalaryStates{
  final String message;
  const TeachersSalaryPaid(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SalaryViewError extends SalaryStates{
  final String message;
  const SalaryViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SalaryNetworkErr extends SalaryStates{
  final String message;
  const SalaryNetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}