import 'package:flutter/material.dart';
import 'package:school_pal/blocs/salary/salary.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/paints/paint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_salary_requests.dart';
import 'package:school_pal/requests/posts/create_update_salary_request.dart';
import 'package:school_pal/res/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/ui/teacher_details.dart';
import 'package:school_pal/utils/system.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'general.dart';

class ViewTeachersSalary extends StatelessWidget {
  final SalaryRecord salaryRecord;
  final List<Teachers> teachers;
  final String classes;
  ViewTeachersSalary({this.salaryRecord, this.teachers, this.classes});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SalaryBloc>(
          create: (context) => SalaryBloc(viewSalaryRepository: ViewSalaryRequest(),
              createSalaryRepository: CreateSalaryRequests()),
        ),
      ],
      child: ViewTeachersSalaryPage(salaryRecord, teachers, classes),
    );
  }
}

// ignore: must_be_immutable
class ViewTeachersSalaryPage extends StatelessWidget {
  final SalaryRecord salaryRecord;
  List<Teachers> teachers;
  final String classes;
  ViewTeachersSalaryPage(this.salaryRecord, this.teachers, this.classes);

  static bool _updated=false;
  static SalaryBloc _salaryBloc;
  void _viewTeachers() async {
      _salaryBloc.add(ViewParticularSalaryRecordEvent(salaryRecord.id));
  }

  @override
  Widget build(BuildContext context) {
    _salaryBloc = BlocProvider.of<SalaryBloc>(context);
    _viewTeachers();
    final _refreshController = RefreshController();

    return WillPopScope(
      onWillPop: () =>_popNavigator(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _viewTeachers();
              _refreshController.refreshCompleted();
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(teachers, salaryRecord));
                        })
                  ],
                  pinned: true,
                  expandedHeight: 250.0,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text('Pay Teachers'),
                      titlePadding: const EdgeInsets.all(15.0),
                      background: CustomPaint(
                        painter: CustomScrollPainter(),
                        child:Center(
                            child:SvgPicture.asset("lib/assets/images/teachers.svg")
                        ),
                      )),
                ),
                _teachersSalaryGrid(context)
              ],
            )),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "Pay Teachers",
          onPressed: () {
            List<String> idForPaymentsToBeUpdated=List();
            List<String> salary=List();
            List<String> bonus=List();
            List<String> paymentStatus=List();
            for(Teachers teacher in teachers){
              if(teacher.subPayment.payAccount){
                idForPaymentsToBeUpdated.add(teacher.subPayment.id);
                salary.add(teacher.subPayment.salary);
                bonus.add(teacher.subPayment.bonus);
                paymentStatus.add(teacher.subPayment.paymentStatus);
              }
            }
            _salaryBloc.add(PayTeachersSalaryEvent(idForPaymentsToBeUpdated: idForPaymentsToBeUpdated, salary: salary, bonus: bonus, paymentStatus: paymentStatus, paymentId: salaryRecord.id));
          },
          label: Text('Process Payment'),
          icon: Icon(Icons.payment),
          backgroundColor: MyColors.primaryColor,
        ),
      ),
    );
  }

  Widget _teachersSalaryGrid(context) {
    return BlocListener<SalaryBloc, SalaryStates>(
      listener: (context, state) {
        //Todo: note listener returns void
        if (state is SalaryNetworkErr) {
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
        } else if (state is SalaryViewError) {
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
        } else if (state is ParticularSalaryRecordLoaded) {
          teachers = state.salaryRecord;
        } else if (state is TeacherSalaryRecordUpdated) {
          //Navigator.pop(context, state.message);
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewTeachers();
        }else if (state is TeacherSelected) {
          teachers[state.index].subPayment.payAccount=state.isSelected;
        }else if (state is TeachersSalaryPaid) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                Text(state.message, textAlign: TextAlign.center),
              ),
            );
          _viewTeachers();
        }
      },
      child: BlocBuilder<SalaryBloc, SalaryStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          if (state is SalaryInitial) {
            return buildInitialScreen();
          } else if (state is SalaryLoading) {
            try{
              return _buildLoadedScreen(context, teachers);
            }on NoSuchMethodError{
              return buildLoadingScreen();
            }
          } else if (state is ParticularSalaryRecordLoaded) {
            return _buildLoadedScreen(context, state.salaryRecord);
          } else if (state is SalaryViewError) {
            try{
              return _buildLoadedScreen(context, teachers);
            }on NoSuchMethodError{
              return buildNODataScreen();
            }
          }else if (state is SalaryNetworkErr) {
            try{
              return _buildLoadedScreen(context, teachers);
            }on NoSuchMethodError{
              return buildNetworkErrorScreen();
            }
          } else {
            try{
              return _buildLoadedScreen(context, teachers);
            }on NoSuchMethodError{
              return buildInitialScreen();
            }
          }
        },
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
                      valueColor:
                      new AlwaysStoppedAnimation<Color>(MyColors.primaryColor),
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
              onTap: () {
                _viewTeachers();
              },
            ),
          ),
        ));
  }

  Widget _buildLoadedScreen(BuildContext context, List<Teachers> teachers) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return _buildRow(context: context, teachers: teachers, index: index, salaryRecord: salaryRecord);
      }, childCount: teachers.length),
    );
  }

  static void showOptionsModalBottomSheet({BuildContext context,List<Teachers> teachers, int index, SalaryRecord salaryRecord}) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    Icons.view_agenda,
                    color: Colors.amber,
                  ),
                  title: new Text('View'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToViewTeachersDetailScreen(context, teachers, index, salaryRecord);
                  },
                ),
                (teachers[index].subPayment.paymentStatus=='not_paid')?ListTile(
                    leading: new Icon(
                      Icons.check_box,
                      color: Colors.green,
                    ),
                    title: new Text('Mark Paid'),
                    onTap: () {
                      Navigator.pop(context);
                      _salaryBloc.add(UpdateTeacherSalaryRecordEvent(
                          teachers[index].subPayment.id,
                          'paid'));
                    }):ListTile(
                    leading: new Icon(
                      Icons.check_box,
                      color: Colors.red,
                    ),
                    title: new Text('Mark Not Paid'),
                    onTap: () {
                      Navigator.pop(context);
                      _salaryBloc.add(UpdateTeacherSalaryRecordEvent(
                          teachers[index].subPayment.id,
                          'not_paid'));
                    }),
              ],
            ),
          );
        });
  }

  static _navigateToViewTeachersDetailScreen(BuildContext context,List<Teachers> teachers, int index,  SalaryRecord salaryRecord) async {

    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TeachersDetails(teachers: teachers, index: index, salaryRecord: salaryRecord, from: 'salary'),
    ));

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if(result!=null){
      //Refresh after update
      try{
        _salaryBloc.add(ViewParticularSalaryRecordEvent(salaryRecord.id));
      }on NoSuchMethodError{}
    }
  }

  Future<bool> _popNavigator(BuildContext context) async {
    if (_updated) {
      print("onwill goback");
      Navigator.pop(context, 'new update');
      return Future.value(false);
    } else {
      print("onwillNot goback");
      return Future.value(true);
    }
  }

}

Widget _buildRow({BuildContext context, List<Teachers> teachers, int index, SalaryRecord salaryRecord}) {
  final bonusController=TextEditingController(text: convertPriceNoFormatting(currency: teachers[index].school.currency, amount: teachers[index].subPayment.bonus));
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Card(
        // margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        child: ListTile(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Container(
                  child: Hero(
                    tag: "teacher passport tag $index",
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                          placeholderScale: 5,
                          height: 80,
                          width: 80,
                          fit: BoxFit.fill,
                          fadeInDuration: const Duration(seconds: 1),
                          fadeInCurve: Curves.easeInCirc,
                          placeholder: 'lib/assets/images/avatar.png',
                          image: teachers[index].passportLink+teachers[index].passport,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                toSentenceCase(teachers[index].subPayment.paymentStatus.replaceAll('_', ' ')),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: teachers[index].subPayment.paymentStatus=='not_paid'?Colors.red
                                        :teachers[index].subPayment.paymentStatus=='processing'?Colors.orange:Colors.green,
                                    fontWeight: FontWeight.normal)),
                          ),
                          Checkbox(value: teachers[index].subPayment.payAccount, onChanged:(bool checked){
                            BlocProvider.of<SalaryBloc>(context).add(SelectTeacherEvent(isSelected: !teachers[index].subPayment.payAccount, index: index));
                          }),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                            '${toSentenceCase(teachers[index].title)} ${toSentenceCase(teachers[index].lName)} ${toSentenceCase(teachers[index].fName)} ${toSentenceCase(teachers[index].mName)}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: MyColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                            convertPrice(currency: teachers[index].school.currency, amount: teachers[index].subPayment.salary),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal)),
                      ),
                      TextField(
                        controller: bonusController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: 'Bonus',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:  BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                          ),
                        ),
                        onChanged: (value){
                          teachers[index].subPayment.bonus=value;
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            ViewTeachersSalaryPage._navigateToViewTeachersDetailScreen(context, teachers, index, salaryRecord);
            // Add 9 lines from here...
          },
          onLongPress: (){
            BlocProvider.of<SalaryBloc>(context).add(SelectTeacherEvent(isSelected: !teachers[index].subPayment.payAccount, index: index));
            //ViewTeachersSalaryPage.showOptionsModalBottomSheet(context: context, teachers: teachers,index: index, salaryRecord: salaryRecord);
          },// ... to here.// ... to here.
        ),
      ),
    ),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Teachers> teachers;
  final SalaryRecord salaryRecord;
  CustomSearchDelegate(this.teachers, this.salaryRecord);

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
          ? teachers
          : teachers
          .where((p) =>
      (p.email.toLowerCase().contains(query.toLowerCase())) ||
          (p.fName.toLowerCase().contains(query.toLowerCase())) ||
          (p.mName.toLowerCase().contains(query.toLowerCase())) ||
          (p.lName.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context: context, teachers: suggestionList, index: index, salaryRecord: salaryRecord);
          });

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
          ? teachers
          : teachers
          .where((p) =>
      (p.email.toLowerCase().contains(query.toLowerCase())) ||
          (p.fName.toLowerCase().contains(query.toLowerCase())) ||
          (p.mName.toLowerCase().contains(query.toLowerCase())) ||
          (p.lName.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: suggestionList.length,
          itemBuilder: (BuildContext context, int index) {
            //if (index.isOdd) return Divider();
            return _buildRow(context: context, teachers: suggestionList, index: index, salaryRecord: salaryRecord);
          });

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
