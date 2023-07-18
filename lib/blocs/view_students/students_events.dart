import 'package:equatable/equatable.dart';

abstract class StudentsEvents extends Equatable{
  const StudentsEvents();
}

class ViewStudentsEvent extends StudentsEvents{
  final String apiToken;
  final bool localDb;
  const ViewStudentsEvent({this.apiToken, this.localDb});
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, localDb];

}

class DeleteStudentEvent extends StudentsEvents {
  final String studentId;
  const DeleteStudentEvent(this.studentId);
  @override
  // TODO: implement props
  List<Object> get props => [studentId];

}