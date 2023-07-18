import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/blocs/profile/profile.dart';
import 'package:school_pal/models/developer.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/launch_request.dart';
import 'package:school_pal/utils/system.dart';
import 'modals.dart';

class DeveloperContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(viewProfileRepository: ViewProfileRequest()),
      child: DeveloperContactPage(),
    );
  }
}

// ignore: must_be_immutable
class DeveloperContactPage extends StatelessWidget {
  ProfileBloc _profileBloc;
  Developer developer;
  void _viewProfile() async {
    _profileBloc.add(ViewDeveloperProfileEvent(await getApiToken()));
  }
  @override
  Widget build(BuildContext context) {
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    _viewProfile();

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
                title: Text(
                    'Contact Developer'),
                titlePadding: const EdgeInsets.all(15.0),
                background: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Center(
                      child: SvgPicture.asset("lib/assets/images/contact_developer.svg")
                  ),
                )),
          ),
          BlocListener<ProfileBloc, ProfileStates>(
            listener: (context, state) {
              //Todo: note listener returns void
              if (state is NetworkErr) {
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
              }else if (state is DeveloperProfileLoaded){
                developer=state.developer;
              }
            },
            child: BlocBuilder<ProfileBloc, ProfileStates>(
              builder: (context, state) {
                //Todo: note builder returns widget
                if(state is ProfileInitial){
                  return buildInitialScreen();
                }else if (state is ProfileLoading) {
                  try{
                    return _buildDeveloperProfileDisplayScreen(context: context, developer: developer);
                  }on NoSuchMethodError{
                    return buildLoadingScreen();
                  }
                }else if (state is NetworkErr) {
                  try{
                    return _buildDeveloperProfileDisplayScreen(context: context, developer: developer);
                  }on NoSuchMethodError{
                    return buildNetworkErrorScreen();
                  }
                }else if (state is ViewError) {
                  try{
                    return _buildDeveloperProfileDisplayScreen(context: context, developer: developer);
                  }on NoSuchMethodError{
                    return buildNODataScreen();
                  }
                }else if (state is DeveloperProfileLoaded) {
                  return _buildDeveloperProfileDisplayScreen(context: context, developer: state.developer);
                }else{
                  try{
                    return _buildDeveloperProfileDisplayScreen(context: context, developer: developer);
                  }on NoSuchMethodError{
                    return buildInitialScreen();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInitialScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Scaffold(),
          ),
        ));
  }

  Widget buildLoadingScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
                      backgroundColor: Colors.pink,
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget buildNODataScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              MyStrings.noData,
              height: 150.0,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
  }

  Widget buildNetworkErrorScreen() {
    return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: SvgPicture.asset(
                MyStrings.networkError,
                height: 150.0,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
              ),
              onTap: () => _viewProfile(),
            ),
          ),
        ));
  }

  _buildDeveloperProfileDisplayScreen({BuildContext context, Developer developer}) {
    return SliverList(
        delegate: SliverChildListDelegate(
          [
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
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.email,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        Text("Email",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Text(developer.emailAddress1.isNotEmpty?toSentenceCase(developer.emailAddress1):'Unknown',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ),
                        Divider(
                          color: Colors.black54,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Text(developer.emailAddress2.isNotEmpty?toSentenceCase(developer.emailAddress2):'Unknown',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
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
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.phone,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        Text("Phone",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                            child: Text(developer.phone1.isNotEmpty?toSentenceCase(developer.phone1):'Unknown',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal)),
                          ),
                          onTap: (){
                            if(developer.phone1.isNotEmpty)
                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number: developer.phone1);
                          },
                          onLongPress: (){
                            if(developer.phone1.isNotEmpty)
                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number: developer.phone1);
                          },
                        ),
                        (developer.phone2.isNotEmpty)?Divider(
                          color: Colors.black54,
                        ):Container(),
                        (developer.phone2.isNotEmpty)?GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                            child: Text(developer.phone2.isNotEmpty?toSentenceCase(developer.phone2):'Unknown',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal)),
                          ),
                          onTap: (){
                            if(developer.phone2.isNotEmpty)
                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number: developer.phone2);
                          },
                          onLongPress: (){
                            if(developer.phone2.isNotEmpty)
                              showCallWhatsappMessageModalBottomSheet(context: context, countryCode: '+234', number: developer.phone2);
                          },
                        ):Container(),
                      ],
                    ),
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
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.location_on,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        Text("Address",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Text(developer.address1.isNotEmpty?toSentenceCase(developer.address1):'Unknown',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ),
                        (developer.address2.isNotEmpty)?Divider(
                          color: Colors.black54,
                        ):Container(),
                        (developer.address2.isNotEmpty)?Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Text(developer.address2.isNotEmpty?toSentenceCase(developer.address2):'Unknown',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal)),
                        ):Container(),
                      ],
                    ),
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
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.chat,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        Text("Social media",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text('Facebook:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(developer.facebook.isNotEmpty?toSentenceCase(developer.facebook):'Unknown',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.fade,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ),
                                  onTap: (){
                                    LaunchRequest().launchURL(developer.facebook);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black54,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text('Instagram:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(developer.instagram.isNotEmpty?toSentenceCase(developer.instagram):'Unknown',
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ),
                                  onTap: (){
                                    LaunchRequest().launchURL(developer.instagram);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black54,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, bottom: 8.0, left: 40.0, right: 2.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text('Twitter:',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(developer.twitter.isNotEmpty?toSentenceCase(developer.twitter):'Unknown',
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal)),
                                  ),
                                  onTap: (){
                                    LaunchRequest().launchURL(developer.twitter);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
