import 'package:flutter/material.dart';
import 'package:school_pal/models/assessments.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/ui/web_view_loader.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/assessments/assessments.dart';
import 'package:school_pal/requests/get/view_assessments_request.dart';
import 'package:school_pal/requests/posts/add_edit_assessment_request.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/modals.dart';
import 'general.dart';

class AssessmentsDetails extends StatelessWidget {
  final List<Assessments> assessments;
  final int index;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  AssessmentsDetails({this.assessments, this.index,  this.loggedInAs, this.classes, this.subject, this.userId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AssessmentsBloc(viewAssessmentsRepository: ViewAssessmentsRequest(), assessmentRepository: AssessmentRequests()),
      child: AssessmentsDetailsPage(assessments, index, loggedInAs, userId, classes, subject),
    );
  }
}

// ignore: must_be_immutable
class AssessmentsDetailsPage extends StatelessWidget {
  List<Assessments> assessments;
  final int index;
  final String loggedInAs;
  final String userId;
  final String classes;
  final String subject;
  AssessmentsDetailsPage(this.assessments, this.index, this.loggedInAs, this.userId, this.classes, this.subject);

  AssessmentsBloc _assessmentsBloc;
  void _viewAssessments() async {
    _assessmentsBloc.add(ViewAssessmentsEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    _assessmentsBloc = BlocProvider.of<AssessmentsBloc>(context);
    _viewAssessments();
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
                title: Text(toSentenceCase(assessments[index].type)),
                titlePadding: const EdgeInsets.all(15.0),
                background: Center(
                  child: Hero(
                    tag: "assessment tag $index",
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                          child: SvgPicture.asset(
                              "lib/assets/images/assessment3.svg")),
                    ),
                  ),
                )),
          ),
          BlocListener<AssessmentsBloc, AssessmentsStates>(
            listener:
                (BuildContext context, AssessmentsStates state) {
             if (state is AssessmentUpdated) {
               Scaffold.of(context).removeCurrentSnackBar();
               _viewAssessments();
              }else if (state is AssessmentsLoaded) {
               assessments = (loggedInAs==MyStrings.teacher)?state.assessments
                   .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject)&&(p.teacherId==userId))
                   .toList():state.assessments
                   .where((p) => (p.classDetail.contains(classes))&&(p.subjectDetail==subject))
                   .toList();

             } else  if (state is Processing) {
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      duration: Duration(minutes: 30),
                      content: General.progressIndicator("Processing..."),
                    ),
                  );
              }else if (state is NetworkErr) {
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
             }
            },
            child: BlocBuilder<AssessmentsBloc, AssessmentsStates>(
              builder:
                  (BuildContext context, AssessmentsStates state) {
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
                                    ("${toSentenceCase(assessments[index].type)}:  "),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text((toSentenceCase(assessments[index].title)),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold)),
                              Html(
                                data: assessments[index].content,
                              ),
                            ],
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
                                    assessments[index].file.split(','),
                                    assessments[index].fileUrl),
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
                                  padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(("Instructions:  "),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: MyColors.primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Html(
                                  data: assessments[index].instructions,
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                      ("Submission mode: ${toSentenceCase(assessments[index].submissionMode)}"),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ],
                            ),
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
                                  padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(("Info:  "),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: MyColors.primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                      (int.parse(assessments[index].noOfSubmission) <
                                          1)
                                          ? 'No submissions yet'
                                          : ("${toSentenceCase(assessments[index].noOfSubmission)} persons already submitted"),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
                      (item.split('.')[1] == 'jpg' ||
                          item.split('.')[1] == 'png' ||
                          item.split('.')[1] == 'gif')?Icons.image:Icons.library_books,
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
            showFileOptionsModalBottomSheet(context: context, fileUrl: fileUrl, file: item);
        },
      ):Container());
    });
    return choices;
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
                          _assessmentsBloc.add(UpdateAssessmentEvent(assessments[index].id,
                              assessments[index].termId, assessments[index].sessionId,
                              assessments[index].classesId, assessments[index].subjectId,
                              assessments[index].teacherId, assessments[index].title, assessments[index].type,
                              assessments[index].submissionMode, assessments[index].instructions,
                              [], assessments[index].content,
                              assessments[index].date.split('=>').last.trim(), [file]));
                        }
                      });
                    }),
              ],
            ),
          );
        });
  }
}
