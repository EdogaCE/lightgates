import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/tickets/tickets.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:animator/animator.dart';
import 'package:school_pal/requests/get/view_tickets_with_comments.dart';
import 'package:school_pal/requests/posts/create_ticket_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/ui/general.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/ui/modals.dart';

class CreateTicket extends StatelessWidget {
  CreateTicket({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketsBloc(viewTicketsRepository: ViewTicketsRequest(), createTicketRepository: CreateTicketRequests()),
      child: CreateTicketPage(),
    );
  }
}

// ignore: must_be_immutable
class CreateTicketPage extends StatelessWidget {
  TicketsBloc ticketsBloc;
  String categoryDropdownValue = '---category---';
  List<String> categorySpinnerItems = ["---category---"];
  List<String> categorySpinnerIds=['0'];
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _viewTicketCategories() async {
    ticketsBloc.add(ViewTicketCategoriesEvent(await getApiToken()));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ticketsBloc = BlocProvider.of<TicketsBloc>(context);
    _viewTicketCategories();
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          //Todo: to change back button color
          iconTheme: IconThemeData(color: MyColors.primaryColor),
          title: Text("Ticket", style: TextStyle(color: MyColors.primaryColor)),
        ),
        body: CustomPaint(
          painter: BackgroundPainter(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[
                Animator(
                  repeats: 1,
                  duration: Duration(seconds: 2),
                  builder: (context, anim, child) => Opacity(
                    opacity: anim.value,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child:
                        SvgPicture.asset("lib/assets/images/contact.svg",
                          alignment: Alignment.topCenter,)
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: titleController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter event title.';
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
                                      labelText: 'Title',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              BlocListener<TicketsBloc, TicketsStates>(
                                listener: (BuildContext context, TicketsStates state) {
                                  if(state is SpinnerDataSelected){
                                    categoryDropdownValue=state.selectedData;
                                  }else if (state is TicketCategoriesLoaded){
                                    categorySpinnerItems.addAll(state.categories[0]);
                                    categorySpinnerIds.addAll(state.categories[1]);
                                  }
                                },
                                child: BlocBuilder<TicketsBloc, TicketsStates>(
                                  builder: (BuildContext context, TicketsStates state) {
                                    return Stack(
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 30.0),
                                              child: Text("Select ticket category",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: MyColors.primaryColor,
                                                      fontWeight: FontWeight.normal)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                  bottom: 8.0,
                                                  top: 1.0),
                                              child: Container(
                                                padding:
                                                EdgeInsets.symmetric(horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(
                                                      color: MyColors.primaryColor,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 10.0, right: 20.0),
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: categoryDropdownValue,
                                                    icon: Icon(Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: TextStyle(
                                                        color: Colors.black, fontSize: 18),
                                                    underline: Container(
                                                      height: 0,
                                                      color: MyColors.primaryColor,
                                                    ),
                                                    onChanged: (String data) {
                                                      ticketsBloc.add(SelectSpinnerDataEvent(data));
                                                    },
                                                    items: categorySpinnerItems
                                                        .map<DropdownMenuItem<String>>(
                                                            (String value) {
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        (state is Loading)?Align(
                                          alignment: Alignment.center,
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
                                        ):Container(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: messageController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter your message.';
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
                                      Icon(Icons.message, color: Colors.blue),
                                      labelText: 'Message',
                                      labelStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      filled: true,
                                      fillColor: Colors.white70),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _sendButtonFill(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BlocListener<TicketsBloc, TicketsStates>(
                  listener: (BuildContext context, TicketsStates state) {
                    if(state is Processing){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if(state is NetworkErr){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    } else if(state is ViewError){
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content: Text(state.message, textAlign: TextAlign.center),
                        ),
                      );
                    }else if(state is TicketCreated){
                      Navigator.pop(context, state.message);
                    }
                  },
                  child: BlocBuilder<TicketsBloc, TicketsStates>(
                    builder: (BuildContext context, TicketsStates state) {
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  bool validateSpinner(){
    bool valid=true;
    if(categoryDropdownValue=='---category---'){
      valid=false;
      showToast(message: 'Please select category');
    }
    return valid;
  }

  Widget _sendButtonFill(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if(validateSpinner()){
              ticketsBloc.add(CreateTicketEvent(titleController.text, categorySpinnerIds[categorySpinnerItems.indexOf(categoryDropdownValue)], messageController.text));
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
          child: const Text("Send", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
