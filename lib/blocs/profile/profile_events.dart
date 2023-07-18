import 'package:equatable/equatable.dart';

abstract class ProfileEvents extends Equatable {
  const ProfileEvents();
}

class ViewDeveloperProfileEvent extends ProfileEvents {
  final String apiToken;
  const ViewDeveloperProfileEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class ViewSchoolProfileEvent extends ProfileEvents {
  final String apiToken;
  const ViewSchoolProfileEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class ViewTeacherProfileEvent extends ProfileEvents {
  final String apiToken;
  final String teacherId;
  const ViewTeacherProfileEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];
}

class ViewStudentProfileEvent extends ProfileEvents {
  final String apiToken;
  final String studentId;
  const ViewStudentProfileEvent(this.apiToken, this.studentId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, studentId];
}

class UpdateSchoolProfileEvent extends ProfileEvents {
  final String schoolId;
  final String name;
  final String contactPhoneNumber;
  final String address;
  final String town;
  final String lga;
  final String city;
  final String nationality;
  final String slogan;
  final String website;
  final String facebook;
  final String instagram;
  final String twitter;
  UpdateSchoolProfileEvent(
      this.schoolId,
      this.name,
      this.contactPhoneNumber,
      this.address,
      this.town,
      this.lga,
      this.city,
      this.nationality,
      this.slogan,
      this.website,
      this.facebook,
      this.instagram,
      this.twitter);
  @override
  // TODO: implement props
  List<Object> get props => [
        schoolId,
        name,
        contactPhoneNumber,
        address,
        town,
        lga,
        city,
        nationality,
        slogan,
        website,
        facebook,
        instagram,
        twitter
      ];
}

class UpdateSchoolSettingsEvent extends ProfileEvents {
  final String schoolId;
  final String poBox;
  final String preferredCurrencyId;
  final String resultCommentSwitch;
  final List<String> traits;
  final List<String> ratings;
  final String numOfTerm;
  final String initialAdmissionNum;
  final String numOfCumulativeTest;
  final List<String> testExamScoreLimit;
  final List<String> behaviouralSkillTestsHeadings;
  final String useCumulativeResult;
  final String useCustomAdmissionNum;
  final String useClassCategoryStatus;
  final String useOfSignatureOnResults;
  UpdateSchoolSettingsEvent(
      this.schoolId,
      this.poBox,
      this.preferredCurrencyId,
      this.resultCommentSwitch,
      this.traits,
      this.ratings,
      this.numOfTerm,
      this.initialAdmissionNum,
      this.numOfCumulativeTest,
      this.testExamScoreLimit,
      this.behaviouralSkillTestsHeadings,
      this.useCumulativeResult,
      this.useCustomAdmissionNum,
      this.useClassCategoryStatus,
      this.useOfSignatureOnResults);
  @override
  // TODO: implement props
  List<Object> get props => [
    schoolId,
    poBox,
    preferredCurrencyId,
    resultCommentSwitch,
    traits,
    ratings,
    numOfTerm,
    initialAdmissionNum,
    numOfCumulativeTest,
    testExamScoreLimit,
    behaviouralSkillTestsHeadings,
    useCumulativeResult,
    useCustomAdmissionNum,
    useClassCategoryStatus,
    useOfSignatureOnResults
  ];
}

class UploadSchoolLogoEvent extends ProfileEvents {
  final String logo64Bit;
  const UploadSchoolLogoEvent(this.logo64Bit);
  @override
  // TODO: implement props
  List<Object> get props => [logo64Bit];
}

class ChangeSchoolPasswordEvent extends ProfileEvents {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const ChangeSchoolPasswordEvent(
      this.oldPassword, this.newPassword, this.confirmPassword);
  @override
  // TODO: implement props
  List<Object> get props => [oldPassword, newPassword, confirmPassword];
}

class VisiblePassword extends ProfileEvents {
  final bool password;
  VisiblePassword(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}

class ChangeDateEvent extends ProfileEvents {
  final DateTime date;
  const ChangeDateEvent(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];
}

class ChangeGenderEvent extends ProfileEvents {
  final String gender;
  const ChangeGenderEvent(this.gender);
  @override
  // TODO: implement props
  List<Object> get props => [gender];
}

class ChangeBloodGroupEvent extends ProfileEvents {
  final String bloodGroup;
  const ChangeBloodGroupEvent(this.bloodGroup);
  @override
  // TODO: implement props
  List<Object> get props => [bloodGroup];
}

class ChangeGenotypeEvent extends ProfileEvents {
  final String genotype;
  const ChangeGenotypeEvent(this.genotype);
  @override
  // TODO: implement props
  List<Object> get props => [genotype];
}

class ChangeTitleEvent extends ProfileEvents {
  final String title;
  const ChangeTitleEvent(this.title);
  @override
  // TODO: implement props
  List<Object> get props => [title];
}

class UploadTeacherImageEvent extends ProfileEvents {
  final String teacherId;
  final String logo64Bit;
  const UploadTeacherImageEvent(this.teacherId, this.logo64Bit);
  @override
  // TODO: implement props
  List<Object> get props => [teacherId, logo64Bit];
}

class UploadTeacherSignatoryEvent extends ProfileEvents {
  final String teacherId;
  final String teacherSignatory;
  const UploadTeacherSignatoryEvent(this.teacherId, this.teacherSignatory);
  @override
  // TODO: implement props
  List<Object> get props => [teacherId, teacherSignatory];
}


class ChangeTeacherPasswordEvent extends ProfileEvents {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const ChangeTeacherPasswordEvent(
      this.oldPassword, this.newPassword, this.confirmPassword);
  @override
  // TODO: implement props
  List<Object> get props => [oldPassword, newPassword, confirmPassword];
}

class CreateTeacherProfileEvent extends ProfileEvents {
  final String role;
  final String title;
  final String firstName;
  final String lastName;
  final String otherNames;
  final String username;
  final String password;
  final String gender;
  final String phone;
  final String email;
  final String contactAddress;
  final String city;
  final String state;
  final String country;
  final String salary;
  final String birthday;
  final String bankCode;
  final String bankName;
  final String bankAccountNumber;
  final String passport;
  CreateTeacherProfileEvent(
      this.role,
      this.title,
      this.firstName,
      this.lastName,
      this.otherNames,
      this.username,
      this.password,
      this.gender,
      this.phone,
      this.email,
      this.contactAddress,
      this.city,
      this.state,
      this.country,
      this.salary,
      this.birthday,
      this.bankCode,
      this.bankName,
      this.bankAccountNumber,
      this.passport);
  @override
  // TODO: implement props
  List<Object> get props => [
        role,
        title,
        firstName,
        lastName,
        otherNames,
        username,
        password,
        gender,
        phone,
        email,
        contactAddress,
        city,
        state,
        country,
        salary,
        birthday,
        bankCode,
        bankName,
        bankAccountNumber,
        passport
      ];
}

class UpdateTeacherProfileEvent extends ProfileEvents {
  final String teacherId;
  final String title;
  final String firstName;
  final String lastName;
  final String otherNames;
  final String gender;
  final String phone;
  final String contactAddress;
  final String city;
  final String state;
  final String country;
  final String birthday;
  final String role;
  final String salary;
  final String preferredCurrencyId;
  final String bankCode;
  final String bankName;
  final String bankAccountNumber;
  UpdateTeacherProfileEvent(
      this.teacherId,
      this.title,
      this.firstName,
      this.lastName,
      this.otherNames,
      this.gender,
      this.phone,
      this.contactAddress,
      this.city,
      this.state,
      this.country,
      this.birthday,
      this.role,
      this.salary,
      this.preferredCurrencyId,
      this.bankCode,
      this.bankName,
      this.bankAccountNumber);
  @override
  // TODO: implement props
  List<Object> get props => [
        teacherId,
        title,
        firstName,
        lastName,
        otherNames,
        gender,
        phone,
        contactAddress,
        city,
        state,
        country,
        birthday,
        role,
        salary,
        preferredCurrencyId,
        bankCode,
        bankName,
        bankAccountNumber
      ];
}

class UploadStudentImageEvent extends ProfileEvents {
  final String studentId;
  final String logo64Bit;
  const UploadStudentImageEvent(this.studentId, this.logo64Bit);
  @override
  // TODO: implement props
  List<Object> get props => [studentId, logo64Bit];
}

class ChangeStudentPasswordEvent extends ProfileEvents {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const ChangeStudentPasswordEvent(
      this.oldPassword, this.newPassword, this.confirmPassword);
  @override
  // TODO: implement props
  List<Object> get props => [oldPassword, newPassword, confirmPassword];
}

class UpdateStudentProfileEvent extends ProfileEvents {
  final String studentId;
  final String firstName;
  final String lastName;
  final String otherNames;
  final String gender;
  final String email;
  final String phone;
  final String contactAddress;
  final String city;
  final String state;
  final String country;
  final String birthday;
  final String bloodGroup;
  final String genotype;
  final String healthHistory;
  final String preferredCurrencyId;
  final String boardingStatus;
  UpdateStudentProfileEvent(
      this.studentId,
      this.firstName,
      this.lastName,
      this.otherNames,
      this.gender,
      this.email,
      this.phone,
      this.contactAddress,
      this.city,
      this.state,
      this.country,
      this.birthday,
      this.bloodGroup,
      this.genotype,
      this.healthHistory,
      this.preferredCurrencyId,
      this.boardingStatus);
  @override
  // TODO: implement props
  List<Object> get props => [
        studentId,
        firstName,
        lastName,
        otherNames,
        gender,
        email,
        phone,
        contactAddress,
        city,
        state,
        country,
        birthday,
        bloodGroup,
        genotype,
        healthHistory,
        preferredCurrencyId,
        boardingStatus
      ];
}

class CreateStudentProfileEvent extends ProfileEvents {
  final String firstName;
  final String lastName;
  final String otherNames;
  final String email;
  final String admissionNUmber;
  final String phone;
  final String contactAddress;
  final String state;
  final String city;
  final String gender;
  final String country;
  final String birthday;
  final String bloodGroup;
  final String genotype;
  final String healthHistory;
  final String boardingStatus;
  final String classId;
  final String sessionId;
  final String parentFullName;
  final String parentTitle;
  final String parentEmail;
  final String parentPhone;
  final String parentAddress;
  final String parentsOccupation;
  CreateStudentProfileEvent(
      {this.firstName,
      this.lastName,
      this.otherNames,
      this.gender,
      this.email,
        this.admissionNUmber,
      this.phone,
      this.contactAddress,
      this.city,
      this.state,
      this.country,
      this.birthday,
      this.bloodGroup,
      this.genotype,
      this.healthHistory,
      this.classId,
      this.sessionId,
      this.boardingStatus,
      this.parentAddress,
      this.parentEmail,
      this.parentPhone,
      this.parentsOccupation,
      this.parentFullName,
      this.parentTitle});
  @override
  // TODO: implement props
  List<Object> get props => [
    firstName,
    lastName,
    otherNames,
    gender,
    email,
    admissionNUmber,
    phone,
    contactAddress,
    city,
    state,
    country,
    birthday,
    bloodGroup,
    genotype,
    healthHistory,
    classId,
    sessionId,
    boardingStatus,
    parentAddress,
    parentEmail,
    parentPhone,
    parentsOccupation,
    parentFullName,
    parentTitle
  ];
}

class UpdateParentProfileEvent extends ProfileEvents {
  final String studentId;
  final String parentId;
  final String parentFullName;
  final String parentTitle;
  final String parentAddress;
  final String parentsOccupation;
  UpdateParentProfileEvent(this.studentId, this.parentId, this.parentFullName,
      this.parentTitle, this.parentAddress, this.parentsOccupation);
  @override
  // TODO: implement props
  List<Object> get props => [
        studentId,
        parentId,
        parentFullName,
        parentTitle,
        parentAddress,
        parentsOccupation
      ];
}

class UploadParentImageEvent extends ProfileEvents {
  final String studentId;
  final String parentId;
  final String logo64Bit;
  const UploadParentImageEvent(this.studentId, this.parentId, this.logo64Bit);
  @override
  // TODO: implement props
  List<Object> get props => [studentId, parentId, logo64Bit];
}

class GetCurrenciesEvent extends ProfileEvents {
  final String apiToken;
  const GetCurrenciesEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];
}

class SelectCurrencyEvent extends ProfileEvents {
  final String currency;
  const SelectCurrencyEvent(this.currency);
  @override
  // TODO: implement props
  List<Object> get props => [currency];
}

class GetFlutterWaveBankCodes extends ProfileEvents {
  const GetFlutterWaveBankCodes();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SelectBankEvent extends ProfileEvents {
  final String bank;
  const SelectBankEvent(this.bank);
  @override
  // TODO: implement props
  List<Object> get props => [bank];
}

class ChangeResultCommentTypeEvent extends ProfileEvents {
  final String value;
  const ChangeResultCommentTypeEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeUseCumulativeEvent extends ProfileEvents {
  final bool value;
  const ChangeUseCumulativeEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeNumberOfTermsEvent extends ProfileEvents {
  final int count;
  const ChangeNumberOfTermsEvent(this.count);
  @override
  // TODO: implement props
  List<Object> get props => [count];
}

class ChangeUseCustomAdmissionNumEvent extends ProfileEvents {
  final bool value;
  const ChangeUseCustomAdmissionNumEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeUseClassCategoryEvent extends ProfileEvents {
  final bool value;
  const ChangeUseClassCategoryEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeUseOfSignatureOnResultsEvent extends ProfileEvents {
  final bool value;
  const ChangeUseOfSignatureOnResultsEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeNumberOfCumulativeTestEvent extends ProfileEvents {
  final int count;
  const ChangeNumberOfCumulativeTestEvent(this.count);
  @override
  // TODO: implement props
  List<Object> get props => [count];
}

class ChangeInitialAdmissionNumEvent extends ProfileEvents {
  final String value;
  const ChangeInitialAdmissionNumEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ChangeScoreLimitEvent extends ProfileEvents {
  final String limit;
  final int position;
  const ChangeScoreLimitEvent(this.limit, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [limit, position];
}

class ChangeBehaviouralSkillEvent extends ProfileEvents {
  final String skill;
  final int position;
  const ChangeBehaviouralSkillEvent(this.skill, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [skill, position];
}

class AddBehaviouralSkillsEvent extends ProfileEvents {
  final String skill;
  const AddBehaviouralSkillsEvent(this.skill);
  @override
  // TODO: implement props
  List<Object> get props => [skill];
}

class RemoveBehaviouralSkillsEvent extends ProfileEvents {
  final int position;
  const RemoveBehaviouralSkillsEvent(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];
}

class ChangeTraitRatingEvent extends ProfileEvents {
  final String trait;
  final String rating;
  final int position;
  const ChangeTraitRatingEvent(this.trait, this.rating, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [trait, rating, position];
}

class AddTraitRatingEvent extends ProfileEvents {
  final String trait;
  final String rating;
  const AddTraitRatingEvent(this.trait, this.rating);
  @override
  // TODO: implement props
  List<Object> get props => [trait, rating];
}

class RemoveTraitRatingEvent extends ProfileEvents {
  final int position;
  const RemoveTraitRatingEvent(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];
}

class ChangeBoardingStatusEvent extends ProfileEvents {
  final bool value;
  const ChangeBoardingStatusEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class GetSessionsEvent extends ProfileEvents {
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends ProfileEvents {
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class GetClassesEvent extends ProfileEvents {
  final String apiToken;
  final String teacherId;
  const GetClassesEvent(this.apiToken, this.teacherId);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId];

}

class SelectClassEvent extends ProfileEvents {
  final String clas;
  const SelectClassEvent(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}