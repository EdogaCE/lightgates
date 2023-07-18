import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Contact extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String userName;
  final String admissionNumber;
  final String classDetails;
  final String passport;
  final String passportLink;
  final String emailAddress;
  final String phone;
  final String userType;
  final String userUniqueId;
  final String status;
  final String date;
  final bool deleted;

  Contact({
    @required this.id,
    @required this.uniqueId,
    @required this.schoolId,
    @required this.userName,
    this.admissionNumber,
    this.classDetails,
    this.passport,
    this.passportLink,
    this.emailAddress,
    this.phone,
    this.userType,
    this.userUniqueId,
    this.status,
    this.date,
    this.deleted
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    schoolId,
    userName,
    admissionNumber,
    classDetails,
    passport,
    passportLink,
    emailAddress,
    phone,
    userType,
    userUniqueId,
    status,
    date,
    deleted
  ];
}