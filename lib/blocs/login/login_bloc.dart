import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/login/login.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/posts/login_request.dart';
import 'package:school_pal/res/strings.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates>{
  final LoginRepository postRepository;
  LoginBloc(this.postRepository) : super(LoginInitialState());

  @override
  Stream<LoginStates> mapEventToState(LoginEvents event) async* {
    // TODO: implement mapEventToState
    if(event is VisiblePassword){
      yield VisiblePasswordState(event.password);
    } else if(event is SelectSpinnerDataEvent){
      yield SpinnerDataSelected(event.selectedData);
    }else if(event is ViewSchoolCategoriesEvent){
      yield Loading();
      try{
        final schools=await getSchoolsSpinnerValue();
        yield SchoolCategoriesLoaded(schools);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UserError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is LoginSchool){
      yield UserLoading();
      try{
        final user=await postRepository.loginSchool(email: event.contactEmail, password: event.password);
        yield UserLoaded(user);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UserError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is LoginTeacher){
      yield UserLoading();
      try{
        final user=await postRepository.loginTeacher(email: event.contactEmail, password: event.password);
        yield UserLoaded(user);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UserError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is LoginStudent){
      yield UserLoading();
      try{
        final user=await postRepository.loginStudent(email: event.contactEmail, password: event.password);
        yield UserLoaded(user);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UserError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is InitializeAppEvent){
      yield UserLoading();
      try{
        final appVersion=await postRepository.fetchAppVersion(localDb: event.localDb);
        yield AppInitialized(appVersion);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield UserError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}