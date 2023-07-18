import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/salary/salary.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/get/view_salary_requests.dart';
import 'package:school_pal/requests/posts/create_update_salary_request.dart';
import 'package:school_pal/res/strings.dart';

class SalaryBloc extends Bloc<SalaryEvents, SalaryStates> {
  final ViewSalaryRepository viewSalaryRepository;
  final CreateSalaryRepository createSalaryRepository;
  SalaryBloc({this.viewSalaryRepository, this.createSalaryRepository}) : super(SalaryInitial());

  @override
  Stream<SalaryStates> mapEventToState(SalaryEvents event) async* {
    // TODO: implement mapEventToState
    if (event is ViewSalaryRecordEvent) {
      yield SalaryLoading();
      try {
        final salary =
            await viewSalaryRepository.fetchSalaryRecord(event.apiToken);
        yield SalaryRecordLoaded(salary);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is ViewParticularSalaryRecordEvent) {
      yield SalaryLoading();
      try {
        final salary =
            await viewSalaryRepository.fetchTeacherSalaryRecord(event.recordId);
        yield ParticularSalaryRecordLoaded(salary);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is CreateSalaryRecordEvent) {
      yield Processing();
      try {
        final message = await createSalaryRepository.createSalaryRecord(
            paymentFrequency: event.paymentFrequency,
            sessionId: event.sessionId,
            termId: event.termId,
            startDate: event.startDate,
            endDate: event.endDate,
            title: event.title,
            description: event.description);
        yield SalaryRecordCreated(message);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is UpdateSalaryRecordEvent) {
      yield Processing();
      try {
        final message = await createSalaryRepository.updateSalaryRecord(
            recordId: event.recordId,
            paymentFrequency: event.paymentFrequency,
            sessionId: event.sessionId,
            termId: event.termId,
            startDate: event.startDate,
            endDate: event.endDate,
            title: event.title,
            description: event.description);
        yield SalaryRecordUpdated(message);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is GetSessionsEvent) {
      yield SalaryLoading();
      try {
        final sessions = await getSessionSpinnerValue(event.apiToken);
        yield SessionsLoaded(sessions);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is SelectSessionEvent) {
      yield SessionSelected(event.session);
    } else if (event is GetTermsEvent) {
      yield SalaryLoading();
      try {
        final terms = await getTermSpinnerValue(event.apiToken);
        yield TermsLoaded(terms);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is SelectTermEvent) {
      yield TermSelected(event.term);
    } else if (event is ChangeDateFromEvent) {
      yield DateFromChanged(event.from);
    } else if (event is ChangeDateToEvent) {
      yield DateToChanged(event.to);
    } else if (event is SelectFrequencyEvent) {
      yield FrequencySelected(event.frequency);
    } else if (event is UpdateTeacherSalaryRecordEvent) {
      yield Processing();
      try {
        final message = await createSalaryRepository.updateTeacherSalaryPaymentRecord(
                paymentId: event.paymentId, paymentStatus: event.paymentStatus);
        yield TeacherSalaryRecordUpdated(message);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectTeacherEvent){
      yield TeacherSelected(isSelected: event.isSelected, index: event.index);
    } else if (event is PayTeachersSalaryEvent) {
      yield Processing();
      try {
        final message = await createSalaryRepository.payTeachersSalary(paymentId: event.paymentId, idForPaymentsToBeUpdated: event.idForPaymentsToBeUpdated, salary: event.salary, bonus: event.bonus, paymentStatus: event.paymentStatus);
        yield TeachersSalaryPaid(message);
      } on NetworkError {
        yield SalaryNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield SalaryViewError(e.toString());
      }on SystemError{
        yield SalaryNetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }
}
