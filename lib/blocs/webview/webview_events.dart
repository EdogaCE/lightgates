import 'package:equatable/equatable.dart';

abstract class WebViewEvents extends Equatable{
  const WebViewEvents();
}

class PageStartedEvent extends WebViewEvents{
  const PageStartedEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PageFinishedEvent extends WebViewEvents{
  const PageFinishedEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WebResourceErrorEvent extends WebViewEvents{
  const WebResourceErrorEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}