import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/news.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/create_edit_news.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/news_comments.dart';
import 'package:school_pal/ui/news_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dashboard.dart';
import 'general.dart';

Widget newsPage({BuildContext context, DashboardBloc dashboardBloc,  String loggedInAs}) {
  List<News> _news;
  return Container(
    height: double.infinity,
    width: double.infinity,
    child: Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: MyColors.primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35.0),
                        child: Text("NEWS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(dashboardBloc, _news, loggedInAs));
                      },
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocListener<DashboardBloc, DashboardStates>(
                listener: (BuildContext context, DashboardStates state) {
                  if (state is Processing) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Processing..."),
                      ),
                    );
                  }else if (state is NewsDeleted) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    dashboardBloc.add(ViewNewsEvent(localDB: false));
                  }else if (state is NetworkErr) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                      ),
                    );
                  } else if (state is ViewError) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                      ),
                    );
                    if (state.message == "Please Login to continue") {
                      reLogUserOut(context);
                    }
                  } else if (state is NewsLoaded) {
                    _news = state.news;
                  }else if (state is LoggingOut) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                      SnackBar(
                        duration: Duration(minutes: 30),
                        content: General.progressIndicator("Logging Out..."),
                      ),
                    );
                  } else if (state is LogoutSuccessful) {
                    logUserOut(context);

                  }
                },
                child: BlocBuilder<DashboardBloc, DashboardStates>(
                    builder: (BuildContext context, DashboardStates state) {
                  if (state is InitialState) {
                    return buildInitialScreen();
                  } else if (state is Loading) {
                    try{
                      return _news.isNotEmpty?_buildLoadedScreen(context, dashboardBloc,  _news, loggedInAs):buildLoadingScreen();
                    }on NoSuchMethodError {
                      return buildLoadingScreen();
                    }
                  } else if (state is NewsLoaded) {
                    return _buildLoadedScreen(context, dashboardBloc, state.news, loggedInAs);
                  }else if (state is ViewError) {
                    try{
                      return _news.isNotEmpty?_buildLoadedScreen(context, dashboardBloc,  _news, loggedInAs):buildNODataScreen();
                    }on NoSuchMethodError {
                      return buildNODataScreen();
                    }

                  }else if (state is NetworkErr) {
                    try{
                      return _news.isNotEmpty?_buildLoadedScreen(context, dashboardBloc,  _news, loggedInAs):buildNetworkErrorScreen("news");
                    }on NoSuchMethodError {
                      return buildNetworkErrorScreen("news");
                    }

                  } else {
                    try{
                      return  _news.isNotEmpty?_buildLoadedScreen(context, dashboardBloc,  _news, loggedInAs):buildInitialScreen();
                    }on NoSuchMethodError {
                      return buildInitialScreen();
                    }
                  }
                }),
              ),
            ),
          ],
        ),
        (loggedInAs==MyStrings.school)?Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: FloatingActionButton(
              heroTag: "Add News",
              onPressed: () {
                _navigateToCreateEditNewsScreen(dashboardBloc: dashboardBloc, context: context, type: 'Add');
              },
              child: Icon(Icons.add),
              backgroundColor: MyColors.primaryColor,
            ),
          ),
        ):Container(),
      ],
    ),
  );
}

Widget _buildLoadedScreen(BuildContext context, DashboardBloc dashboardBloc, List<News> news, String loggedInAs) {
  return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: news.length,
      itemBuilder: (BuildContext context, int index) {
        //if (index.isOdd) return Divider();
        return _buildRow(context, dashboardBloc, news, index, loggedInAs);
      });
}

Widget _buildRow(BuildContext context, DashboardBloc dashboardBloc, List<News> news, int index, String loggedInAs) {
  return Center(
    child: Card(
      // margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 1,
      child: ExpansionTile(
        backgroundColor: Colors.green.shade50,
        title: Text(toSentenceCase(news[index].title),
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.only(right: 2.0),
                icon: Icon(Icons.visibility),
                onPressed: (){
                  _navigateToNewsDetailsScreen(dashboardBloc: dashboardBloc, context: context, news: news[index]);
                },
              ),
              Expanded(
                flex: 2,
                child: Text(news[index].views,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal)),
              ),
              /*IconButton(
                padding: const EdgeInsets.only(right: 2.0),
                icon: Icon(Icons.comment),
                onPressed: (){
                  _showNewsCommentsModalDialog(dashboardBloc: dashboardBloc, context: context, news: news[index]);
                },
              ),
              Expanded(
                flex: 2,
                child: Text(news[index].comments.length.toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal)),
              ),*/
            ],
          ),
        ),
        children: <Widget>[
          ListTile(
            title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Html(
                  data: news[index].content,
                )
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: _buildTagList(news[index].tags.split(",")),
            )
            ),
            onTap: (){
              _navigateToNewsDetailsScreen(dashboardBloc: dashboardBloc, context: context, news: news[index]);
            },
            onLongPress: () {
              if(loggedInAs==MyStrings.school)
                showEditOrDeleteModalBottomSheet(dashboardBloc: dashboardBloc, context: context, news: news[index], type: 'Edit');
            },
          ),
        ],
      ),
    ),
  );
}

_buildTagList(List<String> tagList) {
  List<Widget> choices = List();
  tagList.forEach((item) {
    choices.add(Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        //backgroundColor: Colors.white54,
        label: Text(item),
        selected: false,
        onSelected: (selected) {

        },
      ),
    ));
  });    return choices;
}

class CustomSearchDelegate extends SearchDelegate {
  final List<News> news;
  final DashboardBloc dashboardBloc;
  final String loggedInAs;
  CustomSearchDelegate(this.dashboardBloc, this.news, this.loggedInAs);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    try {
      final suggestionList = query.isEmpty
          ? news
          : news
              .where((p) => p.title.toUpperCase().contains(query.toUpperCase()))
              .toList();

      return _buildLoadedScreen(context, dashboardBloc, suggestionList, loggedInAs);
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    try {
      final suggestionList = query.isEmpty
          ? news
          : news
              .where((p) => p.title.toUpperCase().contains(query.toUpperCase()))
              .toList();

      return _buildLoadedScreen(context, dashboardBloc, suggestionList, loggedInAs);
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }
}

void showEditOrDeleteModalBottomSheet({DashboardBloc dashboardBloc, BuildContext context, News news, type}) {
  showModalBottomSheet(
      context: context,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: Text('Options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColors.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: new Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
                title: new Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCreateEditNewsScreen(dashboardBloc: dashboardBloc, context: context, news: news, type: 'Edit');
                },
              ),
              ListTile(
                  leading: new Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: new Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    dashboardBloc.add(DeleteNewsEvent(news.id));
                  }),
            ],
          ),
        );
      });
}

_navigateToCreateEditNewsScreen({DashboardBloc dashboardBloc, BuildContext context, News news, type}) async {

  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CreateEditNews(news: news, type: type,)),
  );

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if(result!=null){
    showToast(message: result);
    //Refresh after update
    dashboardBloc.add(ViewNewsEvent(localDB: false));
  }
}

_navigateToNewsDetailsScreen({DashboardBloc dashboardBloc, BuildContext context, News news}) async {

  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NewsDetails(news: news)),
  );

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if(result!=null){
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

    //Refresh after update
    dashboardBloc.add(ViewNewsEvent());
  }
}

void _showNewsCommentsModalDialog({DashboardBloc dashboardBloc, BuildContext context, News news}) async{
  final result = await Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return NewsComments(news: news);
      },
      fullscreenDialog: true
  ));

  if(result!=null){
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result", textAlign: TextAlign.center)));

    //Refresh after update
    dashboardBloc.add(ViewNewsEvent());
  }
}
