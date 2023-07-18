import 'package:equatable/equatable.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/wallet_record.dart';

class School extends Equatable {
  final String id;
  final String uniqueId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String town;
  final String lga;
  final String city;
  final String nationality;
  final String slogan;
  final String status;
  final String image;
  final String cacFile;
  final String otherFile;
  final String poBox;
  final String website;
  final String facebook;
  final String instagram;
  final String twitter;
  final String imageLink;
  final String activeSession;
  final String activeTerm;
  final Currency currency;
  final String preferredCurrencyId;
  final WalletRecord walletRecord;
  final String walletBalance;
  final String developerCharge;
  final String resultCommentSwitch;
  final String keyToTraitRating;
  final String numOfTerm;
  final String admissionNumPrefix;
  final String initialAdmissionNum;
  final String numOfCumulativeTest;
  final String testExamScoreLimit;
  final String behaviouralSkillTestsHeadings;
  final bool useCumulativeResult;
  final bool useCustomAdmissionNum;
  final bool useClassCategoryStatus;
  final bool useOfSignatureOnResults;
  final String userChatId;
  final String userChatType;
  final String numberOfStudents;
  final String numberOfTeachers;
  final String numberOfSubjects;
  final String confirmedFees;
  final String pendingFees;
  final bool deleted;
  final String userName;
  final String password;

  School({
    this.id,
    this.uniqueId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.town,
    this.lga,
    this.city,
    this.nationality,
    this.slogan,
    this.status,
    this.image,
    this.cacFile,
    this.otherFile,
    this.poBox,
    this.website,
    this.facebook,
    this.instagram,
    this.twitter,
    this.imageLink,
    this.activeSession,
    this.activeTerm,
    this.currency,
    this.preferredCurrencyId,
    this.walletRecord,
    this.walletBalance,
    this.developerCharge,
    this.resultCommentSwitch,
    this.keyToTraitRating,
    this.numOfTerm,
    this.admissionNumPrefix,
    this.initialAdmissionNum,
    this.numOfCumulativeTest,
    this.testExamScoreLimit,
    this.behaviouralSkillTestsHeadings,
    this.useCumulativeResult,
    this.useCustomAdmissionNum,
    this.useClassCategoryStatus,
    this.useOfSignatureOnResults,
    this.userChatId,
    this.userChatType,
    this.numberOfStudents,
    this.numberOfTeachers,
    this.numberOfSubjects,
    this.pendingFees,
    this.confirmedFees,
    this.deleted,
    this.userName,
    this.password
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    name,
    email,
    phone,
    address,
    town,
    lga,
    city,
    nationality,
    slogan,
    status,
    image,
    cacFile,
    otherFile,
    poBox,
    website,
    facebook,
    instagram,
    twitter,
    imageLink,
    activeSession,
    activeTerm,
    currency,
    preferredCurrencyId,
    walletRecord,
    walletBalance,
    developerCharge,
    resultCommentSwitch,
    keyToTraitRating,
    numOfTerm,
    admissionNumPrefix,
    initialAdmissionNum,
    numOfCumulativeTest,
    testExamScoreLimit,
    behaviouralSkillTestsHeadings,
    useCumulativeResult,
    useCustomAdmissionNum,
    useClassCategoryStatus,
    useOfSignatureOnResults,
    userChatId,
    userChatType,
    numberOfStudents,
    numberOfTeachers,
    numberOfSubjects,
    pendingFees,
    confirmedFees,
    deleted,
    userName,
    password
  ];
}