import 'package:equatable/equatable.dart';

abstract class WebViewStates extends Equatable{
  const WebViewStates();
}

class WebViewInitial extends WebViewStates{
  const WebViewInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WebViewLoading extends WebViewStates{
  const WebViewLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WebViewLoaded extends WebViewStates{
  const WebViewLoaded();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class NetworkErr extends WebViewStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}