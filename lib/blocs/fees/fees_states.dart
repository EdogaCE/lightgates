import 'package:equatable/equatable.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';

abstract class FeesStates extends Equatable{
  const FeesStates();
}

class FeesInitial extends FeesStates{
  const FeesInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Loading extends FeesStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends FeesStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class FeesRecordLoaded extends FeesStates{
  final List<FeesRecord> feesRecord;
  const FeesRecordLoaded(this.feesRecord);
  @override
  // TODO: implement props
  List<Object> get props => [feesRecord];
}

class ParticularFeesRecordLoaded extends FeesStates{
  final List<Teachers> salaryRecord;
  const ParticularFeesRecordLoaded(this.salaryRecord);
  @override
  // TODO: implement props
  List<Object> get props => [salaryRecord];
}

class FeeRecordCreated extends FeesStates{
  final String message;
  const FeeRecordCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeeRecordUpdated extends FeesStates{
  final String message;
  const FeeRecordUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeeRecordDeleted extends FeesStates{
  final String message;
  const FeeRecordDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeeRecordRestored extends FeesStates{
  final String message;
  const FeeRecordRestored(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeeDeleted extends FeesStates{
  final String message;
  const FeeDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class StudentFeesRecordUpdated extends FeesStates{
  final String message;
  const StudentFeesRecordUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class SessionsLoaded extends FeesStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends FeesStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class TermsLoaded extends FeesStates{
  final List<List<String>> terms;
  const TermsLoaded(this.terms);
  @override
  // TODO: implement props
  List<Object> get props => [terms];
}

class TermSelected extends FeesStates{
  final String term;
  const TermSelected(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];

}

class ClassesLoaded extends FeesStates{
  final List<List<String>> classes;
  const ClassesLoaded(this.classes);
  @override
  // TODO: implement props
  List<Object> get props => [classes];
}

class ClassSelected extends FeesStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class TypeSelected extends FeesStates{
  final String type;
  const TypeSelected(this.type);
  @override
  // TODO: implement props
  List<Object> get props => [type];

}

class DivisionSelected extends FeesStates{
  final String division;
  const DivisionSelected(this.division);
  @override
  // TODO: implement props
  List<Object> get props => [division];

}

class FeesLoaded extends FeesStates{
  final List<Fees> fees;
  const FeesLoaded(this.fees);
  @override
  // TODO: implement props
  List<Object> get props => [fees];
}

class FeeCreated extends FeesStates{
  final String message;
  const FeeCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeeUpdated extends FeesStates{
  final String message;
  const FeeUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeesPaymentsLoaded extends FeesStates{
  final List<Students> students;
  const FeesPaymentsLoaded(this.students);
  @override
  // TODO: implement props
  List<Object> get props => [students];
}

class FeePaymentConfirmed extends FeesStates{
  final String message;
  const FeePaymentConfirmed(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class StudentDeactivated extends FeesStates{
  final String message;
  const StudentDeactivated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeesViewError extends FeesStates{
  final String message;
  const FeesViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FeesNetworkErr extends FeesStates{
  final String message;
  const FeesNetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}