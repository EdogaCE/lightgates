import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/fees/fees.dart';
import 'package:school_pal/requests/get/view_fees_requests.dart';
import 'package:school_pal/requests/posts/create_fees_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/res/strings.dart';

class FeesBloc extends Bloc<FeesEvents, FeesStates> {
  final ViewFeesRepository viewFeesRepository;
  final CreateFeesRepository createFeesRepository;
  FeesBloc({this.viewFeesRepository, this.createFeesRepository}) : super(FeesInitial());


  @override
  Stream<FeesStates> mapEventToState(FeesEvents event) async* {
    // TODO: implement mapEventToState
    if (event is ViewFeesRecordEvent) {
      yield Loading();
      try {
        final fees = await viewFeesRepository.fetchFeesRecord(event.apiToken);
        yield FeesRecordLoaded(fees);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is GetSessionsEvent) {
      yield Loading();
      try {
        final sessions = await getSessionSpinnerValue(event.apiToken);
        yield SessionsLoaded(sessions);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is SelectSessionEvent) {
      yield SessionSelected(event.session);
    } else if (event is GetTermsEvent) {
      yield Loading();
      try {
        final terms = await getTermSpinnerValue(event.apiToken);
        yield TermsLoaded(terms);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is SelectTermEvent) {
      yield TermSelected(event.term);
    } else if (event is GetClassEvent) {
      yield Loading();
      try {
        final classes = await getClassesSpinnerValue(event.apiToken);
        yield ClassesLoaded(classes);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    } else if (event is SelectClassEvent) {
      yield ClassSelected(event.clas);
    } else if (event is SelectTypeEvent) {
      yield TypeSelected(event.type);
    } else if (event is SelectDivisionEvent) {
      yield DivisionSelected(event.division);
    }else if (event is CreateFeeRecordEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.createFeesRecord(title: event.title, type: event.type, description: event.description, termId: event.termId, sessionId: event.sessionId);
        yield FeeRecordCreated(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is UpdateFeeRecordEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.updateFeesRecord(recordId: event.recordId,title: event.title, type: event.type, description: event.description, termId: event.termId, sessionId: event.sessionId);
        yield FeeRecordUpdated(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is DeleteFeeRecordEvent) {
      yield Processing();
      try {
        final message = await viewFeesRepository.deleteFeesRecord(event.recordId);
        yield FeeRecordDeleted(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is RestoreFeeRecordEvent) {
      yield Processing();
      try {
        final message = await viewFeesRepository.restoreFeesRecord(event.recordId);
        yield FeeRecordRestored(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ViewFeesEvent) {
      yield Loading();
      try {
        final fees = await viewFeesRepository.fetchFees(event.apiToken, event.recordId);
        yield FeesLoaded(fees);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is DeleteFeeEvent) {
      yield Processing();
      try {
        print(event.feeId+" and "+ event.recordId);
        final message = await createFeesRepository.deleteFee(feeId: event.feeId, recordId: event.recordId);
        yield FeeDeleted(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is CreateFeeEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.createFees(recordId: event.recordId, title: event.title, amount: event.amount, division: event.division, classId: event.classId);
        yield FeeCreated(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is UpdateFeeEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.updateFees(feeId: event.feeId,recordId: event.recordId, title: event.title, amount: event.amount, division: event.division, classId: event.classId);
        yield FeeUpdated(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ViewFeesPaymentsEvent) {
      yield Loading();
      try {
        final students = await viewFeesRepository.fetchFeesPayments(apiToken: event.apiToken, recordId: event.recordId, filter: 'All');
        yield FeesPaymentsLoaded(students);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ViewOutstandingFeesPaymentsEvent) {
      yield Loading();
      try {
        final students = await viewFeesRepository.fetchFeesPayments(apiToken: event.apiToken, recordId: event.recordId, filter: 'Outstanding');
        yield FeesPaymentsLoaded(students);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ViewFeesPaymentsByDateEvent) {
      yield Loading();
      try {
        final students = await viewFeesRepository.fetchFeesPayments(apiToken: event.apiToken, recordId: event.recordId, filter: 'Date', dateFrom: event.dateFrom, dateTo: event.dateTo);
        yield FeesPaymentsLoaded(students);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ConfirmFeesPaymentEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.confirmFeePayment(recordId: event.recordId, feePaymentId: event.feePaymentId);
        yield FeePaymentConfirmed(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is DeactivateDefaultStudentEvent) {
      yield Processing();
      try {
        final message = await createFeesRepository.deactivateDefaultStudent(recordId: event.recordId, studentId: event.studentId);
        yield StudentDeactivated(message);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if (event is ViewStudentFeesEvent) {
      yield Loading();
      try {
        final fees = await viewFeesRepository.fetchStudentFees(apiToken: event.apiToken, studentId: event.studentId);
        yield FeesPaymentsLoaded(fees);
      } on NetworkError {
        yield FeesNetworkErr(MyStrings.networkErrorMessage);
      } on ApiException catch (e) {
        yield FeesViewError(e.toString());
      }on SystemError{
        yield FeesNetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }
}
