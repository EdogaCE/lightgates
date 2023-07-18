import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewTeachersRepository {
  Future<List<Teachers>> fetchTeachers({String apiToken, bool localDb});
}

class ViewTeachersRequest implements ViewTeachersRepository {
  List<Teachers> _teachers = new List();
  @override
  Future<List<Teachers>> fetchTeachers({String apiToken, bool localDb}) async {
      try {
        DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
        Map map;

        if(localDb){
          final localResponse=await databaseHandlerRepository.getData(title: 'teachers');
          map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
        }else{
          final response = await http
              .get(MyStrings.domain + MyStrings.viewTeachersUrl + apiToken);
          map = json.decode(response.body);
          logPrint(map.toString());

          if (map["status"].toString()!= 'true') {
            throw ApiException(
                handelServerError(response: map));
          }

          _teachers.clear();
          if (map["return_data"]["all_teachers"].isEmpty) {
            throw ApiException(
                "No Teacher available, Please do well to add Some");
          }

          if(await databaseHandlerRepository.getData(title: 'teachers')==null){
            databaseHandlerRepository.insertData(apiData: LocalData(title: 'teachers', data: jsonEncode(map)));
            print('Added ${jsonEncode(map)}');
          }else{
            databaseHandlerRepository.updateData(apiData: LocalData(title: 'teachers', data: jsonEncode(map)));
            print('Updated ${jsonEncode(map)}');
          }

        }

        if(map.isNotEmpty){
          _populateLists(map["return_data"], map);
        }

      } on SocketException {
        throw NetworkError();
      } on FormatException catch (e) {
        print(e.toString());
        throw SystemError();
      }

    return _teachers;
  }

  void _populateLists(Map map, Map data) {
    for (int i = 0; i < map["all_teachers"].length; i++) {
      //Building up teacher subject class array
      List<String> subject = List();
      List<String> clas = List();
      List<String> classSubjectId = List();
      List<Subjects> subjectDetail = List();
      List<Classes> classDetail = List();
      if (map["teacher_class_subject_details_array"].isNotEmpty) {
        try{
          List classSubject=map["teacher_class_subject_details_array"]
          [map["all_teachers"][i]["unique_id"].toString().replaceAll('null', '')];
          List subjects = map["teacher_subject_details_array"]
          [map["all_teachers"][i]["unique_id"].toString().replaceAll('null', '')];
          List classes = map["teacher_class_detail_array"]
          [map["all_teachers"][i]["unique_id"].toString().replaceAll('null', '')];

          for (var sub in classSubject) {
            classSubjectId.add(sub["id"].toString());
          }

          for (var sub in subjects) {
            subject.add(sub["title"].toString());
            subjectDetail.add(Subjects(
                id: sub["id"].toString().replaceAll('null', ''),
                uniqueId: sub["unique_id"].toString().replaceAll('null', ''),
                title: sub["title"].toString().replaceAll('null', ''),
                status: sub["status"].toString().replaceAll('null', '')
            ));
          }
          for (var cla in classes) {
            clas.add('${cla["class_label_details"]["label"]} ${ cla["class_category_details"]["category"]}');
            classDetail.add(Classes(
                id: cla["class_details_array"]["id"].toString().replaceAll('null', ''),
                uniqueId: cla["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
                status: cla["class_details_array"]["status"].toString().replaceAll('null', ''),
                category:cla["class_category_details"]["category"].toString().replaceAll('null', ''),
                label: cla["class_label_details"]["label"].toString().replaceAll('null', ''),
                level: cla["class_level_details"]["level"].toString().replaceAll('null', '')
            ));
          }
        }on NoSuchMethodError{}
      }

      List<Classes> _formClasses=List();
      List<Terms> _formTerms=List();
      List<Sessions> _formSessions=List();
      List<String> _formTeacherIds=List();
      try{
        if (map["all_teachers"][i]['formTeacherDetailsArray'].isNotEmpty) {
          for (var clas in map["all_teachers"][i]['formTeacherDetailsArray']) {

            _formTeacherIds.add(clas['id'].toString());

            _formClasses.add(Classes(
              id: clas['class_id'].toString().replaceAll('null', ''),
              level:  clas['class_level']['level'].toString().replaceAll('null', ''),
              label:  clas['class_label']['label'].toString().replaceAll('null', ''),
              category:  clas['class_category']['category'].toString().replaceAll('null', ''),
            ));
            _formTerms.add(Terms(
              id: clas['term_details']['id'].toString().replaceAll('null', ''),
              uniqueId: clas['term_details']['unique_id'].toString().replaceAll('null', ''),
              term: clas['term_details']['term'].toString().replaceAll('null', ''),
              status: clas['term_details']['status'].toString().replaceAll('null', ''),
            ));
            _formSessions.add(Sessions(
              id: clas['session_details']['id'].toString().replaceAll('null', ''),
              uniqueId: clas['session_details']['unique_id'].toString().replaceAll('null', ''),
              sessionDate: clas['session_details']['session_date'].toString().replaceAll('null', ''),
              admissionNumberPrefix: clas['session_details']['admission_no_prefix'].toString().replaceAll('null', ''),
              startAndEndDate: '${clas['session_details']['session_start_date'].toString().replaceAll('null', '')}, ${clas['session_details']['session_end_date'].toString().replaceAll('null', '')}',
              status: clas['session_details']['id'].toString().replaceAll('null', ''),
            ));
          }
        }
      }on NoSuchMethodError{}

      _teachers.add(new Teachers(
          id: map["all_teachers"][i]["id"].toString().replaceAll('null', ''),
          uniqueId: map["all_teachers"][i]["unique_id"].toString().replaceAll('null', ''),
          role: map["all_teachers"][i]["role"].toString().replaceAll('null', ''),
          title: map["all_teachers"][i]["title"].toString().replaceAll('null', ''),
          fName: map["all_teachers"][i]["firstname"].toString().replaceAll('null', ''),
          mName: map["all_teachers"][i]["othernames"].toString().replaceAll('null', ''),
          lName: map["all_teachers"][i]["lastname"].toString().replaceAll('null', ''),
          userName: map["all_teachers"][i]["username"].toString().replaceAll('null', ''),
          password: map["all_teachers"][i]["alt_pass"].toString().replaceAll('null', ''),
          gender: map["all_teachers"][i]["sex"].toString().replaceAll('null', ''),
          phone: map["all_teachers"][i]["phone"].toString().replaceAll('null', ''),
          email: map["all_teachers"][i]["email"].toString().replaceAll('null', ''),
          passport: map["all_teachers"][i]["passport"].toString().replaceAll('null', ''),
          address: map["all_teachers"][i]["contact_address"].toString().replaceAll('null', ''),
          city: map["all_teachers"][i]["city"].toString().replaceAll('null', ''),
          state: map["all_teachers"][i]["state"].toString().replaceAll('null', ''),
          nationality: map["all_teachers"][i]["country"].toString().replaceAll('null', ''),
          salary: map["all_teachers"][i]["salary"].toString().replaceAll('null', ''),
          dob: map["all_teachers"][i]["birthday"].toString().replaceAll('null', ''),
          subjects: subject,
          classes: clas,
          classesDetail: classDetail,
          subjectsDetail: subjectDetail,
          employmentStatus:
              map["all_teachers"][i]["employment_status"].toString().replaceAll('null', ''),
          passportLink: map["path_teacher_passport"].toString().replaceAll('null', ''),
        preferredCurrencyId: map["all_teachers"][i]["prefered_currency"].toString().replaceAll('null', ''),
        bankCode: map["all_teachers"][i]["bank_code"].toString().replaceAll('null', ''),
        bankName: map["all_teachers"][i]["bank_name"].toString().replaceAll('null', ''),
        bankAccountNumber: map["all_teachers"][i]["bank_account_number"].toString().replaceAll('null', ''),
        deleted: map["all_teachers"][i]["is_deleted"].toString().replaceAll('null', '')=='yes',
        currency: Currency(
          id:  map["all_teachers"][i]["currency_details"]['id'].toString().replaceAll('null', ''),
          uniqueId: map["all_teachers"][i]["currency_details"]['unique_id'].toString().replaceAll('null', ''),
          baseCurrency: map["all_teachers"][i]["currency_details"]['base_currency'].toString().replaceAll('null', ''),
          secondCurrency: map["all_teachers"][i]["currency_details"]['second_currency'].toString().replaceAll('null', ''),
          rateOfConversion: map["all_teachers"][i]["currency_details"]['rate_of_conversion'].toString().replaceAll('null', ''),
          expression: map["all_teachers"][i]["currency_details"]['expression'].toString().replaceAll('null', ''),
          currencyName: map["all_teachers"][i]["currency_details"]['currency_name'].toString().replaceAll('null', ''),
          countryName: map["all_teachers"][i]["currency_details"]['country_name'].toString().replaceAll('null', ''),
          countryAbr: map["all_teachers"][i]["currency_details"]['country_abbr'].toString().replaceAll('null', ''),
          deleted: map["all_teachers"][i]["currency_details"]['is_deleted'].toString().replaceAll('null', '')!='no',
        ),
        school: School(
            name: data['current_school_details_array']['name'].toString().replaceAll('null', ''),
            email: data['current_school_details_array']['contact_email'].toString().replaceAll('null', ''),
            phone: data['current_school_details_array']['contact_phone_number'].toString().replaceAll('null', ''),
            preferredCurrencyId: data['current_school_details_array']['prefered_currency'].toString().replaceAll('null', ''),
            currency: Currency(
              id: data['current_school_details_array']['currency_rate']['id'].toString().replaceAll('null', ''),
              uniqueId: data['current_school_details_array']['currency_rate']['unique_id'].toString().replaceAll('null', ''),
              baseCurrency: data['current_school_details_array']['currency_rate']['base_currency'].toString().replaceAll('null', ''),
              secondCurrency: data['current_school_details_array']['currency_rate']['second_currency'].toString().replaceAll('null', ''),
              rateOfConversion: data['current_school_details_array']['currency_rate']['rate_of_conversion'].toString().replaceAll('null', ''),
              expression: data['current_school_details_array']['currency_rate']['expression'].toString().replaceAll('null', ''),
              currencyName: data['current_school_details_array']['currency_rate']['currency_name'].toString().replaceAll('null', ''),
              countryName: data['current_school_details_array']['currency_rate']['country_name'].toString().replaceAll('null', ''),
              countryAbr: data['current_school_details_array']['currency_rate']['country_abbr'].toString().replaceAll('null', ''),
              deleted: data['current_school_details_array']['currency_rate']['is_deleted'].toString().replaceAll('null', '')!='no',
            )
        ),
        formClasses: _formClasses,
        formSession: _formSessions,
        formTerm: _formTerms,
        formTeacherAssignId: _formTeacherIds,
        classSubjectId: classSubjectId
      ));
    }
  }
}
