import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';

class ViewChatGroupDetails extends StatelessWidget {
  final Group group;
  ViewChatGroupDetails({this.group});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: ChatRequests()),
      child: ViewChatGroupDetailsPage(group),
    );
  }
}

// ignore: must_be_immutable
class ViewChatGroupDetailsPage extends StatelessWidget {
  final Group group;
  ViewChatGroupDetailsPage(this.group);
  ChatBloc _chatBloc;
  @override
  Widget build(BuildContext context) {
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[

            ],
            pinned: true,
            floating: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                centerTitle: true,
                title: Text(toSentenceCase(group.name)),
                titlePadding: const EdgeInsets.all(15.0),
                background: Hero(
                  tag: "contact passport tag",
                  transitionOnUserGestures: true,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImage(
                                imageUrl: [group.imageLink + group.image],
                                heroTag: "contact passport tag",
                                placeholder: 'lib/assets/images/avatar.png',
                                position: 0,
                              ),
                            ));
                      },
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.fitWidth,
                        fadeInDuration: const Duration(seconds: 1),
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: 'lib/assets/images/avatar.png',
                        image: group.imageLink+group.image,
                      ),
                    ),
                  ),
                )),
          ),
          BlocListener<ChatBloc, ChatStates>(
            listener: (context, state) {
              if (state is Processing) {
                Scaffold.of(context).showSnackBar(
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
                if (state.message == "Please Login to continue") {
                  reLogUserOut(context);
                }
              }else if (state is ChatGroupsLoaded) {
                Scaffold.of(context).removeCurrentSnackBar();
              }
            },
            child: BlocBuilder<ChatBloc, ChatStates>(
              builder: (context, state) {
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 8.0),
                                  child: Text(toSentenceCase(group.description),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ],
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
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0, top: 5.0, bottom: 2.0),
                                      child: Text('${group.members.length} Members',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: _buildGroupMembersList(context, group.members),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ]
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildGroupMembersList(BuildContext context, List<Contact> contacts) {
    List<Widget> choices = List();
    int index=0;
    contacts.forEach((item) {
      choices.add(Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Hero(
                        tag: "contact passport tag $index",
                        transitionOnUserGestures: true,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                              placeholderScale: 5,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(seconds: 1),
                              fadeInCurve: Curves.easeInCirc,
                              placeholder: 'lib/assets/images/avatar.png',
                              image: item.passportLink + item.passport,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImage(
                                imageUrl: [item.passportLink + item.passport],
                                heroTag: "contact passport tag $index",
                                placeholder: 'lib/assets/images/avatar.png',
                                position: 0,
                              ),
                            ));
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              (group.creatorId==item.id)?Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                child: Text('Group Admin',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.end,
                                ),
                              ):Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                  child: Text(toSentenceCase(item.userType),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text('${toSentenceCase(item.userName)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          (item.userType=='student')?Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                  child: Text(toSentenceCase(item.admissionNumber),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                  child: Text(toSentenceCase(item.classDetails),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ),
                            ],
                          ):Container(),
                          Divider(
                            color: Colors.black87,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                onTap: () {
                  if(group.creatorId!=item.id){
                    _showContactOptionsModalBottomSheet(context: context, contact: item);
                  }
                },
                onLongPress: (){
                  if(group.creatorId!=item.id){
                    _showContactOptionsModalBottomSheet(context: context, contact: item);
                  }
                },
              ),
            ],
          ),
      ));
      index++;
    }); return choices;
  }

  _showContactOptionsModalBottomSheet({BuildContext context, Contact contact}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
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
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  title: new Text('Remove Member'),
                  onTap: () {
                    Navigator.pop(context);

                  },
                ),
              ],
            ),
          );
        });
  }

}
