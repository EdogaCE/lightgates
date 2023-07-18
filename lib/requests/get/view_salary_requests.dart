import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/salary_recored.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/sub_payment.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewSalaryRepository {
  Future<List<SalaryRecord>> fetchSalaryRecord(String apiToken);
  Future<List<Teachers>> fetchTeacherSalaryRecord(String salaryRecordId);
}

class ViewSalaryRequest implements ViewSalaryRepository {
  List<SalaryRecord> _salaryRecord = new List();
  List<Teachers> _teachers = new List();
  @override
  Future<List<SalaryRecord>> fetchSalaryRecord(String apiToken) async {
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewSalaryRecordUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _salaryRecord.clear();
      if (map["return_data"]['main_teacher_payment_details_array'].length < 1) {
        throw ApiException(
            "No Salary record available, Please do well to add Some");
      }
      _populateRecordLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _salaryRecord;
  }

  void _populateRecordLists(Map result) {
    for (int i = 0;
        i < result['main_teacher_payment_details_array'].length;
        i++) {
      _salaryRecord.add(new SalaryRecord(
          id: result['main_teacher_payment_details_array'][i]["id"].toString(),
          uniqueId: result['main_teacher_payment_details_array'][i]["unique_id"].toString(),
          frequency: result['main_teacher_payment_details_array'][i]["payment_frequency"].toString(),
          title: result['main_teacher_payment_details_array'][i]["payment_title"].toString(),
          description: result['main_teacher_payment_details_array'][i]["description"].toString(),
          date: "${result['main_teacher_payment_details_array'][i]["start_date"].toString()} to ${result['main_teacher_payment_details_array'][i]["end_date"].toString()}",
          terms: Terms(
              id: result['term_details_array'][i]["id"].toString(),
              uniqueId: result['term_details_array'][i]["unique_id"].toString(),
              term: result['term_details_array'][i]["term"].toString(),
              date: "${result['term_details_array'][i]["term_start_date"].toString()},${result['term_details_array'][i]["term_end_date"].toString()}",
              status: result['term_details_array'][i]["status"].toString()),
          sessions: Sessions(
            id: result['session_details_array'][i]["id"].toString(),
            uniqueId: result['session_details_array'][i]["unique_id"].toString(),
            sessionDate: result['session_details_array'][i]["session_date"].toString(),
            startAndEndDate: "${result['session_details_array'][i]["session_start_date"].toString()},${result['session_details_array'][i]["session_end_date"].toString()}",
            admissionNumberPrefix: result['session_details_array'][i]["admission_no_prefix"].toString(),
            status: result['session_details_array'][i]["status"].toString(),
          )));
    }
  }

  @override
  Future<List<Teachers>> fetchTeacherSalaryRecord(String salaryRecordId) async {
    // TODO: implement fetchTeacherSalaryRecord
    print(MyStrings.domain + MyStrings.viewParticularSalaryRecordUrl + await getApiToken() + '/' + salaryRecordId);
    try {
      final response = await http.get(MyStrings.domain +
          MyStrings.viewParticularSalaryRecordUrl +
          await getApiToken() +
          '/' +
          salaryRecordId);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _teachers.clear();
      if (map["return_data"]["each_teacher_details_array"].length < 1) {
        throw ApiException(
            "No Teacher data available, Please do well to add Some");
      }
      _populateParticularRecordLists(map["return_data"], map);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.message);
      throw SystemError();
    }

    return _teachers;
  }

  void _populateParticularRecordLists(Map map, Map data) {
    for (int i = 0; i < map["each_teacher_details_array"].length; i++) {
      _teachers.add(new Teachers(
          id: map["each_teacher_details_array"][i]["id"].toString(),
          uniqueId:
              map["each_teacher_details_array"][i]["unique_id"].toString(),
          role: map["each_teacher_details_array"][i]["role"].toString(),
          title: map["each_teacher_details_array"][i]["title"].toString().replaceAll('null', ''),
          fName: map["each_teacher_details_array"][i]["firstname"].toString().replaceAll('null', ''),
          mName: map["each_teacher_details_array"][i]["othernames"].toString().replaceAll('null', ''),
          lName: map["each_teacher_details_array"][i]["lastname"].toString().replaceAll('null', ''),
          gender: map["each_teacher_details_array"][i]["sex"].toString(),
          phone: map["each_teacher_details_array"][i]["phone"].toString(),
          email: map["each_teacher_details_array"][i]["email"].toString(),
          passport: map["each_teacher_details_array"][i]["passport"].toString(),
          address: map["each_teacher_details_array"][i]["contact_address"]
              .toString(),
          city: map["each_teacher_details_array"][i]["city"].toString(),
          state: map["each_teacher_details_array"][i]["state"].toString(),
          nationality:
              map["each_teacher_details_array"][i]["country"].toString(),
          salary: map["each_teacher_details_array"][i]["salary"].toString(),
          dob: map["each_teacher_details_array"][i]["birthday"].toString(),
          employmentStatus: map["each_teacher_details_array"][i]["employment_status"].toString(),
          subPayment: SubPayment(
              id: map["sub_payment_table_details_array"][i]["id"].toString(),
              uniqueId: map["sub_payment_table_details_array"][i]["unique_id"].toString(),
              salary: map["sub_payment_table_details_array"][i]["salary"].toString(),
              bonus: map["sub_payment_table_details_array"][i]["bonus"].toString().replaceAll("", '0'),
              datePaid: map["sub_payment_table_details_array"][i]["date_paid"].toString(),
              bankAccountNumber: map["sub_payment_table_details_array"][i]["bank_account_number"].toString(),
              bankCode: map["sub_payment_table_details_array"][i]["bank_code"].toString(),
              paymentStatus: map["sub_payment_table_details_array"][i]["payment_status"].toString()),
          passportLink: map["teacher_passport_path"].toString(),
          school: School(
              name: data['current_school_details_array']['name'].toString(),
              email: data['current_school_details_array']['contact_email'].toString(),
              phone: data['current_school_details_array']['contact_phone_number'].toString(),
              preferredCurrencyId: data['current_school_details_array']['prefered_currency'].toString(),
              currency: Currency(
                id: data['current_school_details_array']['currency_rate']['id'].toString(),
                uniqueId: data['current_school_details_array']['currency_rate']['unique_id'].toString(),
                baseCurrency: data['current_school_details_array']['currency_rate']['base_currency'].toString(),
                secondCurrency: data['current_school_details_array']['currency_rate']['second_currency'].toString(),
                rateOfConversion: data['current_school_details_array']['currency_rate']['rate_of_conversion'].toString(),
                expression: data['current_school_details_array']['currency_rate']['expression'].toString(),
                currencyName: data['current_school_details_array']['currency_rate']['currency_name'].toString(),
                countryName: data['current_school_details_array']['currency_rate']['country_name'].toString(),
                countryAbr: data['current_school_details_array']['currency_rate']['country_abbr'].toString(),
                deleted: data['current_school_details_array']['currency_rate']['is_deleted'].toString()!='no',
              )
          )
      ));
    }
  }
}
