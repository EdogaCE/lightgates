import 'package:equatable/equatable.dart';

class StudentResult extends Equatable {
  final String fileName;
  final String downloadLink;
  StudentResult(
      {this.fileName,
        this.downloadLink});

  @override
  // TODO: implement props
  List<Object> get props => [
    fileName,
    downloadLink
  ];
}
