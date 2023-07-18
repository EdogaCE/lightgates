import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/handlers/database_handler.dart';
import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewStudentsRepository {
  Future<List<Students>> fetchStudents({String apiToken, bool localDb});
}

class ViewStudentsRequest implements ViewStudentsRepository {
  List<Students> _students = new List();
  @override
  Future<List<Students>> fetchStudents({String apiToken, bool localDb}) async {
    try {
      DatabaseHandlerRepository databaseHandlerRepository=DatabaseHandlerOperations();
      Map map;
      if(localDb){
        final localResponse=await databaseHandlerRepository.getData(title: 'students');
        map=(localResponse!=null)?json.decode(localResponse.data):json.decode('{}');
      }else{
        final response = await http
            .get(MyStrings.domain + MyStrings.viewStudentsUrl + apiToken);
        map = json.decode(response.body);
        logPrint(map.toString());

        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _students.clear();
        if (map["return_data"].isEmpty) {
          throw ApiException(
              "No Student data available, Please do well to add Some");
        }

        if(await databaseHandlerRepository.getData(title: 'students')==null){
          databaseHandlerRepository.insertData(apiData: LocalData(title: 'students', data: jsonEncode(map)));
          print('Added ${jsonEncode(map)}');
        }else{
          databaseHandlerRepository.updateData(apiData: LocalData(title: 'students', data: jsonEncode(map)));
          print('Updated ${jsonEncode(map)}');
        }

      }

      if(map.isNotEmpty){
        _populateLists(map["return_data"]);
      }

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _students;
  }

  void _populateLists(Map map) {
    for (int i = 0; i < map["students_details_array"].length; i++) {
      _students.add(new Students(
          id: map["students_details_array"][i]["id"].toString().replaceAll('null', ''),
          uniqueId: map["students_details_array"][i]["unique_id"].toString().replaceAll('null', ''),
          fName: map["students_details_array"][i]["firstname"].toString().replaceAll('null', ''),
          mName: map["students_details_array"][i]["othernames"].toString().replaceAll('null', ''),
          lName: map["students_details_array"][i]["lastname"].toString().replaceAll('null', ''),
          email: map["students_details_array"][i]["email"].toString().replaceAll('null', ''),
          userName: map["students_details_array"][i]["username"].toString().replaceAll('null', ''),
          password: map["students_details_array"][i]["auth_pass"].toString().replaceAll('null', ''),
          phone: map["students_details_array"][i]["phone"].toString().replaceAll('null', ''),
          gender: map["students_details_array"][i]["sex"].toString().replaceAll('null', ''),
          passport: map["students_details_array"][i]["passport"].toString().replaceAll('null', ''),
          dob: map["students_details_array"][i]["birthday"].toString().replaceAll('null', ''),
          bloodGroup: map["students_details_array"][i]["blood_group"].toString().replaceAll('null', ''),
          genotype: map["students_details_array"][i]["genotype"].toString().replaceAll('null', ''),
          healthHistory: map["students_details_array"][i]["health_history"].toString().replaceAll('null', ''),
          admissionNumber: map["students_details_array"][i]
              ["addmission_number"].toString().replaceAll('null', ''),
          genAdmissionNumber: map["students_details_array"][i]
              ["gen_addmission_number"].toString().replaceAll('null', ''),
          residentAddress: map["students_details_array"][i]["resident_address"].toString().replaceAll('null', ''),
          city: map["students_details_array"][i]["city"].toString().replaceAll('null', ''),
          state: map["students_details_array"][i]["state"].toString().replaceAll('null', ''),
          nationality: map["students_details_array"][i]["nationality"].toString().replaceAll('null', ''),
          preferredCurrencyId: map["students_details_array"][i]["prefered_currency"].toString().replaceAll('null', ''),
          boardingStatus: map["students_details_array"][i]["boarding_status"].toString().replaceAll('null', '')=='yes',
          deleted: map["students_details_array"][i]["is_deleted"].toString().replaceAll('null', '')!='no',
          stClass:
              "${map["class_details_array"][i]["class_label_details"]["label"]} ${map["class_details_array"][i]["class_category_details"]["category"]}",
          parentId: map["parent_details_array"][i]["id"].toString().replaceAll('null', ''),
          parentName: map["parent_details_array"][i]["parent_full_name"].toString().replaceAll('null', ''),
          parentTitle: map["parent_details_array"][i]["parent_title"].toString().replaceAll('null', ''),
          parentPhone: map["parent_details_array"][i]["parent_phone"].toString().replaceAll('null', ''),
          parentEmail: map["parent_details_array"][i]["parent_email"].toString().replaceAll('null', ''),
          parentAddress: map["parent_details_array"][i]["parent_address"].toString().replaceAll('null', ''),
          parentPassport: map["parent_details_array"][i]["parent_passport"].toString().replaceAll('null', ''),
          parentOccupation: map["parent_details_array"][i]
              ["parents_occupation"].toString().replaceAll('null', ''),
          passportLink: map["students_passprt_link"].toString().replaceAll('null', ''),
          parentPassportLink: map["parents_passport_link"].toString().replaceAll('null', ''),
          particularSchoolDetails: map["particular_scholl_details"].toString().replaceAll('null', ''),
        classes: new Classes(
          status: map["class_details_array"][i]["class_details_array"]["status"].toString().replaceAll('null', ''),
          id: map["class_details_array"][i]["class_details_array"]["id"].toString().replaceAll('null', ''),
          uniqueId: map["class_details_array"][i]["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
          date:'${map["class_details_array"][i]["class_details_array"]["created_at"]}, ${map["class_details_array"][i]["class_details_array"]["updated_at"]}',
          category: map["class_details_array"][i]["class_category_details"]["category"].toString().replaceAll('null', ''),
          label: map["class_details_array"][i]["class_label_details"]["label"].toString().replaceAll('null', ''),
          level: map["class_details_array"][i]["class_level_details"]["level"].toString().replaceAll('null', '')
        ),
        sessions: new Sessions(
          uniqueId:  map["students_details_array"][i]["session"]["unique_id"].toString().replaceAll('null', ''),
          id: map["students_details_array"][i]["session"]["id"].toString().replaceAll('null', ''),
          status: map["students_details_array"][i]["session"]["status"].toString().replaceAll('null', ''),
          startAndEndDate: '${map["students_details_array"][i]["session"]["session_start_date"].toString().replaceAll('null', '')}, ${map["students_details_array"][i]["session"]["session_end_date"].toString().replaceAll('null', '')}',
          sessionDate: map["students_details_array"][i]["session"]["session_date"].toString().replaceAll('null', ''),
          admissionNumberPrefix: map["students_details_array"][i]["session"]["admission_no_prefix"].toString().replaceAll('null', '')
        ),
        currency: Currency(
          id: map["students_details_array"][i]["currency_details"]["id"].toString().replaceAll('null', ''),
          uniqueId: map["students_details_array"][i]["currency_details"]["unique_id"].toString().replaceAll('null', ''),
          baseCurrency: map["students_details_array"][i]["currency_details"]["base_currency"].toString().replaceAll('null', ''),
          secondCurrency: map["students_details_array"][i]["currency_details"]["second_currency"].toString().replaceAll('null', ''),
          rateOfConversion: map["students_details_array"][i]["currency_details"]["rate_of_conversion"].toString().replaceAll('null', ''),
          expression: map["students_details_array"][i]["currency_details"]["expression"].toString().replaceAll('null', ''),
          currencyName: map["students_details_array"][i]["currency_details"]["currency_name"].toString().replaceAll('null', ''),
          countryName: map["students_details_array"][i]["currency_details"]["country_name"].toString().replaceAll('null', ''),
          countryAbr: map["students_details_array"][i]["currency_details"]["country_abbr"].toString().replaceAll('null', ''),
          deleted: map["students_details_array"][i]["currency_details"]["is_deleted"].toString().replaceAll('null', '')!='no',
        )
      ));
    }
  }
}
