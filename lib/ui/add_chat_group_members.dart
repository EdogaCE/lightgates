import 'package:flutter/material.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/requests/get/view_chat_requests.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddChatGroupMembers extends StatelessWidget {
  final String userId;
  final String userType;
  final String groupId;
  final List<Contact> contacts;
  final Group group;
  AddChatGroupMembers({this.contacts, this.userId, this.groupId, this.userType, this.group});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(viewChatRepository: ViewChatRequest(), chatRepository: ChatRequests()),
      child: AddChatGroupMembersPage(userId, userType, groupId, contacts, group),
    );
  }
}

// ignore: must_be_immutable
class AddChatGroupMembersPage extends StatelessWidget {
  final String userId;
  final String userType;
  final String groupId;
  List<Contact> contacts;
  final Group group;
  AddChatGroupMembersPage(this.userId, this.userType, this.groupId, this.contacts, this.group);
  ChatBloc _chatBloc;

  List<Contact> selectedMembers=List();
  List<String> selectedMembersId=List();
  ScrollController scrollController=ScrollController();

  _viewChatContacts()async{
    _chatBloc.add(ViewChatContactsEvent(await getApiToken(), userId, userType, false));
  }

  @override
  Widget build(BuildContext context) {
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    //_viewChatContacts();
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[

            ],
            title: Text('Add Group Members')
        ),
        body: Container(
          child: Column(
            children: [
              BlocListener<ChatBloc, ChatStates>(listener:
                  (BuildContext context, ChatStates state) {
                if (state is MemberSelected) {
                  selectedMembers.add(state.membersContact);
                  selectedMembersId.add(state.memberId);
                  scrollController.animateTo(selectedMembers.length.roundToDouble(), duration: Duration(milliseconds: 500), curve: Curves.ease);

                }else if (state is MemberDeSelected) {
                  selectedMembers.remove(state.membersContact);
                  selectedMembersId.remove(state.memberId);
                }
              },
                child:BlocBuilder<ChatBloc, ChatStates>(builder:
                    (BuildContext context, ChatStates state) {
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    reverse: true,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: _buildSelectedMembersList(context, selectedMembers),
                    ),
                  );
                }),
              ),
              Divider(color: Colors.black45),
              Expanded(
                flex: 1,
                child: BlocListener<ChatBloc, ChatStates>(listener:
                    (BuildContext context, ChatStates state) {
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
                  } else if (state is ChatContactsLoaded) {
                    contacts=state.chatContacts;
                  } else if (state is GroupMembersAdded) {
                    Navigator.pop(context, state.message);
                  }
                    },
                  child:BlocBuilder<ChatBloc, ChatStates>(builder:
                      (BuildContext context, ChatStates state) {
                    if(state is ChatInitial){
                      try{
                        return _buildContactsScreen(context, contacts);
                      }on NoSuchMethodError{
                        return buildInitialScreen();
                      }
                    }else if (state is Loading) {
                      try{
                        return _buildContactsScreen(context, contacts);
                      }on NoSuchMethodError{
                        return buildLoadingScreen();
                      }

                    } else if (state is ChatContactsLoaded) {
                      return _buildContactsScreen(context, state.chatContacts);
                    } else if (state is ViewError) {
                      try{
                        return _buildContactsScreen(context, contacts);
                      }on NoSuchMethodError{
                        return buildNODataScreen();
                      }
                    } else if (state is NetworkErr) {
                      try{
                        return _buildContactsScreen(context, contacts);
                      }on NoSuchMethodError{
                        return buildNetworkErrorScreen();
                      }
                    } else {
                      try{
                        return _buildContactsScreen(context, contacts);
                      }on NoSuchMethodError{
                        return buildInitialScreen();
                      }
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: BlocBuilder<ChatBloc, ChatStates>(builder:
          (BuildContext context, ChatStates state) {
        return (selectedMembers.isNotEmpty)?FloatingActionButton(
          heroTag: "Create Group",
          onPressed: () {
            _chatBloc.add(AddGroupMembersEvent(groupId, selectedMembersId));
          },
          child: Icon(Icons.arrow_forward),
          backgroundColor: MyColors.primaryColor,
        ):Container();
      })
    );
  }

  Widget buildInitialScreen() {
    return Center(
      child: Scaffold(),
    );
  }

  Widget buildLoadingScreen() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    MyColors.primaryColor),
                backgroundColor: Colors.pink,
              ),
            )),
      ),
    );
  }

  Widget buildNODataScreen() {
    return Align(
      alignment: Alignment.center,
      child: SvgPicture.asset(
        MyStrings.noData,
        height: 150.0,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget buildNetworkErrorScreen() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        child: SvgPicture.asset(
          MyStrings.networkError,
          height: 150.0,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fitWidth,
        ),
        onTap: () => _viewChatContacts(),
      ),
    );
  }

  Widget _buildContactsScreen(BuildContext context, List<Contact> contacts) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildContactsRow(context, contacts, index, userId, userType);
        });
  }

  Widget _buildContactsRow(BuildContext context, List<Contact> contacts, int index, String userChatId, String userType) {
    return ((userChatId==contacts[index].id)||(group.memberIds.split(',').contains(contacts[index].id)))
        ?Container():Padding(
      padding: const EdgeInsets.all(2.0),
      child: Center(
        child: ListTile(
          title: Row(
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: "student passport tag $index",
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
                          image: contacts[index].passportLink +
                              contacts[index].passport,
                        ),
                      ),
                    ),
                  ),
                  (selectedMembers.contains(contacts[index]))?Align(
                    alignment: Alignment.bottomLeft,
                    child: Icon(Icons.check_circle, color: Colors.teal,),
                  ):Container()
                ],
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.maxFinite,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                        child: Text(toSentenceCase(contacts[index].userType),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              color: MyColors.primaryColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text('${toSentenceCase(contacts[index].userName)}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    (contacts[index].userType=='student')?Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                            child: Text(toSentenceCase(contacts[index].admissionNumber),
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
                            child: Text(toSentenceCase(contacts[index].classDetails),
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
            if(selectedMembersId.contains(contacts[index].id)){
              _chatBloc.add(DeSelectMemberEvent(contacts[index].id, contacts[index]));
            }else{
              _chatBloc.add(SelectMemberEvent(contacts[index].id, contacts[index]));
            }
          },
          onLongPress: (){

          },
        ),
      ),
    );
  }

  _buildSelectedMembersList(BuildContext context, List<Contact> contacts) {
    List<Widget> choices = List();
    contacts.forEach((item) {
      choices.add(GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(8.0),
            child:Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Padding(
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
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.cancel, color: Colors.redAccent)
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                  child: Text('${toSentenceCase(item.userName.split(' ').first)}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            )
        ),
        onTap: (){
          _chatBloc.add(DeSelectMemberEvent(item.id, item));
        },
      ));
    });   return choices;
  }
}
