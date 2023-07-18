import 'package:flutter/material.dart';
import 'package:school_pal/blocs/learning_materials/learning_materials.dart';
import 'package:school_pal/models/learning_materials.dart';
import 'package:school_pal/requests/get/view_learning_materials_request.dart';
import 'package:school_pal/requests/posts/add_edit_learning_material_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/play_video.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearningMaterialsDetails extends StatelessWidget {
  final List<LearningMaterials> learningMaterials;
  final int index;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  LearningMaterialsDetails({this.learningMaterials, this.index, this.loggedInAs, this.userId, this.classes, this.subject});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LearningMaterialsBloc(viewLearningMaterialsRepository: ViewLearningMaterialsRequest(),
              learningMaterialRepository: LearningMaterialRequests()),
      child: LearningMaterialsDetailsPage(learningMaterials, index, loggedInAs, userId, classes, subject),
    );
  }
}

// ignore: must_be_immutable
class LearningMaterialsDetailsPage extends StatelessWidget {
  List<LearningMaterials> learningMaterials;
  final int index;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  LearningMaterialsDetailsPage(this.learningMaterials, this.index, this.loggedInAs, this.userId, this.classes, this.subject);

  YoutubePlayerController _controller;
  LearningMaterialsBloc _learningMaterialsBloc;
  void _viewLearningMaterials() async {
    _learningMaterialsBloc.add(ViewLearningMaterialsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {

    _learningMaterialsBloc = BlocProvider.of<LearningMaterialsBloc>(context);
    _viewLearningMaterials();

    _controller = YoutubePlayerController(
      initialVideoId: (learningMaterials[index].video.split(',')[0].isNotEmpty)?YoutubePlayer.convertUrlToId(learningMaterials[index].video.split(',')[0]):' ',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                centerTitle: true,
                title: Text('Learning Materials'),
                titlePadding: const EdgeInsets.all(15.0),
                background: Center(
                  child: Hero(
                    tag: "assessment tag $index",
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                          child: SvgPicture.asset(
                              "lib/assets/images/learning3.svg")),
                    ),
                  ),
                )),
          ),
          BlocListener<LearningMaterialsBloc, LearningMaterialsStates>(
            listener: (context, state) {
              //Todo: note listener returns void
              if (state is NetworkErr) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                      Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
              } else if (state is ViewError) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                      Text(state.message, textAlign: TextAlign.center),
                    ),
                  );
                if (state.message == "Please Login to continue") {
                  reLogUserOut(context);
                }
              } else if (state is LearningMaterialsLoaded) {
                learningMaterials = (loggedInAs==MyStrings.teacher)?state.learningMaterials
                    .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject)&&(p.teacherId==userId))
                    .toList():state.learningMaterials
                    .where((p) => (p.classDetail.contains(classes)&&(p.subjectDetail==subject)))
                    .toList();
              }else if (state is Processing){
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(minutes: 30),
                    content: General.progressIndicator("Processing..."),
                  ),
                );
              }else if (state is LearningMaterialUpdated) {
                Scaffold.of(context).removeCurrentSnackBar();
                _viewLearningMaterials();
              }
            },
            child: BlocBuilder<LearningMaterialsBloc, LearningMaterialsStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Card(
                        // margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Text(
                                    '${toSentenceCase(learningMaterials[index].title)}:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Html(
                                data: learningMaterials[index].description,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Card(
                          // margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                      'Videos:',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: MyColors.primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                learningMaterials[index].video.isNotEmpty?Wrap(
                                  alignment: WrapAlignment.center,
                                  children: _buildVideoList(context, learningMaterials[index].video.split(',')),
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        // margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Text(("Files: "),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: _buildFileList(
                                    context,
                                    learningMaterials[index].file.split(','),
                                    learningMaterials[index].fileUrl),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  _buildFileList(BuildContext context, List<String> fileList, String fileUrl) {
    List<Widget> choices = List();
    fileList.forEach((item) {
      choices.add((item.isNotEmpty)?GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            backgroundColor: (index + 1 < 5)
                ? Colors.teal[200 * (index + 1 % 9)]
                : Colors.teal,
            label: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      (item.split('.').last == 'jpg' ||
                          item.split('.').last == 'png' ||
                          item.split('.').last == 'gif')?Icons.image:Icons.library_books,
                      color: Colors.blue,
                      size: 14,
                    ),
                    Text((toSentenceCase(item)),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ),
            selected: false,
            onSelected: (selected) {
              if( (item.split('.').last == 'jpg' ||
                  item.split('.').last == 'png' ||
                  item.split('.').last == 'gif')){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewImage(imageUrl: [fileUrl + item],
                            heroTag: 'gallery image $index',
                          placeholder: MyStrings.logoPath,
                            position: 0,
                          ),
                    ));
              }else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewLoader(
                        url: 'https://docs.google.com/viewer?url=${fileUrl + item}',
                        downloadLink: fileUrl+item,
                        title: item.split('.').first,
                      )),
                );
              }
            },
          ),
        ),
        onLongPress: (){
          if(loggedInAs==MyStrings.teacher)
            showFileOptionsModalBottomSheet(context: context, file: item, fileUrl: fileUrl);
        },
      ):Container());
    });
    return choices;
  }

  _buildVideoList(BuildContext context, List<String> video) {
    List<Widget> videos = List();
    video.forEach((item) {
      _controller.load(YoutubePlayer.convertUrlToId(item.toString()));
      videos.add(Stack(
        children: <Widget>[
          Container(
              width: 100.0,
              height: 100.0,
              child: Hero(
                tag: 'materials video $index',
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: MyColors.primaryColor,
                ),
              )
          ),
          Container(
            width: 100.0,
            height: 100.0,
            color: Colors.black.withOpacity(0.2),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayVideo(videoUrl: item.toString(), heroTag: 'materials video $index'),
                    ));
              },
              onLongPress: (){
                if(loggedInAs==MyStrings.teacher)
                  showVideoOptionsModalBottomSheet(context: context, video: item);
              },
            ),
          ),
        ],
      ));
    });
    return videos;
  }

  void showFileOptionsModalBottomSheet({BuildContext context, String fileUrl, String file}) {
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
                    if( (file.split('.').last == 'jpg' ||
                        file.split('.').last == 'png' ||
                        file.split('.').last == 'gif')){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewImage(imageUrl: [fileUrl + file],
                                  heroTag: 'gallery image $index',
                                  placeholder: MyStrings.logoPath,
                                  position: 0,
                                ),
                          ));
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewLoader(
                              url: 'https://docs.google.com/viewer?url=${fileUrl + file}',
                              downloadLink: fileUrl+file,
                              title: file.split('.').first,
                            )),
                      );
                    }
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
                      showConfirmDeleteModalAlertDialog(context: context, title: file).then((value){
                        if(value!=null){
                          if(value)
                            _learningMaterialsBloc.add(UpdateLearningMaterialEvent(learningMaterials[index].id,
                                learningMaterials[index].classesId,
                                [], learningMaterials[index].description, learningMaterials[index].video.split(','), learningMaterials[index].title, learningMaterials[index].teacherId,
                                learningMaterials[index].subjectId, [file]));
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
                            _learningMaterialsBloc.add(UpdateLearningMaterialEvent(learningMaterials[index].id,
                                learningMaterials[index].classesId,
                                [], learningMaterials[index].description, learningMaterials[index].video.split(',')..remove(video), learningMaterials[index].title, learningMaterials[index].teacherId,
                                learningMaterials[index].subjectId, []));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }

}

