import 'package:equatable/equatable.dart';

abstract class SubjectsEvents extends Equatable{
  const SubjectsEvents();
}

class ViewSubjectsEvent extends SubjectsEvents{
  final String apiToken;
  const ViewSubjectsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}


class AddSubjectEvent extends SubjectsEvents {
  final String title;
  const AddSubjectEvent(this.title);
  @override
  // TODO: implement props
  List<Object> get props => [title];
}

class EditSubjectEvent extends SubjectsEvents {
  final String id;
  final String title;
  const EditSubjectEvent(this.id, this.title);
  @override
  // TODO: implement props
  List<Object> get props => [id, title];
}

class DeleteSubjectEvent extends SubjectsEvents {
  final String id;
  const DeleteSubjectEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];
}