import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_pal/blocs/dashboard/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/models/faqs.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/add_edit_faq_dialog.dart';
import 'package:school_pal/ui/general.dart';
import 'package:school_pal/utils/system.dart';
import 'dashboard.dart';

Widget faqPage({BuildContext context, DashboardBloc dashboardBloc, String loggedInAs}) {
  List<FAQs> _faqs;
  return Container(
    height: double.infinity,
    width: double.infinity,
    child: Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: MyColors.primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35.0),
                        child: Text("FAQ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(dashboardBloc, _faqs, loggedInAs));
                      },
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocListener<DashboardBloc, DashboardStates>(listener:
                  (BuildContext context, DashboardStates state) {
                    if (state is Processing) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Processing..."),
                        ),
                      );
                    }else if (state is FAQsAdded) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      dashboardBloc.add(ViewFAQsEvent(localDB: false));
                    } else if (state is FAQsUpdated) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      dashboardBloc.add(ViewFAQsEvent(localDB: false));
                    } else if (state is FAQsDeleted) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message, textAlign: TextAlign.center),
                          ),
                        );
                      dashboardBloc.add(ViewFAQsEvent(localDB: false));
                    }  else if (state is NetworkErr) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                        ),
                      );
                    } else if (state is ViewError) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                        ),
                      );
                      if (state.message == "Please Login to continue") {
                        reLogUserOut(context);
                      }
                    } else if (state is FAQsLoaded) {
                      _faqs = state.faqs;
                    }else if (state is LoggingOut) {
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                        SnackBar(
                          duration: Duration(minutes: 30),
                          content: General.progressIndicator("Logging Out..."),
                        ),
                      );
                    } else if (state is LogoutSuccessful) {
                      logUserOut(context);
                    }
              },
                child:BlocBuilder<DashboardBloc, DashboardStates>(builder:
                    (BuildContext context, DashboardStates state) {
                      if (state is InitialState) {
                        return buildInitialScreen();
                      } else if (state is Loading) {
                        try{
                          return _faqs.isNotEmpty?_buildLoadedScreen(context, dashboardBloc, _faqs, loggedInAs):buildLoadingScreen();
                        }on NoSuchMethodError {
                          return buildLoadingScreen();
                        }
                      } else if (state is FAQsLoaded) {
                        return _buildLoadedScreen(context, dashboardBloc, state.faqs, loggedInAs);
                      } else if (state is ViewError) {
                        try{
                          return _faqs.isNotEmpty?_buildLoadedScreen(context, dashboardBloc, _faqs, loggedInAs):buildNODataScreen();
                        }on NoSuchMethodError {
                          return buildNODataScreen();
                        }

                      }else if (state is NetworkErr) {
                        try{
                          return  _faqs.isNotEmpty?_buildLoadedScreen(context, dashboardBloc, _faqs, loggedInAs):buildNetworkErrorScreen("faq");
                        }on NoSuchMethodError {
                          return buildNetworkErrorScreen("faq");
                        }

                      } else {
                        try{
                          return _faqs.isNotEmpty?_buildLoadedScreen(context, dashboardBloc, _faqs, loggedInAs):buildInitialScreen();
                        }on NoSuchMethodError {
                          return buildInitialScreen();
                        }
                      }
                }),

              ),
            ),
          ],
        ),
        (loggedInAs==MyStrings.school)?Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: FloatingActionButton(
              heroTag: "Add FAQ",
              onPressed: () {
                _showAddEditFaqModalDialog(dashboardBloc: dashboardBloc, context: context, type: 'Add');
              },
              child: Icon(Icons.add),
              backgroundColor: MyColors.primaryColor,
            ),
          ),
        ):Container(),
      ],
    ),
  );
}

Widget _buildLoadedScreen(BuildContext context, DashboardBloc dashboardBloc,  List<FAQs> faqs, String loggedInAs){
  return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: faqs.length,
      itemBuilder: (BuildContext context, int index) {
        //if (index.isOdd) return Divider();
        return _buildRow(context, dashboardBloc, faqs, index, loggedInAs);
      });
}


Widget _buildRow(BuildContext context, DashboardBloc dashboardBloc,  List<FAQs> faqs, int index, String loggedInAs) {
  return Center(
    child: Card(
      // margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 1,
      child: ExpansionTile(
        backgroundColor: Colors.green.shade50,
        title: Text(toSentenceCase(faqs[index].question),
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold)),
        children: <Widget>[
          ListTile(
            title: Text(faqs[index].answer,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.normal)),
            onLongPress: () {
              if(loggedInAs==MyStrings.student)
                showEditOrDeleteModalBottomSheet(dashboardBloc: dashboardBloc, context: context, faQs: faqs[index], type: 'Edit');
            },
          ),
        ],
      ),
    ),
  );
}


class CustomSearchDelegate extends SearchDelegate {
  final List<FAQs> faqs;
  final String loggedInAs;
  final DashboardBloc dashboardBloc;
  CustomSearchDelegate(this.dashboardBloc, this.faqs, this.loggedInAs);

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
          ? faqs
          : faqs
          .where((p) =>
          p.question.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return _buildLoadedScreen(context, dashboardBloc, suggestionList, loggedInAs);

    } on NoSuchMethodError {
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
      final suggestionList = query.isEmpty
          ? faqs
          : faqs
          .where((p) =>
          p.question.toUpperCase().contains(query.toUpperCase()))
          .toList();

      return _buildLoadedScreen(context, dashboardBloc, suggestionList, loggedInAs);
    } on NoSuchMethodError {
      return Center(
        child: Text(
          MyStrings.searchErrorMessage,
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }
  }
}

void showEditOrDeleteModalBottomSheet({DashboardBloc dashboardBloc, BuildContext context, FAQs faQs, type}) {
  showModalBottomSheet(
      context: context,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                  _showAddEditFaqModalDialog(dashboardBloc: dashboardBloc, context: context, faQs: faQs, type: 'Edit');
                },
              ),
              ListTile(
                  leading: new Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: new Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    dashboardBloc.add(DeleteFaqsEvent(faQs.id));
                  }),
            ],
          ),
        );
      });
}


void _showAddEditFaqModalDialog({DashboardBloc dashboardBloc, BuildContext context, FAQs faQs, type}) async {
  final data = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: (type=='Add')?AddEditFaqDialog(title: type):AddEditFaqDialog(title: type, question: faQs.question, answer: faQs.answer),
        );
      });
  if (data != null) {
//TODO: Activate term here
    print(data.toString());
    if(type=='Add'){
      dashboardBloc.add(AddFaqEvent(data[0], data[1]));
    }else{
      dashboardBloc.add(UpdateFaqEvent(faQs.id, data[0], data[1]));
    }
  }
}
