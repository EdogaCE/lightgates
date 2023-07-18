import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/chat/chat.dart';
import 'package:school_pal/models/contact.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/ui/view_image.dart';
import 'package:school_pal/utils/system.dart';

class ViewChatContactDetails extends StatelessWidget {
  final Contact contact;
  ViewChatContactDetails({this.contact});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: ViewChatContactDetailsPage(contact),
    );
  }
}

class ViewChatContactDetailsPage extends StatelessWidget {
  final Contact contact;
  ViewChatContactDetailsPage(this.contact);
  @override
  Widget build(BuildContext context) {
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
                title: Text(toSentenceCase(contact.userName)),
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
                                imageUrl: [contact.passportLink + contact.passport],
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
                        image: contact.passportLink + contact.passport,
                      ),
                    ),
                  ),
                )),
          ),
      BlocListener<ChatBloc, ChatStates>(
        listener: (context, state) {

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
                              child: Text(toSentenceCase(contact.emailAddress),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal)),
                            ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 5.0, bottom: 2.0),
                                child: Text(toSentenceCase(contact.phone),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.normal)),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 5.0, bottom: 8.0),
                              child: Text(toSentenceCase(contact.status),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: (contact.status=='active')?Colors.teal:Colors.orange,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Account:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Text('${toSentenceCase(contact.userType)} Account',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ),
                                (contact.userType=='student')?Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Reg:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Text(toSentenceCase(contact.admissionNumber),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ):Container(),
                                (contact.userType=='student')?Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Text(("Class:  "),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MyColors.primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Text(toSentenceCase(contact.classDetails),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ):Container(),
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
}
