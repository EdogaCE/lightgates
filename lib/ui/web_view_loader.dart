import 'package:flutter/material.dart';
import 'package:school_pal/blocs/webview/webview.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/res/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/file_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoader extends StatelessWidget {
  final String url;
  final String downloadLink;
  final String title;
  WebViewLoader({this.url, this.downloadLink, this.title});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebViewBloc(),
      child: WebViewLoaderPage(url, downloadLink, title),
    );
  }
}

// ignore: must_be_immutable
class WebViewLoaderPage extends StatelessWidget {
  final String url;
  final String downloadLink;
  final String title;
  WebViewLoaderPage(this.url, this.downloadLink, this.title);
  WebViewBloc _webViewBloc;
  WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    _webViewBloc = BlocProvider.of<WebViewBloc>(context);
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            downloadLink.isNotEmpty?IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  _downLoadFile();
                }):Container(),
          ],
          iconTheme: IconThemeData(
            color: MyColors.primaryColor
          ),
          title: Text(title, style: TextStyle(color: MyColors.primaryColor),),
          elevation: 1.0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: CustomPaint(
                    painter: BackgroundPainter(),
                    child: WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller = webViewController;
                      },
                      onPageStarted: (String message){
                        _webViewBloc.add(PageStartedEvent());
                      },
                      onPageFinished: (String message){
                        _webViewBloc.add(PageFinishedEvent());
                      },
                      onWebResourceError: (message){
                        _controller.reload();
                        _webViewBloc.add(WebResourceErrorEvent());
                      },
                    )
                ),
              ),
              BlocListener<WebViewBloc, WebViewStates>(
                listener: (context, state) {
                  //Todo: note listener returns void
                  if (state is NetworkErr) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                      ),
                    );
                  }
                },
                child: BlocBuilder<WebViewBloc, WebViewStates>(
                  builder: (context, state) {
                    //Todo: note builder returns widget
                    if (state is WebViewInitial) {
                      return Container();
                    } else if (state is WebViewLoading) {
                      return  Container(
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                              valueColor:
                              new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                              backgroundColor: Colors.pink,
                            ),
                          )
                      );
                    } else if (state is WebViewLoaded) {
                      return Container();
                    }else if (state is NetworkErr) {
                      return  Container();
                    } else {
                      return  Container();
                    }
                  },
                ),
              ),
            ],
          ),
        /*floatingActionButton: downloadLink.isNotEmpty?Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: FloatingActionButton.extended(
            heroTag: "Download file",
            onPressed: () {
             _downLoadFile();
            },
            label: Text('Download'),
            icon: Icon(Icons.file_download),
            backgroundColor: MyColors.primaryColor,
          ),
        ):Container(),*/
      ),
    );
  }

  void _downLoadFile(){
    _webViewBloc.add(PageStartedEvent());
    try{
      createFileOfPdfUrl(urlP:downloadLink,
          fileNameExtension: downloadLink.split('/').last).then((res) {
        _webViewBloc.add(PageFinishedEvent());
        showToast(message: 'Downloaded to ${res.path}');
      });
    }on NoSuchMethodError{
      showToast(message: 'Download failed try again');
      _webViewBloc.add(WebResourceErrorEvent());
    }
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (await _controller.canGoBack()) {
      print("onwill goback");
      _controller.goBack();
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}
