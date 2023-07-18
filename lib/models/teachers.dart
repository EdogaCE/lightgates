import 'package:equatable/equatable.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/sub_payment.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/terms.dart';

// ignore: must_be_immutable
class Teachers extends Equatable {
  final String id;
  final String uniqueId;
  final String role;
  final String title;
  final String fName;
  final String mName;
  final String lName;
  final String gender;
  final String phone;
  final String email;
  final String passport;
  final String address;
  final String city;
  final String state;
  final String nationality;
  final String salary;
  final String dob;
  final List<String> subjects;
  final List<String> classes;
  final List<String> classSubjectId;
  final List<Subjects> subjectsDetail;
  final List<Classes> classesDetail;
  final String employmentStatus;
  final String passportLink;
  final String activeSession;
  final String activeTerm;
  final SubPayment subPayment;
  final Currency currency;
  final String preferredCurrencyId;
  final String bankCode;
  final String bankName;
  final String bankAccountNumber;
  final List<String> formTeacherAssignId;
  final List<Classes> formClasses;
  final List<Terms> formTerm;
  final List<Sessions> formSession;
  final School school;
  final bool isFormTeacher;
  final String userChatId;
  final String userChatType;
  final String assessmentsCount;
  final String learningMaterialsCount;
  final String pendingResultsCount;
  final String confirmedResultsCount;
  final String numberOfClassTeaching;
  final String numberOfClassForming;
  final String signatoryArea;
  final String signatoryAreaUrl;
  final bool deleted;
  final String userName;
  final String password;

  Teachers({
   this.id,
    this.uniqueId,
    this.role,
    this.title,
    this.fName,
    this.mName,
    this.lName,
    this.gender,
    this.phone,
    this.email,
    this.passport,
    this.address,
    this.city,
    this.state,
    this.nationality,
    this.salary,
    this.dob,
    this.subjects,
    this.classes,
    this.employmentStatus,
    this.passportLink,
    this.activeSession,
    this.activeTerm,
    this.subPayment,
    this.currency,
    this.preferredCurrencyId,
    this.bankCode,
    this.bankName,
    this.bankAccountNumber,
    this.formTeacherAssignId,
    this.formClasses,
    this.formTerm,
    this.formSession,
    this.classSubjectId,
    this.classesDetail,
    this.subjectsDetail,
    this.school,
    this.isFormTeacher,
    this.userChatId,
    this.userChatType,
    this.assessmentsCount,
    this.learningMaterialsCount,
    this.pendingResultsCount,
    this.confirmedResultsCount,
    this.numberOfClassTeaching,
    this.numberOfClassForming,
    this.signatoryArea,
    this.signatoryAreaUrl,
    this.deleted,
    this.userName,
    this.password
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    role,
    title,
    fName,
    mName,
    lName,
    gender,
    phone,
    email,
    passport,
    address,
    city,
    state,
    nationality,
    salary,
    dob,
    subjects,
    classes,
    employmentStatus,
    passportLink,
    activeSession,
    activeTerm,
    subPayment,
    currency,
    preferredCurrencyId,
    bankCode,
    bankName,
    bankAccountNumber,
    formTeacherAssignId,
    formClasses,
    formTerm,
    formSession,
    classSubjectId,
    classesDetail,
    subjectsDetail,
    school,
    isFormTeacher,
    userChatId,
    userChatType,
    assessmentsCount,
    learningMaterialsCount,
    pendingResultsCount,
    confirmedResultsCount,
    numberOfClassTeaching,
    numberOfClassForming,
    signatoryArea,
    signatoryAreaUrl,
    deleted,
    userName,
    password
  ];
}