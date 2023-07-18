import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/models/news.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/news_comment.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/requests/posts/add_edit_faq_news_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';

class NewsComments extends StatelessWidget {
  final News news;
  NewsComments({this.news});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(createFaqNewsRepository: CreateFaqNewsRequests()),
      child: NewsCommentsPage(news),
    );
  }
}

// ignore: must_be_immutable
class NewsCommentsPage extends StatelessWidget {
  final News news;
  NewsCommentsPage(this.news);

  DashboardBloc _dashboardBloc;
  final commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  child: Text(news.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _buildCommentList(context, news.comments),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.0),
                  border: Border.all(color: MyColors.primaryColor,
                      style: BorderStyle.solid,
                      width: 0.80),
                  color: Colors.white
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: TextFormField(
                              controller: commentController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(25.0),
                                    ),
                                  ),
                                  //icon: Icon(Icons.email),
                                  prefixIcon:
                                  Icon(Icons.comment, color: Colors.blue),
                                  labelText: 'Comment',
                                  labelStyle:
                                  new TextStyle(color: Colors.grey[800]),
                                  filled: true,
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: FloatingActionButton(
                          heroTag: "Send comment",
                          onPressed: () async {
                            User user=await retrieveLoginDetailsFromSF();
                            if (_formKey.currentState.validate()) {
                              _dashboardBloc.add(AddNewsCommentEvent(news.id, user.id, commentController.text));
                            }
                          },
                          child: Icon(Icons.send),
                          backgroundColor: MyColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  _buildCommentList(BuildContext context, List<NewsComment> tagList) {
    List<Widget> choices = List();
    tagList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: GestureDetector(
          child: ChoiceChip(
            //backgroundColor: Colors.white54,
            label: Text(item.content),
            selected: false,
            onSelected: (selected) {

            },
          ),
          onLongPress: (){
            showOptionsModalBottomSheet(context: context, newsComment: item);
          },
        ),
      ));
    });    return choices;
  }

  void showOptionsModalBottomSheet({BuildContext context, NewsComment newsComment}) {
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
                    Icons.edit,
                    color: Colors.green,
                  ),
                  title: new Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    showEditMessageModalDialog(context: context, newsComment: newsComment);
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
                      _dashboardBloc.add(DeleteNewsCommentEvent(newsComment.id));
                    }),
              ],
            ),
          );
        });
  }

  void showEditMessageModalDialog({BuildContext context, NewsComment newsComment}){
    final _textController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
      _textController.text=newsComment.content;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child:Container(
                height: 230,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Edit message',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _textController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value.isEmpty) {
                                return ' ';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(25.0),
                                  ),
                                ),
                                //icon: Icon(Icons.email),
                                prefixIcon:
                                Icon(Icons.comment, color: MyColors.primaryColor),
                                labelText: "Comment",
                                labelStyle: new TextStyle(color: Colors.grey[800]),
                                filled: true,
                                fillColor: Colors.white70),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.maxFinite,
                          //height: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () async {
                              User user=await retrieveLoginDetailsFromSF();
                              if(_formKey.currentState.validate()){
                                _dashboardBloc.add(UpdateNewsCommentEvent(newsComment.id,  user.userName, user.contactEmail, _textController.text));
                              }
                            },
                            textColor: Colors.white,
                            color: MyColors.primaryColor,
                            padding: const EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
                              child: const Text("Done",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
          );
        });
  }
}
