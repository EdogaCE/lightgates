import 'package:equatable/equatable.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/fees_payment.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';

class Students extends Equatable {
  final String id;
  final String uniqueId;
  final String fName;
  final String mName;
  final String lName;
  final String email;
  final String phone;
  final String gender;
  final String passport;
  final String dob;
  final String bloodGroup;
  final String genotype;
  final String healthHistory;
  final String admissionNumber;
  final String genAdmissionNumber;
  final String residentAddress;
  final String city;
  final String state;
  final String nationality;
  final String stClass;
  final String parentId;
  final String parentName;
  final String parentTitle;
  final String parentPhone;
  final String parentEmail;
  final String parentAddress;
  final String parentPassport;
  final String parentOccupation;
  final String passportLink;
  final String parentPassportLink;
  final String particularSchoolDetails;
  final String activeSession;
  final String activeTerm;
  final Sessions sessions;
  final Classes classes;
  final School school;
  final FeesPayment feesPayment;
  final Currency currency;
  final String preferredCurrencyId;
  final bool boardingStatus;
  final bool deleted;
  final String userChatId;
  final String userChatType;
  final String assessmentsCount;
  final String learningMaterialsCount;
  final String eventsCount;
  final String pendingFees;
  final String userName;
  final String password;

  Students(
      {this.id,
      this.uniqueId,
      this.fName,
      this.mName,
      this.lName,
      this.email,
      this.phone,
      this.gender,
      this.passport,
      this.dob,
      this.bloodGroup,
      this.genotype,
      this.healthHistory,
      this.admissionNumber,
      this.genAdmissionNumber,
      this.residentAddress,
      this.city,
      this.state,
      this.nationality,
      this.stClass,
      this.parentId,
      this.parentName,
      this.parentTitle,
      this.parentPhone,
      this.parentEmail,
      this.parentAddress,
      this.parentPassport,
      this.parentOccupation,
      this.passportLink,
      this.parentPassportLink,
      this.particularSchoolDetails,
      this.activeTerm,
      this.activeSession,
      this.sessions,
      this.classes,
      this.school,
      this.feesPayment,
      this.currency,
      this.preferredCurrencyId,
      this.boardingStatus,
      this.userChatId,
      this.userChatType,
      this.assessmentsCount,
      this.learningMaterialsCount,
      this.eventsCount,
      this.pendingFees,
      this.deleted,
      this.userName,
        this.password
      });

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        uniqueId,
        fName,
        mName,
        lName,
        email,
        phone,
        gender,
        passport,
        dob,
        bloodGroup,
        genotype,
        healthHistory,
        admissionNumber,
        genAdmissionNumber,
        residentAddress,
        city,
        state,
        nationality,
        stClass,
        parentId,
        parentName,
        parentTitle,
        parentPhone,
        parentEmail,
        parentAddress,
        parentPassport,
        parentOccupation,
        passportLink,
        parentPassportLink,
        particularSchoolDetails,
        activeTerm,
        activeSession,
        sessions,
        classes,
        school,
        feesPayment,
        currency,
        preferredCurrencyId,
        boardingStatus,
        userChatId,
        userChatType,
        assessmentsCount,
        learningMaterialsCount,
        eventsCount,
        pendingFees,
        deleted,
        userName,
        password
      ];
}
