import 'package:equatable/equatable.dart';
import 'package:school_pal/models/developer.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';

abstract class ProfileStates extends Equatable{
  const ProfileStates();
}

class ProfileInitial extends ProfileStates{
  const ProfileInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProfileLoading extends ProfileStates{
  const ProfileLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DeveloperProfileLoaded extends ProfileStates{
  final Developer developer;
  const DeveloperProfileLoaded(this.developer);
  @override
  // TODO: implement props
  List<Object> get props => [developer];
}

class SchoolProfileLoaded extends ProfileStates{
  final School school;
  const SchoolProfileLoaded(this.school);
  @override
  // TODO: implement props
  List<Object> get props => [school];
}

class TeacherProfileLoaded extends ProfileStates{
  final Teachers teachers;
  const TeacherProfileLoaded(this.teachers);
  @override
  // TODO: implement props
  List<Object> get props => [teachers];
}

class StudentProfileLoaded extends ProfileStates{
  final Students students;
  const StudentProfileLoaded(this.students);
  @override
  // TODO: implement props
  List<Object> get props => [students];
}

class ProfileUpdating extends ProfileStates{
  const ProfileUpdating();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ProfileUpdated extends ProfileStates{
  final String message;
  const ProfileUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class VisiblePasswordState extends ProfileStates{
  final bool password;
  const VisiblePasswordState(this.password);
  @override
  // TODO: implement props
  List<Object> get props => [password];
}

class DateChanged extends ProfileStates{
  final DateTime date;
  const DateChanged(this.date);
  @override
  // TODO: implement props
  List<Object> get props => [date];

}

class GenderChanged extends ProfileStates{
  final String gender;
  const GenderChanged(this.gender);
  @override
  // TODO: implement props
  List<Object> get props => [gender];

}

class BloodGroupChanged extends ProfileStates{
  final String bloodGroup;
  const BloodGroupChanged(this.bloodGroup);
  @override
  // TODO: implement props
  List<Object> get props => [bloodGroup];

}

class GenotypeChanged extends ProfileStates{
  final String genotype;
  const GenotypeChanged(this.genotype);
  @override
  // TODO: implement props
  List<Object> get props => [genotype];

}

class TileChanged extends ProfileStates{
  final String title;
  const TileChanged(this.title);
  @override
  // TODO: implement props
  List<Object> get props => [title];

}

class CurrenciesLoaded extends ProfileStates{
  final List<List<String>> currencies;
  const CurrenciesLoaded(this.currencies);
  @override
  // TODO: implement props
  List<Object> get props => [currencies];
}

class CurrencySelected extends ProfileStates{
  final String currency;
  const CurrencySelected(this.currency);
  @override
  // TODO: implement props
  List<Object> get props => [currency];

}

class BanksLoaded extends ProfileStates{
  final List<List<String>> banks;
  const BanksLoaded(this.banks);
  @override
  // TODO: implement props
  List<Object> get props => [banks];
}

class BankSelected extends ProfileStates{
  final String bank;
  const BankSelected(this.bank);
  @override
  // TODO: implement props
  List<Object> get props => [bank];

}

class ResultCommentTypeChanged extends ProfileStates {
  final String value;
  const ResultCommentTypeChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class UseCumulativeChanged extends ProfileStates {
  final bool value;
  const UseCumulativeChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class NumberOfTermsChanged extends ProfileStates {
  final int count;
  const NumberOfTermsChanged(this.count);
  @override
  // TODO: implement props
  List<Object> get props => [count];
}

class UseCustomAdmissionNumChanged extends ProfileStates {
  final bool value;
  const UseCustomAdmissionNumChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class UseClassCategoryChanged extends ProfileStates {
  final bool value;
  const UseClassCategoryChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class UseOfSignatureOnResultsChanged extends ProfileStates {
  final bool value;
  const UseOfSignatureOnResultsChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class NumberOfCumulativeTestChanged extends ProfileStates {
  final int count;
  const NumberOfCumulativeTestChanged(this.count);
  @override
  // TODO: implement props
  List<Object> get props => [count];
}

class InitialAdmissionNumChanged extends ProfileStates {
  final String value;
  const InitialAdmissionNumChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ScoreLimitChanged extends ProfileStates {
  final String limit;
  final int position;
  const ScoreLimitChanged(this.limit, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [limit, position];
}

class BehaviouralSkillChanged extends ProfileStates {
  final String skill;
  final int position;
  const BehaviouralSkillChanged(this.skill, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [skill, position];
}

class BehaviouralSkillsAdded extends ProfileStates {
  final String skill;
  const BehaviouralSkillsAdded(this.skill);
  @override
  // TODO: implement props
  List<Object> get props => [skill];
}

class BehaviouralSkillsRemoved extends ProfileStates {
  final int position;
  const BehaviouralSkillsRemoved(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];
}

class TraitRatingChanged extends ProfileStates {
  final String trait;
  final String rating;
  final int position;
  const TraitRatingChanged(this.trait, this.rating, this.position);
  @override
  // TODO: implement props
  List<Object> get props => [trait, rating, position];
}

class TraitRatingAdded extends ProfileStates {
  final String trait;
  final String rating;
  const TraitRatingAdded(this.trait, this.rating);
  @override
  // TODO: implement props
  List<Object> get props => [trait, rating];
}

class TraitRatingRemoved extends ProfileStates {
  final int position;
  const TraitRatingRemoved(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];
}

class BoardingStatusChanged extends ProfileStates {
  final bool value;
  const BoardingStatusChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class SessionsLoaded extends ProfileStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends ProfileStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class ClassesLoaded extends ProfileStates{
  final List<List<String>> classes;
  const ClassesLoaded(this.classes);
  @override
  // TODO: implement props
  List<Object> get props => [classes];
}

class ClassSelected extends ProfileStates{
  final String clas;
  const ClassSelected(this.clas);
  @override
  // TODO: implement props
  List<Object> get props => [clas];

}

class UpdateError extends ProfileStates{
  final String message;
  const UpdateError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends ProfileStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends ProfileStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}