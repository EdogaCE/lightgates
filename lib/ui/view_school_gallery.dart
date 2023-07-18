import 'dart:async';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/gallery/gallery.dart';
import 'package:school_pal/blocs/navigatoins/navigation.dart';
import 'package:school_pal/models/gallery.dart';
import 'package:school_pal/requests/get/view_school_gallery_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_gallery.dart';
import 'package:school_pal/ui/school_gallery_details.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class ViewSchoolGallery extends StatelessWidget {
  final String loggedInAs;
  ViewSchoolGallery({this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GalleryBloc>(
          create: (context) => GalleryBloc(viewSchoolGalleryRepository: ViewSchoolGalleryRequest())),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
      ],
      child: ViewSchoolGalleryPage(loggedInAs),
    );
  }
}

// ignore: must_be_immutable
class ViewSchoolGalleryPage extends StatelessWidget {
  final String loggedInAs;
  ViewSchoolGalleryPage(this.loggedInAs);
  static GalleryBloc _galleryBloc;
  NavigationBloc _navigationBloc;
  List<Gallery> _schoolGallery;
  List<String> images=List();
  int imageIndex=0;
  String imageUrl='';
  static void viewSchoolGallery() async {
    _galleryBloc.add(ViewGalleryEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _galleryBloc = BlocProvider.of<GalleryBloc>(context);
   _navigationBloc=BlocProvider.of<NavigationBloc>(context);
    viewSchoolGallery();
    final RefreshController _refreshController = RefreshController();
    Timer.periodic(Duration(seconds: 10), (timer) {
      try{
        _navigationBloc.add(ChangeGalleryImageEvent((imageIndex + 1) % images.length));
      }catch(e){}
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () {
            viewSchoolGallery();
            _refreshController.refreshCompleted();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(_schoolGallery, loggedInAs));
                      })
                ],
                pinned: true,
                floating: true,
                expandedHeight: 300.0,
                //title: SABT(child: Text("Class Levels")),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text("School Gallery"),
                    titlePadding: const EdgeInsets.all(15.0),
                    background: BlocListener<NavigationBloc, NavigationStates>(
                      listener: (context, state) {
                        if(state is GalleryImageChanged)
                          imageIndex=state.index;
                        //Todo: note listener returns void
                      },
                      child: BlocBuilder<NavigationBloc, NavigationStates>(
                        builder: (context, state) {
                          //Todo: note builder returns widget
                         return GestureDetector(
                           onTap: ()=>_navigationBloc.add(ChangeGalleryImageEvent((imageIndex + 1) % images.length)),
                           child: FadeInImage.assetNetwork(
                             fit: BoxFit.cover,
                             fadeInDuration: const Duration(seconds: 1),
                             fadeInCurve: Curves.easeInCirc,
                             placeholder: 'lib/assets/images/avatar.png',
                             image: images.isNotEmpty?imageUrl + images[imageIndex]:'',
                           ),
                         );
                        },
                      ),
                    )),
              ),
              _studentsGrid(context)
            ],
          )),
      floatingActionButton: (loggedInAs!=MyStrings.student)?FloatingActionButton(
        heroTag: "Add image",
        onPressed: () {
          _navigateToAddEditGalleryScreen(context: context, editing: false);
        },
        child: Icon(Icons.add),
        backgroundColor: MyColors.primaryColor,
      ):Container(),
    );
  }

  Widget _studentsGrid(context) {
    return BlocListener<GalleryBloc, GalleryStates>(
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
        } else if (state is GalleryLoaded) {
          _schoolGallery = state.gallery;
        }else if(state is Processing){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: General.progressIndicator("Deleting..."),
            ),
          );
        }else if(state is GalleryDeleted){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          viewSchoolGallery();
        }
      },
      child: BlocBuilder<GalleryBloc, GalleryStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is GalleryInitial) {
            return buildInitialScreen();
          } else if (state is GalleryLoading) {
            try{
              return _buildLoadedScreen(context, _schoolGallery);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }

          } else if (state is GalleryLoaded) {
            return _buildLoadedScreen(context, state.gallery);
          }else if (state is ViewError) {
            try{
              return _buildLoadedScreen(context, _schoolGallery);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }

          }else if (state is NetworkErr) {
            try{
              return _buildLoadedScreen(context, _schoolGallery);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }

          } else {
            try{
              return _buildLoadedScreen(context, _schoolGallery);
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
              onTap: () => viewSchoolGallery(),
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Gallery> gallery) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if(gallery[index].images.isNotEmpty){
          images.addAll(gallery[index].images.split(','));
          imageUrl=gallery[index].imageUrl;
        }
        return _buildGallery(context, gallery, index, loggedInAs);
      }, childCount: gallery.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context, List<Gallery> gallery, int index, String loggedInAs}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    Icons.view_agenda,
                    color: Colors.amber,
                  ),
                  title: new Text('View'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToGalleryDetailScreen(context: context, gallery: gallery, index: index, loggedInAs: loggedInAs);
                  },
                ),
                ListTile(
                  leading: new Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  title: new Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddEditGalleryScreen(context: context, gallery: gallery[index], editing: true);
                  },
                ),
                ListTile(
                    leading: new Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: new Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      showConfirmDeleteModalAlertDialog(context: context, title: gallery[index].title).then((value){
                        if(value!=null){
                          if(value)
                            _galleryBloc.add(DeleteGalleryEvent(gallery[index].id));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }

  static void _navigateToAddEditGalleryScreen({BuildContext context, Gallery gallery, bool editing, GalleryBloc galleryBloc}) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditGallery(gallery: gallery, editing: editing,)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
      viewSchoolGallery();
    }
  }

  static void _navigateToGalleryDetailScreen({BuildContext context, List<Gallery> gallery, int index, String loggedInAs}) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SchoolGalleryDetails(gallery: gallery, index: index, loggedInAs: loggedInAs)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
      viewSchoolGallery();
    }
  }

}


Widget _buildGallery(
    BuildContext context, List<Gallery> gallery, int index, String loggedInAs) {
  return (!gallery[index].deleted)?Padding(
    padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
    child: Center(
        child: GestureDetector(
          onTap: (){
            ViewSchoolGalleryPage._navigateToGalleryDetailScreen(context: context, gallery: gallery, index: index, loggedInAs: loggedInAs);
          },
          onLongPress: (){
            if((loggedInAs==MyStrings.school))
            ViewSchoolGalleryPage.showOptionsModalBottomSheet(context: context, gallery: gallery, index: index, loggedInAs: loggedInAs);
          },
          child: Container(
            width: double.maxFinite,
            height: 200.0,
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  child: FadeInImage.assetNetwork(
                    fit: BoxFit.fitWidth,
                    fadeInDuration: const Duration(seconds: 1),
                    fadeInCurve: Curves.easeInCirc,
                    placeholder: 'lib/assets/images/avatar.png',
                    image: gallery[index].imageUrl +
                        gallery[index].images.split(',')[0].trim(),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  color: Colors.black.withOpacity(0.5),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(gallery[index].sessions.sessionDate,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(gallery[index].date,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(gallery[index].title,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('( ${((gallery[index].images.isNotEmpty)?gallery[index].images.split(',').length:0)+((gallery[index].videos.isNotEmpty)?gallery[index].videos.split(',').length:0)} )',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ),
        )),
  ):Container();
}
class CustomSearchDelegate extends SearchDelegate {
  final List<Gallery> gallery;
  final String loggedInAs;
  CustomSearchDelegate(this.gallery, this.loggedInAs);

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
          ? gallery
          : gallery
          .where((p) =>
          p.title.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildGallery(context, suggestionList, index, loggedInAs);
          });
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
          ? gallery
          : gallery
          .where((p) =>
          p.title.toUpperCase().contains(query.toUpperCase()))
          .toList();
      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildGallery(context, suggestionList, index, loggedInAs);
          });
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


