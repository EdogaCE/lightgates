import 'package:equatable/equatable.dart';

abstract class SchoolEvents extends Equatable {
  const SchoolEvents();
}

class ViewSessionsEvent extends SchoolEvents {
  final String apiToken;
  const ViewSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class ActivateSessionEvent extends SchoolEvents {
  final String id;
  const ActivateSessionEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];
}

class ViewTermsEvent extends SchoolEvents {
  final String apiToken;
  const ViewTermsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class ActivateTermEvent extends SchoolEvents {
  final String termId;
  final String sessionId;
  final String startDate;
  final String endDate;
  const ActivateTermEvent(
      this.termId, this.sessionId, this.startDate, this.endDate);
  @override
  // TODO: implement props
  List<Object> get props => [termId, sessionId, startDate, endDate];
}

class ViewGradesEvent extends SchoolEvents {
  final String apiToken;
  const ViewGradesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class AddGradeEvent extends SchoolEvents {
  final String grade;
  final String startLimit;
  final String endLimit;
  final String remark;
  const AddGradeEvent(this.grade, this.startLimit, this.endLimit, this.remark);
  @override
  // TODO: implement props
  List<Object> get props => [grade, startLimit, endLimit, remark];
}

class UpdateGradeEvent extends SchoolEvents {
  final String gradeId;
  final String grade;
  final String startLimit;
  final String endLimit;
  final String remark;
  const UpdateGradeEvent(this.gradeId, this.grade, this.startLimit, this.endLimit, this.remark);
  @override
  // TODO: implement props
  List<Object> get props => [gradeId, grade, startLimit, endLimit, remark];
}

class DeleteGradeEvent extends SchoolEvents {
  final String gradeId;
  const DeleteGradeEvent(this.gradeId);
  @override
  // TODO: implement props
  List<Object> get props => [gradeId];
}

class RestoreGradeEvent extends SchoolEvents {
  final String gradeId;
  const RestoreGradeEvent(this.gradeId);
  @override
  // TODO: implement props
  List<Object> get props => [gradeId];
}

class AddSessionEvent extends SchoolEvents {
  final String sessionDate;
  final String sessionStartDate;
  final String sessionEndDate;
  final String admissionNumberPrefix;
  const AddSessionEvent(this.sessionDate, this.sessionStartDate, this.sessionEndDate, this.admissionNumberPrefix);
  @override
  // TODO: implement props
  List<Object> get props => [sessionDate, sessionStartDate, sessionEndDate, admissionNumberPrefix];
}

class UpdateSessionEvent extends SchoolEvents {
  final String id;
  final String sessionDate;
  final String sessionStartDate;
  final String sessionEndDate;
  final String admissionNumberPrefix;
  const UpdateSessionEvent(this.id, this.sessionDate, this.sessionStartDate, this.sessionEndDate, this.admissionNumberPrefix);
  @override
  // TODO: implement props
  List<Object> get props => [id, sessionDate, sessionStartDate, sessionEndDate, admissionNumberPrefix];
}

class AddTermEvent extends SchoolEvents {
  final String term;
  const AddTermEvent(this.term);
  @override
  // TODO: implement props
  List<Object> get props => [term];
}

class UpdateTermEvent extends SchoolEvents {
  final String id;
  final String term;
  const UpdateTermEvent(this.id, this.term);
  @override
  // TODO: implement props
  List<Object> get props => [id, term];
}

class ReorderTermEvent extends SchoolEvents {
  final int oldIndex;
  final int newIndex;
  const ReorderTermEvent(this.oldIndex, this.newIndex);
  @override
  // TODO: implement props
  List<Object> get props => [oldIndex, newIndex];
}

class RearrangeTermEvent extends SchoolEvents {
  final List<String> termId;
  const RearrangeTermEvent(this.termId);
  @override
  // TODO: implement props
  List<Object> get props => [termId];
}
