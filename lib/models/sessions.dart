import 'package:equatable/equatable.dart';

class Sessions extends Equatable {
  final String id;
  final String uniqueId;
  final String sessionDate;
  final String startAndEndDate;
  final String status;
  final String admissionNumberPrefix;

  Sessions(
      {this.id,
      this.uniqueId,
      this.sessionDate,
      this.startAndEndDate,
      this.status,
      this.admissionNumberPrefix});

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        uniqueId,
        sessionDate,
        startAndEndDate,
        status,
        admissionNumberPrefix
      ];
}
