import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:school_pal/blocs/navigatoins/navigation.dart';
import 'package:school_pal/models/user.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/animations/animations.dart';
import 'package:school_pal/ui/dashboard.dart';
import 'package:school_pal/ui/modals.dart';
import 'package:school_pal/ui/register.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Show status bar
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AnimationBloc(),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
      ],
      child: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  bool pageOneSelected= false;
  bool pageTwoSelected= false;
  bool pageThreeSelected= false;
  bool pageFourSelected= false;
  bool pageFiveSelected= false;
  bool pageSixSelected= false;
  bool pageSevenSelected= false;
  AnimationBloc animationBloc;
  // ignore: close_sinks
  NavigationBloc navigationBloc;
  PageController _controller = PageController(
      initialPage: 0,
      viewportFraction: 1.0
  );

  _checkLoggedIn(BuildContext context) async {
    String loginAs=await getLoggedInAs();
    User user=await retrieveLoginDetailsFromSF();
   if(await isLoggedIn()){
     Navigator.pushAndRemoveUntil(
       context,
       MaterialPageRoute(builder: (context) => Dashboard(loggedInAs: loginAs, user: user)),
       ModalRoute.withName('/'),
     );
   }
  }


  @override
  Widget build(BuildContext context) {
    // Starting animation
    _checkLoggedIn(context);
    animationBloc = BlocProvider.of<AnimationBloc>(context);
    animationBloc.add(StartHomeAnimation(true, 0));
    navigationBloc = BlocProvider.of<NavigationBloc>(context);
    Timer.periodic(Duration(seconds: 5), (timer) {
      try{
        navigationBloc.add(ChangeHomeViewPagerPositionEvent((_controller.page.round() + 1) % 7));
        //navigationBloc.add(ChangeHomeViewPagerPositionEvent((_controller.page.round() + 1)));
      }catch(e){}
    });
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Stack(
            children: [
              Container(
                color: Colors.white,
                /*decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/home_screen_background.jpg"),
                    fit: BoxFit.cover
                  )
                ),*/
                child: BlocListener<NavigationBloc, NavigationStates>(
                  listener: (context, state) {
                    if(state is HomeViewPagerPositionChanged){
                      (state.position==7)
                        ?_controller.jumpToPage(state.position)
                      :_controller.animateToPage(state.position, duration: Duration(milliseconds: 500), curve: Curves.ease);
                    }
                    //Todo: note listener returns void
                  },
                  child: BlocBuilder<NavigationBloc, NavigationStates>(
                    builder: (context, state) {
                      //Todo: note builder returns widget
                      return PageIndicatorContainer(
                        child: _pageView(),
                        align: IndicatorAlign.bottom,
                        length: 7,
                        indicatorSpace: 10.0,
                        padding: const EdgeInsets.all(10),
                        indicatorColor: Colors.black26,
                        indicatorSelectorColor: MyColors.primaryColor,
                        shape: IndicatorShape.circle(size: 8)
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    MyStrings.logoPath,
                    scale: 15,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Wrap(
              children: <Widget>[
                Column(children: <Widget>[
                  const SizedBox(height: 100),
                  loginButtonBorder(context),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: registerButtonFill(context)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35.0, top: 8.0, left: 8.0, right: 8.0),
                    child: FloatingActionButton(
                      heroTag: "Next page",
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(100.0),
                          //side: BorderSide(color: MyColors.primaryColor)
                      ),
                      splashColor: MyColors.primaryColor,
                      onPressed: () {
                        navigationBloc.add(ChangeHomeViewPagerPositionEvent((_controller.page.round() + 1) % 7));
                      },
                      child: Icon(Icons.arrow_forward_ios, color: MyColors.primaryColor,),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageView(){
    return PageView(
      controller: _controller,
      children: <Widget>[
        firstPage(),
        secondPage(),
        thirdPage(),
        fourthPage(),
        fifthPage(),
        sixthPage(),
        seventhPage()
      ],
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      physics: PageScrollPhysics(),
      onPageChanged: _onPageViewChange,
      // physics: BouncingScrollPhysics(),
    );

  }

 //Todo: still in progress but might replace pageview
 /* Widget _liquidSwipe(){
    return LiquidSwipe(
        pages: [
          firstPage(),
          secondPage(),
          thirdPage()
        ],
      enableSlideIcon: true,
      onPageChangeCallback: _onPageViewChange,
    );
  }*/

  _onPageViewChange(int page) {
    animationBloc.add(StartHomeAnimation(true, page));
  }

  Widget firstPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child: BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/contact_developer.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Share ', style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: 'and', style: TextStyle(color: MyColors.primaryColor, fontSize: 18)),
                                TextSpan(text: ' reference', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                                TextSpan(text: ' photos, videos and documents', style: TextStyle(color: MyColors.primaryColor, fontSize: 18)),
                                TextSpan(text: ' easily', style: TextStyle(color:Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageOneSelected),
                      //color: MyColors.pageOneColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration:_decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget secondPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child: BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/learning3.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Learning Made', style: TextStyle(color: MyColors.primaryColor, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: ' Easy', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageTwoSelected),
                      //color: MyColors.pageTwoColor,
                    ),
                    /*/Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget thirdPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child: BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/assessment1.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Administer ',  style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: '& collate tests, homework & project results', style: TextStyle(color: MyColors.primaryColor, fontSize: 18)),
                                TextSpan(text: ' faster', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageThreeSelected),
                      //color:  MyColors.pageThreeColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget fourthPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child:BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/invoice.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Issue invoices and process payments ',  style: TextStyle(color: MyColors.primaryColor, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: 'conveniently', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageFourSelected),
                      //color:  MyColors.pageThreeColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget fifthPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child: BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/schedule3.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Track ',  style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: 'pupils & students', style: TextStyle(color: MyColors.primaryColor, fontSize: 18)),
                                TextSpan(text: ' performance periodically', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageFiveSelected),
                     // color:  MyColors.pageThreeColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget sixthPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child:BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/bus_tracker.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Track ',  style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: 'School bus from anywhere in', style: TextStyle(color: MyColors.primaryColor, fontSize: 18)),
                                TextSpan(text: ' real-time', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageSixSelected),
                     // color: MyColors.pageThreeColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget seventhPage(){
    return BlocListener<AnimationBloc, AnimationState>(
        listener: (context, state) {
          if(state is AnimationStart){
            switch(state.page){
              case 0:{
                pageOneSelected=state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 1:{
                pageOneSelected=!state.start;
                pageTwoSelected=state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 2:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 3:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 4:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=state.start;
                pageSixSelected= !state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 5:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=state.start;
                pageSevenSelected=!state.start;
                break;
              }
              case 6:{
                pageOneSelected=!state.start;
                pageTwoSelected=!state.start;
                pageThreeSelected=!state.start;
                pageFourSelected=!state.start;
                pageFiveSelected=!state.start;
                pageSixSelected=!state.start;
                pageSevenSelected=state.start;
                break;
              }
            }

          }
        },
        child:BlocBuilder<AnimationBloc, AnimationState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      child: logoAndWriteUps(
                          'lib/assets/images/data_storage.svg',
                          RichText(
                            text: TextSpan(
                              text: 'Store and access school data from ',  style: TextStyle(color: MyColors.primaryColor, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: ' anywhere, anytime!', style: TextStyle(color: Colors.deepOrange, fontSize: 18)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          pageSevenSelected),
                      //color: MyColors.pageThreeColor,
                    ),
                    /*Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            decoration: _decoration(),
          )*/
                  ],
                ),
              );
            })
    );
  }

  Widget logoAndWriteUps(String imagePath, RichText richText, bool animatePage){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            width: animatePage ? 200.0 : 100.0,
            height: animatePage ? 200.0 : 100.0,
          //  color: pageSelected ? Colors.red : Colors.blue,
            alignment: animatePage ? Alignment.center : AlignmentDirectional.topCenter,
            duration: Duration(seconds: 2),
            curve: Curves.fastOutSlowIn,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                imagePath,
                fit: BoxFit.fitWidth,
                colorBlendMode: BlendMode.darken,
                alignment: Alignment.center,
              )/*Image.asset(
                imagePath,
                scale: 2,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
              )*/,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              MyStrings.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  fontSize: 35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: richText,
          ),
          const SizedBox(height: 250),
        ],
      ),
    );
  }

  Decoration _decoration(){
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.black.withAlpha(0),
          Colors.black12,
          Colors.black45
        ],
      ),
    );
  }

  Widget loginButtonBorder(BuildContext context){
    return RaisedButton(
      onPressed: () {
        loginAsModalBottomSheet(context);
        //Todo: Navigator.pop(context); to move back to previous page kinda finish asin android
      },
      textColor: Colors.white,
      color: MyColors.primaryColor, //MyColors.transparent,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.white)
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 100.0, top: 2.0, right: 100.0, bottom: 2.0),
        child: const Text(
            "Login",
            style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }

  Widget registerButtonFill(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Register(continueRegistration: false,))
        );
      },
      textColor: Colors.white,
      color: MyColors.transparent,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 2.0, right: 20.0, bottom: 2.0),
        child: Text(
            "New School?  Register",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, color: MyColors.primaryColor/*, decoration: TextDecoration.underline*/)
        ),
      ),
    );
  }
}
