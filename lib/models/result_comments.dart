import 'package:equatable/equatable.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/terms.dart';

class ResultComments extends Equatable {
  final String id;
  final String uniqueId;
  final String startLimit;
  final String endLimit;
  final String remark;
  final Classes classes;
  final Sessions session;
  final Terms term;
  final bool deleted;


  ResultComments(
      {this.id,
        this.uniqueId,
        this.startLimit,
        this.endLimit,
        this.remark,
        this.classes,
        this.session,
        this.term,
        this.deleted});

  @override
  // TODO: implement props
  List<Object> get props =>
      [id, uniqueId, startLimit, endLimit, remark, classes, session, term, deleted];
}
