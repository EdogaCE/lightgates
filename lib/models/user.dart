import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class User extends Equatable {
  final String logoName;
  final String appName;
  final String id;
  final String uniqueId;
  final String userName;
  final String contactPhone;
  final String contactEmail;
  final String address;
  final String town;
  final String lga;
  final String city;
  final String nationality;
  final String image;
  final String apiToken;
  final bool isFormTeacher;
  final String userChatId;
  final String userChatType;
  final String assessmentsCount;
  final String learningMaterialsCount;
  final String eventsCount;
  final String pendingFees;
  final String pendingResultsCount;
  final String confirmedResultsCount;
  final String numberOfClassTeaching;
  final String numberOfClassForming;
  final String numberOfStudents;
  final String numberOfTeachers;
  final String numberOfSubjects;
  final String confirmedFees;
  final bool verificationStatus;
  final String videoForVerification;
  final bool firstTimeLogin;
  final String firstTimeSetupPage;

  User({
    @required this.logoName,
    @required this.appName,
    this.id,
    this.uniqueId,
    this.userName,
    this.contactPhone,
    this.contactEmail,
    this.address,
    this.town,
    this.lga,
    this.city,
    this.nationality,
    this.image,
    this.apiToken,
    this.isFormTeacher,
    this.userChatId,
    this.userChatType,
    this.assessmentsCount,
    this.learningMaterialsCount,
    this.eventsCount,
    this.pendingFees,
    this.confirmedFees,
    this.numberOfSubjects,
    this.numberOfTeachers,
    this.numberOfStudents,
    this.numberOfClassForming,
    this.numberOfClassTeaching,
    this.confirmedResultsCount,
    this.pendingResultsCount,
    this.verificationStatus,
    this.firstTimeLogin,
    this.videoForVerification,
    this.firstTimeSetupPage
  });

  @override
  List<Object> get props => [
    logoName,
    appName,
    id,
    uniqueId,
    userName,
    contactPhone,
    contactEmail,
    address,
    town,
    lga,
    city,
    nationality,
    image,
    apiToken,
    isFormTeacher,
    userChatId,
    userChatType,
    assessmentsCount,
    learningMaterialsCount,
    eventsCount,
    pendingFees,
    confirmedFees,
    numberOfSubjects,
    numberOfTeachers,
    numberOfStudents,
    numberOfClassForming,
    numberOfClassTeaching,
    confirmedResultsCount,
    pendingResultsCount,
    verificationStatus,
    firstTimeLogin,
    videoForVerification,
    firstTimeSetupPage
  ];
}