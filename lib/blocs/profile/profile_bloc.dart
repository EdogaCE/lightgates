import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/update_profile_request.dart';
import 'package:school_pal/res/strings.dart';

class ProfileBloc extends Bloc<ProfileEvents, ProfileStates>{
  final  ViewProfileRepository viewProfileRepository;
  final UpdateProfileRepository updateProfileRepository;
  ProfileBloc({this.viewProfileRepository, this.updateProfileRepository}) : super(ProfileInitial());

  @override
  Stream<ProfileStates> mapEventToState(ProfileEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewDeveloperProfileEvent){
      yield ProfileLoading();
      try{
        final developer=await viewProfileRepository.fetchDeveloperProfile(event.apiToken);
        yield DeveloperProfileLoaded(developer);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewSchoolProfileEvent){
      yield ProfileLoading();
      try{
        final school=await viewProfileRepository.fetchSchoolProfile(event.apiToken);
        yield SchoolProfileLoaded(school);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateSchoolProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.updateSchoolProfile(schoolId:event.schoolId, name: event.name, contactPhoneNumber: event.contactPhoneNumber, address: event.address, town: event.town, lga: event.lga, city: event.city, nationality: event.nationality, slogan:event.slogan, website: event.website, facebook: event.facebook, instagram: event.instagram, twitter: event.twitter);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UpdateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateSchoolSettingsEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.updateSchoolSettings(schoolId:event.schoolId, poBox:event.poBox, preferredCurrencyId: event.preferredCurrencyId, behaviouralSkillTestsHeadings: event.behaviouralSkillTestsHeadings, initialAdmissionNum: event.initialAdmissionNum, numOfCumulativeTest: event.numOfCumulativeTest, numOfTerm: event.numOfTerm, traits: event.traits, ratings: event.ratings, resultCommentSwitch: event.resultCommentSwitch, testExamScoreLimit: event.testExamScoreLimit, useClassCategoryStatus: event.useClassCategoryStatus, useCumulativeResult: event.useCumulativeResult, useCustomAdmissionNum: event.useCustomAdmissionNum, useOfSignatureOnResults: event.useOfSignatureOnResults);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UpdateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadSchoolLogoEvent){
      yield ProfileUpdating();
      try{
        final school=await updateProfileRepository.uploadSchoolLogo(schoolLogo64Bit: event.logo64Bit);
        yield SchoolProfileLoaded(school);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeSchoolPasswordEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.changeSchoolPassword(oldPassword: event.oldPassword, newPassword: event.newPassword, confirmPassword: event.confirmPassword);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UpdateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is VisiblePassword){
      yield VisiblePasswordState(event.password);
    }else if(event is ChangeDateEvent){
      yield DateChanged(event.date);
    }else if(event is ChangeGenderEvent){
      yield GenderChanged(event.gender);
    }else if(event is ChangeBloodGroupEvent){
      yield BloodGroupChanged(event.bloodGroup);
    }else if(event is ChangeGenotypeEvent){
      yield GenotypeChanged(event.genotype);
    }else if(event is ChangeTitleEvent){
      yield TileChanged(event.title);
    }else if(event is ViewTeacherProfileEvent){
      yield ProfileLoading();
      try{
        final teacher=await viewProfileRepository.fetchTeacherProfile(event.apiToken, event.teacherId);
        yield TeacherProfileLoaded(teacher);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is CreateTeacherProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.createTeacherProfile(role: event.role, title: event.title, firstName: event.firstName, lastName: event.lastName, otherNames: event.otherNames, username: event.username, gender: event.gender, phone: event.phone, contactAddress: event.contactAddress, city: event.city, state: event.state, country: event.country, birthday: event.birthday, email: event.email, passport: event.passport, salary: event.salary, bankCode: event.bankCode, bankName: event.bankName, bankAccountNumber: event.bankAccountNumber, password: event.password);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateTeacherProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.updateTeacherProfile(teacherId: event.teacherId, title: event.title, firstName: event.firstName, lastName: event.lastName, otherNames: event.otherNames, gender: event.gender, phone: event.phone, contactAddress: event.contactAddress, city: event.city, state: event.state, country: event.country, birthday: event.birthday, salary: event.salary, role: event.role, preferredCurrencyId: event.preferredCurrencyId, bankCode: event.bankCode, bankName: event.bankName, bankAccountNumber: event.bankAccountNumber);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadTeacherImageEvent){
      yield ProfileUpdating();
      try{
        final teacher=await updateProfileRepository.uploadTeacherImage(teacherId: event.teacherId, teacherImage: event.logo64Bit);
        yield TeacherProfileLoaded(teacher);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadTeacherSignatoryEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.uploadTeacherSignatory(teacherId: event.teacherId, teacherSignatory: event.teacherSignatory);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeTeacherPasswordEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.changeTeacherPassword(oldPassword: event.oldPassword, newPassword: event.newPassword, confirmPassword: event.confirmPassword);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UpdateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewStudentProfileEvent){
      try{
        final student=await viewProfileRepository.fetchStudentProfile(event.apiToken, event.studentId);
        yield StudentProfileLoaded(student);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadStudentImageEvent){
      yield ProfileUpdating();
      try{
        final student=await updateProfileRepository.uploadStudentImage(studentId: event.studentId,studentImage: event.logo64Bit);
        yield StudentProfileLoaded(student);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeStudentPasswordEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.changeStudentPassword(oldPassword: event.oldPassword, newPassword: event.newPassword, confirmPassword: event.confirmPassword);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UpdateError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateStudentProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.updateStudentProfile(studentId: event.studentId, firstName: event.firstName, lastName: event.lastName, otherNames: event.otherNames, gender: event.gender, email: event.email, phone: event.phone, contactAddress: event.contactAddress, city: event.city, state: event.state, country: event.country, birthday: event.birthday, bloodGroup: event.bloodGroup, genotype: event.genotype, healthHistory: event.healthHistory, preferredCurrencyId: event.preferredCurrencyId, boardingStatus: event.boardingStatus);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateParentProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.updateParentProfile(studentId: event.studentId, parentId: event.studentId, parentTitle: event.parentTitle, parentAddress: event.parentAddress, parentFullName: event.parentFullName, parentsOccupation: event.parentsOccupation);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UploadParentImageEvent){
      yield ProfileUpdating();
      try{
        final student=await updateProfileRepository.uploadParentImage(studentId: event.studentId, parentId: event.parentId, parentImage: event.logo64Bit);
        yield StudentProfileLoaded(student);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    } else if(event is GetCurrenciesEvent){
      yield ProfileLoading();
      try{
        final currencies=await getCurrenciesSpinnerValue(event.apiToken);
        yield CurrenciesLoaded(currencies);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectCurrencyEvent){
      yield CurrencySelected(event.currency);
    }else if(event is GetFlutterWaveBankCodes){
      yield ProfileLoading();
      try{
        final banks=await getFlutterWaveBankCodesSpinnerValue();
        yield BanksLoaded(banks);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectBankEvent){
      yield BankSelected(event.bank);
    }else if(event is ChangeResultCommentTypeEvent){
      yield ResultCommentTypeChanged(event.value);
    }else if(event is ChangeUseCumulativeEvent){
      yield UseCumulativeChanged(event.value);
    }else if(event is ChangeUseCustomAdmissionNumEvent){
      yield UseCustomAdmissionNumChanged(event.value);
    }else if(event is ChangeUseClassCategoryEvent){
      yield UseClassCategoryChanged(event.value);
    }else if(event is ChangeUseOfSignatureOnResultsEvent){
      yield UseOfSignatureOnResultsChanged(event.value);
    }else if(event is ChangeNumberOfTermsEvent){
      yield NumberOfTermsChanged(event.count);
    }else if(event is ChangeNumberOfCumulativeTestEvent){
      yield NumberOfCumulativeTestChanged(event.count);
    }else if(event is ChangeInitialAdmissionNumEvent){
      yield InitialAdmissionNumChanged(event.value);
    }else if(event is ChangeScoreLimitEvent){
      yield ScoreLimitChanged(event.limit, event.position);
    } else if(event is ChangeBehaviouralSkillEvent){
      yield BehaviouralSkillChanged(event.skill, event.position);
    }else if(event is AddBehaviouralSkillsEvent){
      yield BehaviouralSkillsAdded(event.skill);
    }else if(event is RemoveBehaviouralSkillsEvent){
      yield BehaviouralSkillsRemoved(event.position);
    } else if(event is ChangeTraitRatingEvent){
      yield TraitRatingChanged(event.trait, event.rating, event.position);
    }else if(event is AddTraitRatingEvent){
      yield TraitRatingAdded(event.trait, event.rating);
    }else if(event is RemoveTraitRatingEvent){
      yield TraitRatingRemoved(event.position);
    }else if(event is ChangeBoardingStatusEvent){
      yield BoardingStatusChanged(event.value);
    }else if(event is GetSessionsEvent){
      yield ProfileLoading();
      try{
        final sessions=await getSessionSpinnerValue(event.apiToken);
        yield SessionsLoaded(sessions);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectSessionEvent){
      yield SessionSelected(event.session);
    }else if(event is GetClassesEvent){
      yield ProfileLoading();
      try{
        //final classes=await getTeacherClassesSpinnerValue(event.apiToken, event.teacherId);
        final classes=await getClassesSpinnerValue(event.apiToken);
        yield ClassesLoaded(classes);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectClassEvent){
      yield ClassSelected(event.clas);
    }else if(event is CreateStudentProfileEvent){
      yield ProfileUpdating();
      try{
        final message=await updateProfileRepository.createStudentProfile(email: event.email, admissionNUmber: event.admissionNUmber, birthday: event.birthday, bloodGroup: event.bloodGroup, boardingStatus: event.boardingStatus, city: event.city, classId: event.classId, contactAddress: event.contactAddress, country: event.country, firstName: event.firstName, gender: event.gender, genotype: event.genotype, healthHistory: event.healthHistory, lastName: event.lastName, otherNames: event.otherNames, parentAddress: event.parentAddress, parentEmail: event.parentEmail, parentFullName: event.parentFullName, parentPhone: event.parentPhone, parentsOccupation: event.parentsOccupation, parentTitle: event.parentTitle, phone: event.phone, sessionId: event.sessionId, state: event.state);
        yield ProfileUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }
}