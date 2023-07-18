import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/webview/webview.dart';
import 'package:school_pal/res/strings.dart';

class WebViewBloc extends Bloc<WebViewEvents, WebViewStates>{
  WebViewBloc() : super( WebViewInitial());

  @override
  Stream<WebViewStates> mapEventToState(WebViewEvents event) async*{
    // TODO: implement mapEventToState
    if(event is PageStartedEvent){
      yield WebViewLoading();
    }else if(event is PageFinishedEvent){
      yield WebViewLoaded();
    } else if(event is WebResourceErrorEvent){
      yield NetworkErr(MyStrings.networkErrorMessage);
    }
  }
}