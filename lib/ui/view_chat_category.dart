import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/providers/notification_provider.dart';
import 'package:school_pal/requests/get/view_chat_requests.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_chat_group_members.dart';
import 'package:school_pal/ui/create_chat_group.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/view_chat_message.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewChatCategory extends StatelessWidget {
  final String userChatType;
  final String userChatId;
  ViewChatCategory({this.userChatType, this.userChatId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(viewChatRepository: ViewChatRequest(), chatRepository: ChatRequests()),
      child: ViewChatCategoryPage(userChatType, userChatId),
    );
  }
}

// ignore: must_be_immutable
class ViewChatCategoryPage extends StatelessWidget {
  final String userChatType;
  final String userChatId;
  ViewChatCategoryPage(this.userChatType, this.userChatId);

  ChatBloc _chatBloc;
  List<Contact> _contacts;
  List<Group> _groups;
  List<Chat> _chats;
  String apiToken;
  int tabPosition=0;

  _initChatUi()async{
    apiToken=await getApiToken();
    //Local Database
    _chatBloc.add(ViewChatsEvent(apiToken, userChatId, true));
    _chatBloc.add(ViewChatContactsEvent(apiToken, userChatId, userChatType, true));
    _chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, true));
    //Api
    _chatBloc.add(ViewChatContactsEvent(apiToken, userChatId, userChatType, false));
    _chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, false));
    _chatBloc.add(ViewChatsEvent(apiToken, userChatId, false));
  }

  @override
  Widget build(BuildContext context) {
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _initChatUi();
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(chats: _chats, contacts: _contacts, groups: _groups, position: tabPosition, userChatId: userChatId, userType: userChatType, chatBloc: _chatBloc, apiToken: apiToken));
                })
          ],
          title: Text('Chats'),
          bottom: TabBar(
            onTap: (int position){
              tabPosition=position;
            },
            tabs: [
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            chatsUi(context),
            contactsUi(context),
            groupsUi(context),
          ],
        ),
      ),
    );
  }

  Widget chatsUi(BuildContext context){
    return Consumer<NotificationProvider>(
      builder: (BuildContext context, NotificationProvider notificationProvider, Widget child) {
        _onIncomingChatNotification(notificationProvider.notification);
        return BlocListener<ChatBloc, ChatStates>(listener:
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
            _contacts=state.chatContacts;
          } else if (state is ChatGroupsLoaded) {
            _groups=state.chatGroups;
          } else if (state is ChatsLoaded) {
            _chats=state.chats;
          } else if (state is GroupCreated) {
            Scaffold.of(context).removeCurrentSnackBar();
            _chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, false));
            _navigateToAddGroupMembersScreen(context: context, userId: userChatId, userType: userChatType, groupId: state.group.id, contacts: _contacts, group: state.group, chatBloc: _chatBloc, userChatId: userChatId, apiToken: apiToken);
          }
        },
          child:BlocBuilder<ChatBloc, ChatStates>(builder:
              (BuildContext context, ChatStates state) {
            if(state is ChatInitial){
              try{
                return _chats.isNotEmpty?_buildChatsScreen(context, _chats, userChatId):buildInitialScreen();
              }on NoSuchMethodError{
                return buildInitialScreen();
              }
            }else if (state is Loading) {
              try{
                return _chats.isNotEmpty?_buildChatsScreen(context, _chats, userChatId):buildLoadingScreen();
              }on NoSuchMethodError{
                return buildLoadingScreen();
              }

            } else if (state is ChatsLoaded) {
              return _buildChatsScreen(context, state.chats, userChatId);
            } else if (state is ViewError) {
              try{
                return _chats.isNotEmpty?_buildChatsScreen(context, _chats, userChatId):buildNODataScreen();
              }on NoSuchMethodError{
                return buildNODataScreen();
              }
            } else if (state is NetworkErr) {
              try{
                return _chats.isNotEmpty?_buildChatsScreen(context, _chats, userChatId):buildNetworkErrorScreen();
              }on NoSuchMethodError{
                return buildNetworkErrorScreen();
              }
            } else {
              try{
                return _chats.isNotEmpty?_buildChatsScreen(context, _chats, userChatId):buildInitialScreen();
              }on NoSuchMethodError{
                return buildInitialScreen();
              }
            }
          }),
        );
      },
    );
  }

  Widget contactsUi(BuildContext context){
    return BlocListener<ChatBloc, ChatStates>(listener:
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
            _contacts=state.chatContacts;
          } else if (state is ChatGroupsLoaded) {
            _groups=state.chatGroups;
          } else if (state is ChatsLoaded) {
            _chats=state.chats;
          } else if (state is GroupCreated) {
            Scaffold.of(context).removeCurrentSnackBar();
            _chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, false));
            _navigateToAddGroupMembersScreen(context: context, userId: userChatId, userType: userChatType, groupId: state.group.id, contacts: _contacts, group: state.group, chatBloc: _chatBloc, userChatId: userChatId, apiToken: apiToken);
          }
        },
      child:BlocBuilder<ChatBloc, ChatStates>(builder:
          (BuildContext context, ChatStates state) {
        if(state is ChatInitial){
          try{
            return _contacts.isNotEmpty?_buildContactsScreen(context, _contacts):buildInitialScreen();
          }on NoSuchMethodError{
            return buildInitialScreen();
          }
        }else if (state is Loading) {
          try{
            return _contacts.isNotEmpty?_buildContactsScreen(context, _contacts):buildLoadingScreen();
          }on NoSuchMethodError{
            return buildLoadingScreen();
          }

        } else if (state is ChatContactsLoaded) {
          return _buildContactsScreen(context, state.chatContacts);
        } else if (state is ViewError) {
          try{
            return _contacts.isNotEmpty?_buildContactsScreen(context, _contacts):buildNODataScreen();
          }on NoSuchMethodError{
            return buildNODataScreen();
          }
        } else if (state is NetworkErr) {
          try{
            return _contacts.isNotEmpty?_buildContactsScreen(context, _contacts):buildNetworkErrorScreen();
          }on NoSuchMethodError{
            return buildNetworkErrorScreen();
          }
        } else {
          try{
            return _contacts.isNotEmpty?_buildContactsScreen(context, _contacts):buildInitialScreen();
          }on NoSuchMethodError{
            return buildInitialScreen();
          }
        }
      }),
    );
  }

  Widget groupsUi(BuildContext context){
    return BlocListener<ChatBloc, ChatStates>(listener:
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
        _contacts=state.chatContacts;
      } else if (state is ChatGroupsLoaded) {
        _groups=state.chatGroups;
      } else if (state is ChatsLoaded) {
        _chats=state.chats;
      } else if (state is GroupCreated) {
        Scaffold.of(context).removeCurrentSnackBar();
        _chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, false));
        _navigateToAddGroupMembersScreen(context: context, userId: userChatId, userType: userChatType, groupId: state.group.id, contacts: _contacts, group: state.group, chatBloc: _chatBloc, userChatId: userChatId, apiToken: apiToken);
      }
    },
      child:Stack(
        children: [
          BlocBuilder<ChatBloc, ChatStates>(builder:
              (BuildContext context, ChatStates state) {
            if(state is ChatInitial){
              try{
                return _groups.isNotEmpty?_buildGroupsScreen(context, _groups):buildInitialScreen();
              }on NoSuchMethodError{
                return buildInitialScreen();
              }
            }else if (state is Loading) {
              try{
                return _groups.isNotEmpty?_buildGroupsScreen(context, _groups):buildLoadingScreen();
              }on NoSuchMethodError{
                return buildLoadingScreen();
              }
            } else if (state is ChatGroupsLoaded) {
              return _buildGroupsScreen(context, state.chatGroups);
            } else if (state is ViewError) {
              try{
                return _groups.isNotEmpty?_buildGroupsScreen(context, _groups):buildNODataScreen();
              }on NoSuchMethodError{
                return buildNODataScreen();
              }
            } else if (state is NetworkErr) {
              try{
                return _groups.isNotEmpty?_buildGroupsScreen(context, _groups):buildNetworkErrorScreen();
              }on NoSuchMethodError{
                return buildNetworkErrorScreen();
              }
            } else {
              try{
                return _groups.isNotEmpty?_buildGroupsScreen(context, _groups):buildInitialScreen();
              }on NoSuchMethodError{
                return buildInitialScreen();
              }
            }
          }),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: FloatingActionButton(
                heroTag: "Create Group",
                onPressed: () {
                  _showCreateGroupModalDialog(context: context, creatorId: userChatId, creatorType: userChatType);
                },
                child: Icon(Icons.add),
                backgroundColor: MyColors.primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget buildInitialScreen() {
    return Center(
      child: Container(),
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
        onTap: () => _initChatUi(),
      ),
    );
  }

  Widget _buildContactsScreen(BuildContext context, List<Contact> contacts) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildContactsRow(context, _chatBloc, contacts, index, userChatId, userChatType);
        });
  }

  Widget _buildGroupsScreen(BuildContext context, List<Group> groups) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: groups.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildGroupsRow(context, _chatBloc, groups, index, userChatId, userChatType, _contacts, apiToken);
        });
  }

  Widget _buildChatsScreen(BuildContext context, List<Chat> chats, String userChatId) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: chats.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildChatsRow(context, _chatBloc, chats, index, userChatId, userChatType, _contacts);
        });
  }

  void _showCreateGroupModalDialog({BuildContext context, String creatorId, String creatorType}) async {
    final data = await showDialog<List<String>>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: CreateChatGroup(),
          );
        });
    if (data != null) {
//TODO: Activate term here
      print(data.toString());
      _chatBloc.add(CreateGroupEvent(creatorId, creatorType, data[0], data[1]));
    }
  }

  static void _navigateToAddGroupMembersScreen({BuildContext context, ChatBloc chatBloc, String userId, String userType, String groupId, List<Contact> contacts, Group group, String apiToken, String userChatId}) async {

    final String result = await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddChatGroupMembers(userId: userId, userType: userType, groupId: groupId, contacts: contacts, group: group)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
      chatBloc.add(ViewChatGroupsEvent(apiToken, userChatId, false));
    }
  }

  static void showGroupOptionsModalBottomSheet({BuildContext context, ChatBloc chatBloc, Group group, String apiToken, String userChatId, String userType, List<Contact> contacts }) {
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
                    Icons.add_circle,
                    color: Colors.blue,
                  ),
                  title: new Text('Add Members'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddGroupMembersScreen(context: context, userId: userChatId, userType: userType, groupId: group.id, contacts: contacts, group: group, apiToken: apiToken, userChatId: userChatId, chatBloc: chatBloc);
                  },
                ),
              ],
            ),
          );
        });
  }

  static void _navigateToChatMessageScreen({BuildContext context, ChatBloc chatBloc, final String userChatId, String userType, String receiverId, String receiverType, String groupId, String chatType, Contact receiver, Group receivers, List<Contact> contacts}) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewChatMessage(userChatId: userChatId, userType: userType, receiverId: receiverId, receiverType: receiverType, groupId: groupId, chatType: chatType, receiver: receiver, receivers: receivers, contacts: contacts)),
      );

      // After the Selection Screen returns a result, hide any previous snackbars
      // and show the new result.
      if (result != null) {
        //Refresh after update
        chatBloc.add(ViewChatsEvent(await getApiToken(), userChatId, false));
      }
  }

  void _onIncomingChatNotification(Map<String, dynamic> message)async{
    print('New notification ${message.toString()}');
    try{
      Map<String, dynamic> notification=jsonDecode(message['data']['message']);
      if(notification['notification_type']=='chat_notification'){
        //Map chatDetails=notification['chat_details'];
        _chatBloc.add(ViewChatsEvent(await getApiToken(), userChatId, false));
      }
    }catch(e){
      print(e.toString());
    }
  }

}

Widget _buildContactsRow(BuildContext context, ChatBloc chatBloc, List<Contact> contacts, int index, String userChatId, String userType) {
  return (userChatId!=contacts[index].id)?Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: ListTile(
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
                      image: contacts[index].passportLink +
                          contacts[index].passport,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewImage(
                        imageUrl: [contacts[index].passportLink + contacts[index].passport,],
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
          ViewChatCategoryPage._navigateToChatMessageScreen(context: context, chatBloc:  chatBloc, userChatId: userChatId, userType: userType, receiverId: contacts[index].id, receiverType: contacts[index].userType, groupId: '0', chatType: 'private', receiver: contacts[index]);
        },
        onLongPress: (){

        },
      ),
    ),
  ):Container();
}

Widget _buildGroupsRow(BuildContext context, ChatBloc chatBloc, List<Group> groups, int index, String userChatId, String userType, List<Contact> contacts, String apiToken) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: ListTile(
        title: Row(
          children: <Widget>[
            GestureDetector(
              child: Hero(
                tag: "group passport tag $index",
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
                      image: groups[index].imageLink +
                          groups[index].image,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewImage(
                        imageUrl: [groups[index].imageLink + groups[index].image],
                        heroTag: "group passport tag $index",
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
                  Container(
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text(toSentenceCase('${groups[index].members.length} Member(s)'),
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
                    child: Text('${toSentenceCase(groups[index].name)}',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                    child: Text(toSentenceCase(groups[index].description),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                  ),
                  Divider(
                    color: Colors.black87,
                  )
                ],
              ),
            )
          ],
        ),
        onTap: () {
          ViewChatCategoryPage._navigateToChatMessageScreen(context: context, chatBloc: chatBloc, userChatId: userChatId, userType: userType, receiverId: groups[index].id, receiverType: 'group_members', groupId: groups[index].id, chatType: 'group', receivers: groups[index], contacts: contacts);
        },
        onLongPress: (){
          if(groups[index].creatorId==userChatId){
            ViewChatCategoryPage.showGroupOptionsModalBottomSheet(context: context, group: groups[index], userChatId: userChatId, userType: userType, contacts: contacts, apiToken: apiToken, chatBloc: chatBloc);
          }
        },
      ),
    ),
  );
}

Widget _buildChatsRow(BuildContext context, ChatBloc chatBloc, List<Chat> chats, int index, String userChatId, String userType, List<Contact> contacts) {
  // HH:mm:ss
  final formatDate = DateFormat("yyyy-MM-dd");
  //final formatDate = DateFormat("yyyy/MM/dd");
  final timeFormat = DateFormat("h:mm a");
  final dateFormat = DateFormat("EEE, MMM d, yyyy");
  DateTime todayDate = DateTime.now();
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: ListTile(
        title: Row(
          children: <Widget>[
            GestureDetector(
              child: Hero(
                tag: "receiver(s) passport tag $index",
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
                      image: (chats[index].message.chatType=='private')
                          ?(chats[index].sender.id==userChatId)
                          ? chats[index].receiver.passportLink+ chats[index].receiver.passport
                          :chats[index].sender.passportLink+ chats[index].sender.passport
                      :chats[index].receivers.imageLink+chats[index].receivers.image,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewImage(
                        imageUrl: (chats[index].message.chatType=='private')
                            ?(chats[index].sender.id==userChatId)
                            ? [chats[index].receiver.passportLink+ chats[index].receiver.passport]
                            :[chats[index].sender.passportLink+ chats[index].sender.passport]
                            :[chats[index].receivers.imageLink+chats[index].receivers.image],
                        heroTag: "receiver(s) passport tag $index",
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
                  Container(
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                      child: Text((formatDate.format(todayDate.toLocal())==chats[index].lastMessage.date.split(' ').first)
                          ?toSentenceCase(timeFormat.format(convertDateFromString(chats[index].lastMessage.date)))
                          :toSentenceCase(dateFormat.format(convertDateFromString(chats[index].lastMessage.date))),
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
                    child: Text((chats[index].message.chatType=='private')
                        ?(chats[index].sender.id==userChatId)
                        ? toSentenceCase(chats[index].receiver.userName)
                        :toSentenceCase(chats[index].sender.userName)
                        :toSentenceCase(chats[index].receivers.name),
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                          child: Text(toSentenceCase(chats[index].lastMessage.message),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ),
                      (double.parse(chats[index].readReceiptCount)>0)?CircleAvatar(
                        radius: 12,
                        backgroundColor: MyColors.primaryColor,
                        child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text((double.parse(chats[index].readReceiptCount)<100)
                                ?chats[index].readReceiptCount
                              :'99+', textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),)
                        ),
                      ):Container()
                    ],
                  ),
                  Divider(
                    color: Colors.black87,
                  )
                ],
              ),
            )
          ],
        ),
        onTap: () {
          if(chats[index].message.chatType=='private'){
            if(chats[index].sender.id==userChatId){
              ViewChatCategoryPage._navigateToChatMessageScreen(context: context, chatBloc: chatBloc, userChatId: userChatId, userType: userType, receiverId: chats[index].receiver.id, receiverType: chats[index].message.receiverType, groupId: '0', chatType: chats[index].message.chatType, receiver: chats[index].receiver);
            }else{
              ViewChatCategoryPage._navigateToChatMessageScreen(context: context, chatBloc: chatBloc, userChatId: userChatId, userType: userType, receiverId: chats[index].sender.id, receiverType: chats[index].message.senderType, groupId: '0', chatType: chats[index].message.chatType, receiver: chats[index].sender);
            }
          }else{
            ViewChatCategoryPage._navigateToChatMessageScreen(context: context, chatBloc: chatBloc, userChatId: userChatId,  userType: userType, receiverId: chats[index].receivers.id, receiverType: 'group_members', groupId: chats[index].receivers.id, chatType: chats[index].message.chatType, receivers: chats[index].receivers, contacts: contacts);
          }
        },
        onLongPress: (){

        },
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Contact> contacts;
  final List<Group> groups;
  final List<Chat> chats;
  final int position;
  final String userChatId;
  final String userType;
  final ChatBloc chatBloc;
  final String apiToken;
  CustomSearchDelegate({this.contacts, this.groups, this.chats, this.position, this.userChatId, this.userType, this.chatBloc, this.apiToken});

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
      final suggestionList = (position==0)?query.isEmpty
          ? chats
          : chats
          .where((p) => ((p.message.chatType=='private')
          ?(p.sender.id==userChatId)
          ? p.receiver.userName.contains(query)
          :p.sender.userName.contains(query)
          :p.receivers.name.contains(query))
          || (p.lastMessage.date.contains(query))
      ).toList()

          :(position==1)?query.isEmpty
          ? contacts
          : contacts
          .where((p) => (p.userName.contains(query))
          || (p.userType.contains(query))
          || (p.admissionNumber.contains(query))
          || (p.classDetails.contains(query))
      ).toList()

      :query.isEmpty
          ? groups
          : groups
          .where((p) => (p.name.contains(query))
          || (p.description.contains(query))
      ).toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            return (position==0) ?_buildChatsRow(context, chatBloc, suggestionList, index, userChatId, userType, contacts)
            :(position==1)?_buildContactsRow(context, chatBloc, suggestionList, index, userChatId, userType)
            :_buildGroupsRow(context, chatBloc, suggestionList, index, userChatId, userType, contacts, apiToken);
          });
    } catch(e) {
      print(e.toString());
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
      final suggestionList = (position==0)?query.isEmpty
          ? chats
          : chats
          .where((p) => ((p.message.chatType=='private')
          ?(p.sender.id==userChatId)
          ? p.receiver.userName.contains(query)
          :p.sender.userName.contains(query)
          :p.receivers.name.contains(query))
          || (p.lastMessage.date.contains(query))
      ).toList()

          :(position==1)?query.isEmpty
          ? contacts
          : contacts
          .where((p) => (p.userName.contains(query))
          || (p.userType.contains(query))
          || (p.admissionNumber.contains(query))
          || (p.classDetails.contains(query))
      ).toList()

          :query.isEmpty
          ? groups
          : groups
          .where((p) => (p.name.contains(query))
          || (p.description.contains(query))
      ).toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            return (position==0) ?_buildChatsRow(context, chatBloc, suggestionList, index, userChatId, userType, contacts)
                :(position==1)?_buildContactsRow(context, chatBloc, suggestionList, index, userChatId, userType)
                :_buildGroupsRow(context, chatBloc, suggestionList, index, userChatId, userType, contacts, apiToken);
          });
    } catch(e) {
      print(e.toString());
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }
}
