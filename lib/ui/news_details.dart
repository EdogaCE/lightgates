import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/blocs/dashboard/dashboard_bloc.dart';
import 'package:school_pal/models/news.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/requests/get/view_faqs_news_request.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/news_comments.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_html/flutter_html.dart';

class NewsDetails extends StatelessWidget {
  final News news;
  NewsDetails({this.news});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(viewFAQsNewsRepository: ViewFAQsNewsRequest()),
      child: NewsDetailsPage(news),
    );
  }
}

// ignore: must_be_immutable
class NewsDetailsPage extends StatelessWidget {
  News news;
  NewsDetailsPage(this.news);
  DashboardBloc _dashboardBloc;
  void _viewSingleNews() async {
    _dashboardBloc.add(ViewSingleNewsEvent(news.id));
  }

  @override
  Widget build(BuildContext context) {
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    _viewSingleNews();
    final RefreshController _refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            _viewSingleNews();
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 250.0,
                actions: <Widget>[
                  /*IconButton(
                    icon: Icon(
                      Icons.comment,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _showNewsCommentsModalDialog(context: context, news: news);
                    },
                  )*/
                ],
                //title: SABT(child: Text("Classes Categorized")),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(news.title, textAlign: TextAlign.center,),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: CustomPaint(
                      painter: CustomScrollPainter(),
                      child: Center(
                          child: SvgPicture.asset("lib/assets/images/news.svg")
                      ),
                    )),
              ),
              _buildNews(context)
            ],
          )),
    );
  }

  Widget _buildNews(context) {
    return BlocListener<DashboardBloc, DashboardStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is NetworkErr) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        } else if (state is ViewError) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        } else if (state is SingleNewsLoaded) {
          news=state.news;
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is InitialState) {
            return buildInitialScreen();
          } else if (state is Loading) {
            try{
              return _buildLoadedScreen(context, news);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }
          } else if (state is SingleNewsLoaded) {
            return _buildLoadedScreen(context, state.news);
          }  else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, news);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, news);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, news);
            }on NoSuchMethodError{
              return buildInitialScreen();
            }

          }
        },
      ),
    );
  }

  Widget buildInitialScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Scaffold(),
          ),
        ));
  }

  Widget buildLoadingScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                      backgroundColor: Colors.pink,
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget buildNODataScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              MyStrings.noData,
              height: 150.0,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }

  Widget buildNetworkErrorScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: SvgPicture.asset(
                MyStrings.networkError,
                height: 150.0,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => _viewSingleNews(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, News news) {
    return SliverList(
        delegate: SliverChildListDelegate([
          ListTile(
            title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Html(
                  data: news.content,
                )
            ),
            subtitle: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: _buildTagList(news.tags.split(",")),
                )
            ),
          ),
          ],
        ));
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

  void _showNewsCommentsModalDialog({BuildContext context, News news}) async{
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
      _viewSingleNews();
    }
  }
}

