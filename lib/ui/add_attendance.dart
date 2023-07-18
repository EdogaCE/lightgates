import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/results/results.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_pal/requests/posts/result_requests.dart';
import 'package:school_pal/res/colors.dart';
import 'package:school_pal/utils/system.dart';
import 'general.dart';

class AddAttendance extends StatelessWidget {
  final Map<String, String> values;
  final List<String> attendanceHeader;
  final List<List<String>> attendance;
  AddAttendance({this.values, this.attendanceHeader, this.attendance});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResultsBloc(resultRepository: ResultRequests()),
      child: AddAttendancePage(values, attendanceHeader, attendance),
    );
  }
}

// ignore: must_be_immutable
class AddAttendancePage extends StatelessWidget {
  final Map<String, String> values;
  final List<String> attendanceHeader;
  final List<List<String>> attendance;
  AddAttendancePage(this.values, this.attendanceHeader, this.attendance);
  ResultsBloc _resultsBloc;

  @override
  Widget build(BuildContext context) {
    _resultsBloc = BlocProvider.of<ResultsBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  List<String> studentAttendanceHeader=List()..addAll(attendanceHeader);
                  List<String> studentsAttendance= List();
                  studentAttendanceHeader.removeRange(0, 2);
                  studentAttendanceHeader.removeAt(1);

                  for(int i=0; i<attendance.length; i++){
                    List<String> newAttendance=List()..addAll(attendance[i]);
                    newAttendance.removeRange(0, 2);
                    newAttendance.removeAt(1);
                    studentsAttendance.add(newAttendance.join(','));
                  }
                  _resultsBloc.add(AddStudentsAttendanceEvent(values['classId'], values['termId'], values['sessionId'], studentAttendanceHeader, studentsAttendance));
                    print(studentAttendanceHeader);
                    print(studentsAttendance);
                },
                child: Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('Students Attendance'),
                titlePadding: const EdgeInsets.all(15.0),
                background: Center(
                    child: SvgPicture.asset(
                        "lib/assets/images/assessment1.svg")
                )),
          ),
          _buildSalaryRecord(context)
        ],
      ),
    );
  }

  Widget _buildSalaryRecord(context) {
    return BlocListener<ResultsBloc, ResultsStates>(
      listener: (context, state) {
        //Todo: note listener returns void
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
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        } else if (state is ViewError) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          if (state.message == "Please Login to continue") {
            reLogUserOut(context);
          }
        }else if (state is StudentsAttendanceAdded) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
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
        }else if(state is ViewError){
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message, textAlign: TextAlign.center),
              ),
            );
        }
      },
      child: BlocBuilder<ResultsBloc, ResultsStates>(
        builder: (context, state) {
          //Todo: note builder returns widget
          return _buildLoadedScreen(context, attendance);

        },
      ),
    );
  }

  Widget _buildLoadedScreen(BuildContext context,
      List<List<String>> attendance) {
    return SliverList(
        delegate: SliverChildListDelegate([
          SingleChildScrollView(
            child: Card(
              // margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              elevation: 1,
              color: MyColors.primaryColorShade500,
              child: _buildRow(context, attendance),
            ),
          ),
        ])
    );
  }

  Widget _buildRow(BuildContext context, List<List<String>> attendance) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildAttendanceCell(context,attendanceHeader, attendanceHeader.length, 0, true),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildRows(context, attendance, attendance.length),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildRows(BuildContext context, List<List<String>> attendance, int count) {
    return List.generate(
      count,
          (index) => Column(
        children:_buildAttendanceCell(context, attendance[index], attendance[index].length, index, false),
      ),
    );
  }

  List<Widget> _buildAttendanceCell(BuildContext context, List<String> attendanceRow, int count, int rowIndex, bool title) {
    return List.generate(
      count,
          (index) => Container(
        alignment: Alignment.center,
        width: 150.0,
        height: 60.0,
        color: (title)?MyColors.primaryColorShade500:(rowIndex%2!=0)?Colors.white70:Colors.white,
        margin: EdgeInsets.all(2.0),
        padding: EdgeInsets.all(5.0),
        child: (!title && (index>3))
            ?inputForm(attendanceRow, rowIndex, index)
            :Text(toSentenceCase(attendanceRow[index]),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: (!title)?Colors.black87:Colors.white,
                fontWeight: (!title)?FontWeight.normal:FontWeight.bold)),
      ),
    );
  }

  Widget inputForm(List<String> attendanceRow, int rowIndex, index){
    final entryController = TextEditingController(text: attendanceRow[index]);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: entryController,
        keyboardType: TextInputType.number,
        onChanged: (value){
          attendance[rowIndex][index]=value;
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Make an entry.';
          }
          return null;
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(0.0),
              ),
            ),
            //icon: Icon(Icons.email),
            labelText: 'Entry',
            labelStyle: new TextStyle(
                color: Colors.grey[800]),
            filled: true,
            fillColor: (rowIndex%2!=0)?Colors.white70:Colors.white),
      ),
    );
  }
}
