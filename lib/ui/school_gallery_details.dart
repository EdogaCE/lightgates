import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/blocs/gallery/gallery.dart';
import 'package:school_pal/blocs/navigatoins/navigation.dart';
import 'package:school_pal/models/gallery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_school_gallery_request.dart';
import 'package:school_pal/requests/posts/add_event_gallery_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/play_video.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SchoolGalleryDetails extends StatelessWidget {
  final List<Gallery> gallery;
  final int index;
  final String loggedInAs;
  SchoolGalleryDetails({this.gallery, this.index, this.loggedInAs});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GalleryBloc>(
          create: (context) => GalleryBloc(viewSchoolGalleryRepository: ViewSchoolGalleryRequest(),
              addEventGalleryRepository: AddEventGalleryRequests()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
      ],
      child: SchoolGalleryDetailsPage(gallery, index, loggedInAs),
    );

  }
}

// ignore: must_be_immutable
class SchoolGalleryDetailsPage extends StatelessWidget {
  List<Gallery> gallery;
  final int index;
  final String loggedInAs;
  SchoolGalleryDetailsPage(this.gallery, this.index, this.loggedInAs);
  bool _updated=false;
  GalleryBloc _galleryBloc;
  NavigationBloc _navigationBloc;
  List<String> images;
  int imageIndex = 0;
  YoutubePlayerController _controller;

  void viewSchoolGallery() async {
    _galleryBloc.add(ViewGalleryEvent(await getApiToken()));
  }


  @override
  Widget build(BuildContext context) {
    _galleryBloc = BlocProvider.of<GalleryBloc>(context);
    _navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final RefreshController _refreshController = RefreshController();
    viewSchoolGallery();
    images = gallery[index].images.split(',');
    Timer.periodic(Duration(seconds: 10), (timer) {
      try{
        _navigationBloc.add(ChangeGalleryImageEvent((imageIndex + 1) % images.length));
      }catch(e){}
    });

     _controller = YoutubePlayerController(
      initialVideoId: gallery[index].videos.split(',')[0].isNotEmpty?YoutubePlayer.convertUrlToId(gallery[index].videos.split(',')[0]):'',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );
    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
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
                  pinned: true,
                  floating: true,
                  expandedHeight: 250.0,
                  //title: SABT(child: Text(_classes[0].label.toUpperCase())),
                  flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      title: Text(gallery[index].title.toUpperCase()),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: BlocListener<NavigationBloc, NavigationStates>(
                        listener: (context, state) {
                          if (state is GalleryImageChanged)
                            imageIndex = state.index;
                          //Todo: note listener returns void
                        },
                        child: BlocBuilder<NavigationBloc, NavigationStates>(
                          builder: (context, state) {
                            //Todo: note builder returns widget
                            return GestureDetector(
                              onTap: () => _navigationBloc.add(
                                  ChangeGalleryImageEvent(
                                      (imageIndex + 1) % images.length)),
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(seconds: 1),
                                fadeInCurve: Curves.easeInCirc,
                                placeholder: 'lib/assets/images/avatar.png',
                                image: images.isNotEmpty ? gallery[index]
                                    .imageUrl + images[imageIndex] : '',
                              ),
                            );
                          },
                        ),
                      )),
                ),
                BlocListener<GalleryBloc, GalleryStates>(
                  listener: (context, state) {
                    //Todo: note listener returns void
                    if (state is NetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                    } else if (state is ViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      if (state.message == "Please Login to continue") {
                        reLogUserOut(context);
                      }
                    } else if (state is GalleryLoaded) {
                      gallery = state.gallery;
                    }else if(state is Processing){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if(state is GalleryUpdated){
                      _updated=true;
                      Scaffold.of(context).removeCurrentSnackBar();
                      viewSchoolGallery();
                    }
                  },
                  child: BlocBuilder<GalleryBloc, GalleryStates>(
                    builder: (context, state) {
                      //Todo: note builder returns widget
                      return _buildLoadedScreen(context, gallery[index].images.split(','),
                          gallery[index].videos.split(','), gallery[index].imageUrl, gallery[index].title, gallery[index].description);
                    },
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Card(
                          // margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          elevation: 2,
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(gallery[index].description,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: MyColors.primaryColor,
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ],
                    ))
              ],
            )),
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context, List<String> images,
      List<String> video, String imageUrl, String title, String description) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 2.0,
      ),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return (index < images.length) ? _buildGallery(
            context, images, imageUrl, index) :(video[index-images.length].isNotEmpty)?_buildVideo(context, video, index-images.length):Container();
      }, childCount: images.length + video.length),
    );
  }

  Widget _buildGallery(BuildContext context, List<String> images, String imageUrl, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Center(
          child: GestureDetector(
            onTap: () {
              List<String> viewImages=List();
              for(String image in images){
                viewImages.add(imageUrl+image);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewImage(imageUrl: viewImages,
                          heroTag: 'gallery image $index',
                          placeholder: 'lib/assets/images/avatar.png',
                          position: index,
                        ),
                  ));
            },
            onLongPress: (){
              if((loggedInAs==MyStrings.school))
                showImageOptionsModalBottomSheet(context: context, imageUrl: imageUrl, images: images, index: index);
            },
            child: Container(
                width: double.maxFinite,
                height: 200.0,
                child: Hero(
                  tag: 'gallery image $index',
                  child: FadeInImage.assetNetwork(
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(seconds: 1),
                    fadeInCurve: Curves.easeInCirc,
                    placeholder: 'lib/assets/images/avatar.png',
                    image: imageUrl + images[index],
                  ),
                )
            ),
          )),
    );
  }

  Widget _buildVideo(
      BuildContext context, List<String> video, int index) {
    _controller.load(YoutubePlayer.convertUrlToId(video[index]));
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Container(
        child: Stack(
          children: <Widget>[
            Center(
                child: Container(
                    width: double.maxFinite,
                    height: 200.0,
                    child: Hero(
                      tag: 'gallery video $index',
                      child: YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: MyColors.primaryColor,
                      ),
                    )
                )),
            Container(
              width: double.maxFinite,
              height: 200.0,
              color: Colors.black.withOpacity(0.2),
              child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayVideo(videoUrl: video[index], heroTag: 'gallery video $index'),
                          ));
                    },
                    onLongPress: (){
                      if((loggedInAs==MyStrings.school))
                        showVideoOptionsModalBottomSheet(context: context, video: video[index]);
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void showImageOptionsModalBottomSheet({BuildContext context, String imageUrl, List<String> images, int index}) {
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
                    List<String> viewImages=List();
                    for(String image in images){
                      viewImages.add(imageUrl+image);
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewImage(imageUrl: viewImages,
                                heroTag: 'gallery image $index',
                                placeholder: 'lib/assets/images/avatar.png',
                                position: index,
                              ),
                        ));
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
                      showConfirmDeleteModalAlertDialog(context: context, title: images[index]).then((value){
                        if(value!=null){
                          print([images[index]]);
                          if(value)
                            _galleryBloc.add(UpdateGalleryEvent(gallery[index].id,
                                gallery[index].title, gallery[index].sessions.id,
                                gallery[index].description, [], gallery[index].videos.split(','),
                                gallery[index].sessionId, [images[index]]));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }

  void showVideoOptionsModalBottomSheet({BuildContext context, String video}) {
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayVideo(videoUrl: video, heroTag: 'gallery video $index'),
                        ));
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
                      showConfirmDeleteModalAlertDialog(context: context, title: video).then((value){
                        if(value!=null){
                          if(value)
                            _galleryBloc.add(UpdateGalleryEvent(gallery[index].id,
                                gallery[index].title, gallery[index].sessions.id, gallery[index].description, [],
                                gallery[index].videos.split(',')..remove(video), gallery[index].sessionId, []));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_updated) {
      print("onwill goback");
      Navigator.pop(context, 'new update');
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}
