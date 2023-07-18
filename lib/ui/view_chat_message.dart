import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/models/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/models/group.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:school_pal/providers/notification_provider.dart';
import 'package:school_pal/requests/get/view_chat_requests.dart';
import 'package:school_pal/requests/posts/chat_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_chat_group_members.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/ui/view_chat_contact_details.dart';
import 'package:school_pal/ui/view_chat_group_details.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/image_picker.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class ViewChatMessage extends StatelessWidget {
  final String userChatId;
  final String userType;
  final String receiverId;
  final String receiverType;
  final String groupId;
  final String chatType;
  final Contact receiver;
  final Group receivers;
  final List<Contact> contacts;
  ViewChatMessage({this.userChatId, this.userType, this.receiverId, this.receiverType, this.groupId, this.chatType, this.receiver, this.receivers, this.contacts});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(viewChatRepository: ViewChatRequest(), chatRepository: ChatRequests()),
      child: ViewChatMessagePage(userChatId, userType, receiverId, receiverType, groupId, chatType, receiver, receivers, contacts),
    );
  }
}

// ignore: must_be_immutable
class ViewChatMessagePage extends StatelessWidget {
  final String userChatId;
  final String userType;
  final String receiverId;
  final String receiverType;
  final String groupId;
  final String chatType;
  final Contact receiver;
  final Group receivers;
  final List<Contact> contacts;
  ViewChatMessagePage(this.userChatId, this.userType, this.receiverId, this.receiverType, this.groupId, this.chatType, this.receiver, this.receivers, this.contacts);

  ChatBloc _chatBloc;
  List<Chat> _chats;
  bool showEmoji=false;
  bool _loaded=false;
  List<Asset> selectedImages = List<Asset>();

  final messageController = TextEditingController();
  final messageFocusNode =FocusNode();

  ScrollController scrollController=ScrollController();
  List<String> dropButtonList=['Search'];

  _viewChatMessages()async{
    String apiToken=await getApiToken();
    _chatBloc.add(ViewChatMessagesEvent(apiToken, userChatId, userType, receiverId, receiverType, groupId, chatType, false));
    //_chatBloc.add(UpdateChatReadMessagesEvent(apiToken, userChatId, _chats.first.message.mainMessageId, chatType));
  }

  void _loadMultipleImages() async {
    _chatBloc.add(LoadImagesEvent(await loadAssets(selectedImages)));
  }

  @override
  Widget build(BuildContext context) {
    _chatBloc = BlocProvider.of<ChatBloc>(context);

    getApiToken().then((value){
      if(value!=null){
        _chatBloc.add(ViewChatMessagesEvent(value, userChatId, userType, receiverId, receiverType, groupId, chatType, true));
      }
    });

    messageFocusNode.addListener(() {
      if(messageFocusNode.hasFocus){
        _chatBloc.add(RenderEmojiEvent(false));
      }
    });

    if((chatType=='group')&&(receivers.creatorId==userChatId)){
      dropButtonList.add('Add Members');
    }
    _viewChatMessages();
    return Consumer<NotificationProvider>(
      builder: (BuildContext context, NotificationProvider notificationProvider, Widget child) {
        _onIncomingChatNotification(notificationProvider, notificationProvider.notification);
        return WillPopScope(
          onWillPop: () =>_popNavigator(context),
          child: Scaffold(
              appBar: AppBar(
                  actions: <Widget>[
                    DropdownButton<String>(
                      icon: Icon( Icons.more_vert, color: Colors.white,),
                      items: dropButtonList.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        switch(value){
                          case 'Search':{
                            showSearch(
                                context: context,
                                delegate: CustomSearchDelegate(chats: _chats, contacts: contacts, userChatId: userChatId));
                            break;
                          }
                          case 'Add Members':{
                            _navigateToAddGroupMembersScreen(context: context, userId: userChatId, userType: userType, groupId: groupId, contacts: contacts, group: receivers);
                            break;
                          }
                        }
                      },
                    )
                  ],
                  title: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: "contact passport tag",
                          transitionOnUserGestures: true,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: FadeInImage.assetNetwork(
                                placeholderScale: 5,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(seconds: 1),
                                fadeInCurve: Curves.easeInCirc,
                                placeholder: 'lib/assets/images/avatar.png',
                                image: (chatType=='group')?receivers.imageLink+receivers.image
                                    :receiver.passportLink + receiver.passport,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0, bottom: 2.0, left: 12.0, right: 2.0),
                                child: Text((chatType=='group')?toSentenceCase(receivers.name):toSentenceCase(receiver.userName),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    onTap: (){
                      if(chatType=='group'){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewChatGroupDetails(group: receivers)),
                        );
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewChatContactDetails(contact: receiver)),
                        );
                      }
                    },
                  )
              ),
              body: CustomPaint(
                painter: BackgroundPainter(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: BlocListener<ChatBloc, ChatStates>(
                        listener: (BuildContext context, ChatStates state) {
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
                          }else if (state is Processing) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(minutes: 30),
                                content: General.progressIndicator("Processing..."),
                              ),
                            );
                          }else if (state is ChatsLoaded) {
                            _loaded=_chats!=state.chats;
                            _chats=state.chats;
                            notificationProvider.chats=state.chats;
                            try{
                              messageController.clear();
                              selectedImages.clear();
                              Scaffold.of(context).removeCurrentSnackBar();
                              scrollController.animateTo(state.chats.length.roundToDouble(), duration: Duration(milliseconds: 500), curve: Curves.ease);
                            }catch(e){
                              print(e);
                            }
                          }else if (state is EmojiRendered) {
                            showEmoji=state.show;
                            if(state.show){
                              FocusScope.of(context).requestFocus(FocusNode());
                            }else{
                              FocusScope.of(context).requestFocus(messageFocusNode);
                            }
                          }else if (state is ImagesLoaded) {
                            if (state.images.isNotEmpty)
                              selectedImages = state.images;
                          }else if (state is ChatReadMessagesUpdated) {
                            print(state.message);
                          }
                        },
                        child: BlocBuilder<ChatBloc, ChatStates>(
                          builder: (BuildContext context, ChatStates state) {
                            if(state is ChatInitial){
                              try{
                                return _chats.isNotEmpty?_buildLoadedScreen(context, _chats):buildInitialScreen();
                              }on NoSuchMethodError{
                                return buildInitialScreen();
                              }
                            }else if (state is Loading) {
                              try{
                                return  _chats.isNotEmpty?_buildLoadedScreen(context, _chats):buildLoadingScreen();
                              }on NoSuchMethodError{
                                return buildLoadingScreen();
                              }
                            } else if (state is ChatsLoaded) {
                              return _buildLoadedScreen(context, state.chats);
                            } else if (state is ViewError) {
                              try{
                                return _chats.isNotEmpty?_buildLoadedScreen(context, _chats):buildNODataScreen();
                              }on NoSuchMethodError{
                                return buildNODataScreen();
                              }
                            } else if (state is NetworkErr) {
                              try{
                                return _chats.isNotEmpty?_buildLoadedScreen(context, _chats):buildNetworkErrorScreen();
                              }on NoSuchMethodError{
                                return buildNetworkErrorScreen();
                              }
                            } else {
                              try{
                                return  _chats.isNotEmpty?_buildLoadedScreen(context, _chats):buildInitialScreen();
                              }on NoSuchMethodError{
                                return buildInitialScreen();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    BlocBuilder<ChatBloc, ChatStates>(
                      builder: (BuildContext context,
                          ChatStates state) {
                        return selectedImages.isNotEmpty?Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                    color: MyColors.primaryColor,
                                    style: BorderStyle.solid,
                                    width: 0.80),
                              ),
                              height: 100.0,
                              child: GestureDetector(
                                onTap: () {
                                  _loadMultipleImages();
                                },
                                child: Stack(
                                  children: <Widget>[
                                    selectedImages.isEmpty
                                        ? Center(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .all(8.0),
                                        child: Row(
                                          mainAxisSize:
                                          MainAxisSize
                                              .min,
                                          children: <Widget>[
                                            Icon(
                                                Icons
                                                    .add_photo_alternate,
                                                color: Colors
                                                    .black
                                                    .withOpacity(
                                                    0.3)),
                                            Text("Images",
                                                style: TextStyle(
                                                    fontSize:
                                                    20,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Colors
                                                        .black
                                                        .withOpacity(
                                                        0.3))),
                                          ],
                                        ),
                                      ),
                                    )
                                        : Container(),
                                    GridView.count(
                                      crossAxisCount: 3,
                                      children: List.generate(
                                          selectedImages.length,
                                              (index) {
                                            Asset asset =
                                            selectedImages[index];
                                            return AssetThumb(
                                              asset: asset,
                                              width: 300,
                                              height: 300,
                                            );
                                          }),
                                    ),
                                    (selectedImages.length > 3)
                                        ? Align(
                                      alignment: Alignment
                                          .bottomRight,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              25.0),
                                          child: Container(
                                            color: Colors
                                                .white
                                                .withOpacity(
                                                0.5),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(
                                                  8.0),
                                              child: Text(
                                                  '+${selectedImages.length - 3}',
                                                  style: TextStyle(
                                                      fontSize:
                                                      20,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .deepPurple)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : Container()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ):Container();
                      },
                    ),
                    BlocBuilder<ChatBloc, ChatStates>(
                      builder: (BuildContext context, ChatStates state) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: TextFormField(
                                      controller: messageController,
                                      focusNode: messageFocusNode,
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
                                          prefixIcon: IconButton(
                                              onPressed: () {
                                                _chatBloc.add(RenderEmojiEvent(!showEmoji));
                                              },
                                              icon: Icon(showEmoji?Icons.keyboard:Icons.mood, color: Colors.blueGrey)
                                          ),
                                          /*suffixIcon: IconButton(
                                      onPressed: () {
                                        _loadMultipleImages();
                                      },
                                      icon: Icon(Icons.image, color: Colors.blueGrey)
                                  ),*/
                                          labelText: 'Message',
                                          labelStyle:
                                          new TextStyle(color: Colors.grey[800]),
                                          filled: true,
                                          fillColor: Colors.white70)
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: FloatingActionButton(
                                  heroTag: "Send comment",
                                  onPressed: () {
                                    if (messageController.text.isNotEmpty) {
                                      _chatBloc.add(SendChatMessageEvent(messageController.text, userChatId, userType, receiverId, receiverType, groupId, chatType));
                                    }
                                  },
                                  child: Icon(Icons.send),
                                  backgroundColor: MyColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    BlocBuilder<ChatBloc, ChatStates>(
                      builder: (BuildContext context, ChatStates state) {
                        return showEmoji?EmojiPicker(
                          rows: 3,
                          columns: 7,
                          buttonMode: ButtonMode.MATERIAL,
                          recommendKeywords: ["racing", "horse"],
                          numRecommended: 10,
                          bgColor: Colors.white54,
                          onEmojiSelected: (emoji, category) {
                            print(emoji);
                            messageController.text='${messageController.text}${emoji.emoji}';
                          },
                        ):Container();
                      },
                    ),
                  ],
                ),
              )
          ),
        );
      },
    );
  }

  Widget buildInitialScreen() {
    return Center(
      child: Container(),
    );
  }

  Widget buildLoadingScreen() {
    return Container(
      child: Center(
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
      ),
    );
  }

  Widget buildNODataScreen() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text('No active chat yet',
          style: TextStyle(fontWeight: FontWeight.bold,
              color: Colors.black45,
              fontSize: 15),),
      )
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
        onTap: () => _viewChatMessages(),
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context, List<Chat> chats) {
    return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: chats.length,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        controller: scrollController,
        reverse: true,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(context, chats, index, contacts, userChatId);
        });
  }

  _navigateToAddGroupMembersScreen({BuildContext context, String userId, String userType, String groupId, List<Contact> contacts, Group group}) async {

    final String result = await  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddChatGroupMembers(userId: userId, userType: userType, groupId: groupId, contacts: contacts, group: group)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
    }
  }

  void _onIncomingChatNotification(NotificationProvider notificationProvider, Map<String, dynamic> message){
    print('New notification ${message.toString()}');
    if(message.isNotEmpty){
      _chats=notificationProvider.chats;
    }
    try{
      Map<String, dynamic> notification=jsonDecode(message['data']['message']);
      if(notification['notification_type']=='chat_notification'){
        Map chatDetails=notification['chat_details'];
        _viewChatMessages();
      }
    }catch(e){
      print(e.toString());
    }
    message.clear();
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_loaded) {
      print("onwill goback");
      Navigator.pop(context, 'new messages');
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}

Widget _buildRow(
    BuildContext context, List<Chat> chats, int index, List<Contact> contacts, String userChatId) {
  return ListTile(
      title: (userChatId == chats[index].message.senderId)
          ? Row(
        children: <Widget>[
          Expanded(child: Container()),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                  color: Colors.green.withOpacity(0.3),
                  padding: const EdgeInsets.all(15.0),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                              toSentenceCase(chats[index].message.message),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.check_circle,
                              size: 15,
                              color:
                              MyColors.primaryColor.withOpacity(1)))
                    ],
                  )),
            ),
          ),
        ],
      )
          : Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                  color: MyColors.primaryColor.withOpacity(0.3),
                  padding: (chats[index].message.chatType=='group')?const EdgeInsets.all(0.0):const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      (chats[index].message.chatType=='group')?GestureDetector(
                        child: Hero(
                          tag: "contact passport tag $index",
                          transitionOnUserGestures: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: FadeInImage.assetNetwork(
                                placeholderScale: 5,
                                height: 35,
                                width: 35,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(seconds: 1),
                                fadeInCurve: Curves.easeInCirc,
                                placeholder: 'lib/assets/images/avatar.png',
                                image: contacts.where((element) => element.id==chats[index].message.senderId).toList().first.passportLink + contacts.where((element) => element.id==chats[index].message.senderId).toList().first.passport,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImage(
                                  imageUrl: [contacts.where((element) => element.id==chats[index].message.senderId).toList().first.passportLink + contacts.where((element) => element.id==chats[index].message.senderId).toList().first.passport],
                                  heroTag: "contact passport tag $index",
                                  placeholder: 'lib/assets/images/avatar.png',
                                  position: 0,
                                ),
                              ));
                        },
                      ):Container(),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(toSentenceCase(chats[index].message.message),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal)),
                          )
                      ),
                    ],
                  )),
            ),
          ),
          Expanded(child: Container())
        ],
      ),
      onTap: () {});
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Chat> chats;
  final List<Contact> contacts;
  final String userChatId;
  CustomSearchDelegate({this.chats, this.contacts, this.userChatId});

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
          ? chats
          : chats
          .where((p) =>
      (p.message.message.contains(query)))
          .toList();

      return  CustomPaint(
          painter: BackgroundPainter(),
        child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: suggestionList.length,
            itemBuilder: (BuildContext context, int index) {
              //if (index.isOdd) return Divider();
              return _buildRow(context, suggestionList, index, contacts, userChatId);
            }),
      );
    } on NoSuchMethodError {
      return  CustomPaint(
        painter: BackgroundPainter(),
        child: Center(
          child: Text(
            MyStrings.searchErrorMessage,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    try {
      final suggestionList = query.isEmpty
          ? chats
          : chats
          .where((p) =>
      (p.message.message.contains(query)))
          .toList();

      return  CustomPaint(
          painter: BackgroundPainter(),
        child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: suggestionList.length,
            itemBuilder: (BuildContext context, int index) {
              //if (index.isOdd) return Divider();
              return _buildRow(context, suggestionList, index, contacts, userChatId);
            }),
      );
    } on NoSuchMethodError {
      return  CustomPaint(
        painter: BackgroundPainter(),
        child: Center(
          child: Text(
            MyStrings.searchErrorMessage,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    }
  }
}
