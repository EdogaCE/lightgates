import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:school_pal/models/news.dart';
import 'package:school_pal/requests/posts/add_edit_faq_news_requests.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class CreateEditNews extends StatelessWidget {
  final News news;
  final String type;
  CreateEditNews({this.news, this.type});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(createFaqNewsRepository: CreateFaqNewsRequests()),
      child: CreateEditNewsPage(news, type),
    );
  }
}

// ignore: must_be_immutable
class CreateEditNewsPage extends StatelessWidget {
  final News news;
  final String type;
  CreateEditNewsPage(this.news, this.type);
  DashboardBloc dashboardBloc;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tagController = TextEditingController();
  List<String> tagList = List();
  @override
  Widget build(BuildContext context) {
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    try{
      titleController.text=news.title;
      contentController.text=news.content;
      tagList=news.tags.split(',');
    } on NoSuchMethodError{}
    return Scaffold(
      appBar: AppBar(
      title: Text('$type News', style: TextStyle(color: MyColors.primaryColor)),
        elevation: 0.0,
        backgroundColor: Colors.white,
        //Todo: to change back button color
        iconTheme: IconThemeData(color: MyColors.primaryColor),
      ),
      body: Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: titleController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter news title.';
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
                                    Icon(Icons.title, color: Colors.blue),
                                    labelText: 'News Title',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: contentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter news content.';
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
                                    Icon(Icons.priority_high, color: Colors.green),
                                    labelText: 'News Content',
                                    labelStyle: new TextStyle(
                                        color: Colors.grey[800]),
                                    filled: true,
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  BlocListener<DashboardBloc, DashboardStates>(
                                    listener: (BuildContext context,
                                        DashboardStates state) {
                                      if (state is TagAddedToList) {
                                        if (state.tag.isNotEmpty)
                                          tagList.add(state.tag);
                                      } else if (state is TagRemovedFromList) {
                                        tagList.remove(state.tag);
                                      } else  if (state is Processing) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            duration: Duration(minutes: 30),
                                            content: General.progressIndicator("Processing..."),
                                          ),
                                        );
                                      }else if (state is NewsAdded) {
                                        Scaffold.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(state.message, textAlign: TextAlign.center),
                                            ),
                                          );
                                       Navigator.pop(context, state.message);
                                      } else if (state is NewsUpdated) {
                                        Scaffold.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(state.message, textAlign: TextAlign.center),
                                            ),
                                          );
                                        Navigator.pop(context, state.message);
                                      }else if (state is NetworkErr) {
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
                                      }
                                    },
                                    child: BlocBuilder<DashboardBloc, DashboardStates>(
                                      builder: (BuildContext context,
                                          DashboardStates state) {
                                        return Wrap(
                                          children:
                                          _buildTagList(tagList),
                                        );
                                      },
                                    ),
                                  ),
                                  TextFormField(
                                    controller: tagController,
                                    keyboardType: TextInputType.url,
                                    validator: (value) {
                                      /* if (value.isEmpty) {
                                          return 'Please enter video link.';
                                        }*/
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          const BorderRadius.all(
                                            const Radius.circular(25.0),
                                          ),
                                        ),
                                        //icon: Icon(Icons.email),
                                        prefixIcon: Icon(Icons.brightness_1,
                                            color: Colors.orange),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            dashboardBloc.add(
                                                AddTagToListEvent(tagController.text));
                                            tagController.clear();
                                          },
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: MyColors.primaryColor,
                                          ),
                                        ),
                                        labelText: 'News Tag',
                                        labelStyle: new TextStyle(
                                            color: Colors.grey[800]),
                                        filled: true,
                                        fillColor: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 15.0, right: 8.0, bottom: 15.0),
                            child: _createClassButtonFill(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  _buildTagList(List<String> youtubeLinkList) {
    List<Widget> choices = List();
    youtubeLinkList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item),
              Icon(
                Icons.cancel,
                size: 15,
              )
            ],
          ),
          selected: false,
          onSelected: (selected) {
            dashboardBloc.add(RemoveTagToListEvent(item));
          },
        ),
      ));
    });
    return choices;
  }

  Widget _createClassButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      //height: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          tagList.add(tagController.text);
          if(_formKey.currentState.validate())
          switch (type){
            case 'Add':{
              dashboardBloc.add(AddNewsEvent(titleController.text, contentController.text, tagList.join(',')));
              break;
            }
            case 'Edit':{
              dashboardBloc.add(UpdateNewsEvent(news.id, titleController.text, contentController.text, tagList.join(',')));
              break;
            }
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
          child: const Text("Done", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
  
}
