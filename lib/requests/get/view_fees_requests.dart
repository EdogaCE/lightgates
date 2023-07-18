import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/fees.dart';
import 'package:school_pal/models/fees_payment.dart';
import 'package:school_pal/models/fees_payment_detail.dart';
import 'package:school_pal/models/fees_recored.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewFeesRepository {
  Future<List<FeesRecord>> fetchFeesRecord(String apiToken);
  Future<String> deleteFeesRecord(String recordId);
  Future<String> restoreFeesRecord(String recordId);
  Future<List<Fees>> fetchFees(String apiToken, String recordId);
  Future<List<Students>> fetchFeesPayments({String apiToken, String recordId, String filter, String dateFrom, String dateTo});
  Future<List<Students>> fetchStudentFees({String apiToken, String studentId});
}

class ViewFeesRequest implements ViewFeesRepository {
  List<FeesRecord> _feesRecord = new List();
  List<Fees> _fees = new List();
  List<Students> _students = new List();

  @override
  Future<List<FeesRecord>> fetchFeesRecord(String apiToken) async {
    try {
      final response = await http.get(
          MyStrings.domain + MyStrings.viewFeesRecordUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _feesRecord.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Fees record available, Please do well to add Some");
      }
      _populateRecordLists(map["return_data"]);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _feesRecord;
  }

  void _populateRecordLists(List result) {
    for (int i = 0; i < result.length; i++) {
      _feesRecord.add(new FeesRecord(
          id: result[i]['id'].toString(),
          uniqueId: result[i]['unique_id'].toString(),
          title: result[i]['title'].toString(),
          type: result[i]['fee_type'].toString(),
          description: result[i]['description'].toString(),
          date: '${result[i]['created_at']
              .toString()}, ${result[i]['updated_at'].toString()}',
          sessionId: result[i]['session_i'].toString(),
          termId: result[i]['term_id'].toString(),
          deleted: result[i]['is_deleted'].toString() != 'no'
      ));
    }
  }

  @override
  Future<List<Fees>> fetchFees(String apiToken, String recordId) async {
    // TODO: implement fetchFees
    try {
      final response = await http.get(
          MyStrings.domain + MyStrings.viewFeesUrl + apiToken + '/$recordId');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _fees.clear();
      if (map["return_data"]['all_fees'].length < 1) {
        throw ApiException(
            "No Fees available, Please do well to add Some");
      }
      _populateFeesLists(map["return_data"], map);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _fees;
  }

  void _populateFeesLists(Map result, Map map) {
    for (int i = 0; i < result['all_fees'].length; i++) {
      _fees.add(new Fees(
          id: result['all_fees'][i]['id'].toString(),
          uniqueId: result['all_fees'][i]['unique_id'].toString(),
          title: result['all_fees'][i]['title'].toString(),
          division: result['all_fees'][i]['division'].toString(),
          amount: result['all_fees'][i]['amount'].toString(),
          date: '${result['all_fees'][i]['created_at']
              .toString()}, ${result['all_fees'][i]['updated_at'].toString()}',
          deleted: result['all_fees'][i]['is_deleted'].toString() != 'no',
          classId: result['all_fees'][i]['class_tb_id'].toString(),
          recordId: result['all_fees'][i]['fee_category_id'].toString(),
          feesRecord: new FeesRecord(
              id: result['id'].toString(),
              uniqueId: result['unique_id'].toString(),
              title: result['title'].toString(),
              type: result['fee_type'].toString(),
              description: result['description'].toString(),
              date: '${result['created_at'].toString()}, ${result['updated_at']
                  .toString()}',
              sessionId: result['session_i'].toString(),
              termId: result['term_id'].toString(),
              deleted: result['is_deleted'].toString() != 'no'
          ),
        currency: Currency(
          id: map['current_school_details_array']['currency_rate']['id'].toString(),
          uniqueId: map['current_school_details_array']['currency_rate']['unique_id'].toString(),
          baseCurrency: map['current_school_details_array']['currency_rate']['base_currency'].toString(),
          secondCurrency: map['current_school_details_array']['currency_rate']['second_currency'].toString(),
          rateOfConversion: map['current_school_details_array']['currency_rate']['rate_of_conversion'].toString(),
          expression: map['current_school_details_array']['currency_rate']['expression'].toString(),
          currencyName: map['current_school_details_array']['currency_rate']['currency_name'].toString(),
          countryName: map['current_school_details_array']['currency_rate']['country_name'].toString(),
          countryAbr: map['current_school_details_array']['currency_rate']['country_abbr'].toString(),
          deleted: map['current_school_details_array']['currency_rate']['is_deleted'].toString()!='no',
        )
      ));
    }
  }

  @override
  Future<String> deleteFeesRecord(String recordId) async {
    // TODO: implement deleteFeesRecord
    String rtnData;
    try {
      final response = await http.get(
          MyStrings.domain + MyStrings.deleteParticularFeesRecordUrl +
              await getApiToken() + '/$recordId');
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      rtnData = map['success_message'];
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

  @override
  Future<String> restoreFeesRecord(String recordId) async {
    // TODO: implement undoDeleteFeesRecord
    String rtnData;
    try {
      final response = await http.get(
          MyStrings.domain + MyStrings.undoDeleteParticularFeesRecordUrl +
              await getApiToken() + '/$recordId');
      Map map = json.decode(response.body);
      print(map);


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      rtnData = map['success_message'];
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return rtnData;
  }

  @override
  Future<List<Students>> fetchFeesPayments({String apiToken, String recordId, String filter, String dateFrom, String dateTo}) async {
    // TODO: implement fetchFeesPayments
    try {
          final response = await http.get((filter=='All')
              ?MyStrings.domain + MyStrings.viewFeesPaymentsUrl + apiToken + '/$recordId'
              :(filter=='Outstanding')?MyStrings.domain + MyStrings.viewOutstandingFeesPaymentsUrl + apiToken + '/$recordId'
              :MyStrings.domain + MyStrings.viewFeesPaymentsByDateUrl + apiToken + '/$recordId/$dateFrom/$dateTo');


      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _students.clear();
      if (map["return_data"]['payment_details'].length < 1) {
        throw ApiException(
            "No Fees available, Please do well to add Some");
      }

      _populateFeesPaymentsLists(map["return_data"], map);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _students;
  }

  void _populateFeesPaymentsLists(Map result, Map map) {
    for (int i = 0; i < result['payment_details'].length; i++) {
      List<Fees> fees=List();
      for(var fee in result['payment_details'][i]['fees_details']){
        if(fee!=null){
          fees.add(Fees(
              id: fee['id'].toString(),
              uniqueId: fee['unique_id'].toString(),
              title: fee['title'].toString(),
              division: fee['division'].toString(),
              amount: fee['amount'].toString(),
              date: '${fee['created_at']
                  .toString()}, ${fee['updated_at'].toString()}',
              deleted: fee['is_deleted'].toString() != 'no',
              classId: fee['class_tb_id'].toString(),
              recordId: fee['fee_category_id'].toString(),
              feesRecord: new FeesRecord(
                  id: result['payment_details'][i]['fee_category']['id'].toString(),
                  uniqueId: result['payment_details'][i]['fee_category']['unique_id'].toString(),
                  title: result['payment_details'][i]['fee_category']['title'].toString(),
                  type: result['payment_details'][i]['fee_category']['fee_type'].toString(),
                  description: result['payment_details'][i]['fee_category']['description'].toString(),
                  date: '${result['payment_details'][i]['fee_category']['created_at'].toString()}, ${result['payment_details'][i]['fee_category']['updated_at'].toString()}',
                  sessionId: result['payment_details'][i]['fee_category']['session_i'].toString(),
                  termId: result['payment_details'][i]['fee_category']['term_id'].toString(),
                  deleted: result['payment_details'][i]['fee_category']['is_deleted'].toString() != 'no'
              )
          ));
        }
      }
      /*for (int j=0; j<result['payment_details'][i]['fees_details'].length; j++){

      }*/
      List<FeesPaymentDetail> feePaymentDetails=List();
      for (int k=0; k<result['payment_details'][i]['payment_details'].length; k++){
        feePaymentDetails.add(FeesPaymentDetail(
          id: result['payment_details'][i]['payment_details'][k]['id'].toString(),
          uniqueId: result['payment_details'][i]['payment_details'][k]['unique_id'].toString(),
          feeId: result['payment_details'][i]['payment_details'][k]['paid_fee_id'].toString(),
          amountPaid: result['payment_details'][i]['payment_details'][k]['amount_paid'].toString(),
          paymentOption:  result['payment_details'][i]['payment_details'][k]['payment_option'].toString(),
          paymentProof: result['payment_details'][i]['payment_details'][k]['payment_proof'].toString(),
          status: result['payment_details'][i]['payment_details'][k]['status'].toString(),
          deleted: result['payment_details'][i]['payment_details'][k]['is_deleted'].toString()!='no',
          paymentProofLink: ''
        ));
      }
      _students.add(new Students(
          id: result['payment_details'][i]['student_details']["id"].toString(),
          uniqueId: result['payment_details'][i]['student_details']["unique_id"].toString(),
          fName: result['payment_details'][i]['student_details']["firstname"].toString(),
          mName: result['payment_details'][i]['student_details']["othernames"].toString(),
          lName: result['payment_details'][i]['student_details']["lastname"].toString(),
          email: result['payment_details'][i]['student_details']["email"].toString(),
          phone: result['payment_details'][i]['student_details']["phone"].toString(),
          gender: result['payment_details'][i]['student_details']["sex"].toString(),
          passport: result['payment_details'][i]['student_details']["passport"].toString(),
          dob: result['payment_details'][i]['student_details']["birthday"].toString(),
          bloodGroup: result['payment_details'][i]['student_details']["blood_group"].toString(),
          genotype: result['payment_details'][i]['student_details']["genotype"].toString(),
          healthHistory: result['payment_details'][i]['student_details']["health_history"].toString(),
          admissionNumber: result['payment_details'][i]['student_details']
          ["addmission_number"].toString(),
          genAdmissionNumber: result['payment_details'][i]['student_details']
          ["gen_addmission_number"].toString(),
          residentAddress: result['payment_details'][i]['student_details']["resident_address"].toString(),
          city: result['payment_details'][i]['student_details']["city"].toString(),
          state: result['payment_details'][i]['student_details']["state"].toString(),
          nationality: result['payment_details'][i]['student_details']["nationality"].toString(),
          passportLink: result['student_passport_url'].toString(),
        sessions: Sessions(
          id: result['payment_details'][i]['student_details']["session"]['id'].toString(),
          uniqueId: result['payment_details'][i]['student_details']["session"]['unique_id'].toString(),
          sessionDate: result['payment_details'][i]['student_details']["session"]['session_date'].toString(),
          startAndEndDate: '${result['payment_details'][i]['student_details']["session"]['session_start_date'].toString()}, ${result['payment_details'][i]['student_details']["session"]['session_end_date'].toString()}',
          admissionNumberPrefix: result['payment_details'][i]['student_details']["session"]['admission_no_prefix'].toString(),
          status: result['payment_details'][i]['student_details']["session"]['status'].toString(),
        ),
        currency: Currency(
          id: result['payment_details'][i]['student_details']["currency_details"]['id'].toString(),
          uniqueId: result['payment_details'][i]['student_details']["currency_details"]['unique_id'].toString(),
          baseCurrency: result['payment_details'][i]['student_details']["currency_details"]['base_currency'].toString(),
          secondCurrency: result['payment_details'][i]['student_details']["currency_details"]['second_currency'].toString(),
          rateOfConversion: result['payment_details'][i]['student_details']["currency_details"]['rate_of_conversion'].toString(),
          expression: result['payment_details'][i]['student_details']["currency_details"]['expression'].toString(),
          countryName: result['payment_details'][i]['student_details']["currency_details"]['currency_name'].toString(),
          countryAbr: result['payment_details'][i]['student_details']["currency_details"]['country_abbr'].toString(),
          deleted: result['payment_details'][i]['student_details']["currency_details"]['is_deleted'].toString()!='no',
        ),
        feesPayment: FeesPayment(
            id: result['payment_details'][i]['id'].toString(),
            uniqueId: result['payment_details'][i]['unique_id'].toString(),
            studentId: result['payment_details'][i]['students_id'].toString(),
            recordId: result['payment_details'][i]['fee_category_id'].toString(),
            totalAmount: result['payment_details'][i]['total_amount'].toString(),
            amountPaid: result['payment_details'][i]['amount_paid'].toString(),
            balance: result['payment_details'][i]['balance'].toString(),
            status: result['payment_details'][i]['status'].toString(),
            deleted: result['payment_details'][i]['is_deleted'].toString() != 'no',
          fees: fees,
          paymentDetails: feePaymentDetails
        ),
        school: School(
         name: map['current_school_details_array']['name'].toString(),
          email: map['current_school_details_array']['contact_email'].toString(),
          phone: map['current_school_details_array']['contact_phone_number'].toString(),
            preferredCurrencyId: map['current_school_details_array']['prefered_currency'].toString(),
          currency: Currency(
            id: map['current_school_details_array']['currency_rate']['id'].toString(),
            uniqueId: map['current_school_details_array']['currency_rate']['unique_id'].toString(),
            baseCurrency: map['current_school_details_array']['currency_rate']['base_currency'].toString(),
            secondCurrency: map['current_school_details_array']['currency_rate']['second_currency'].toString(),
            rateOfConversion: map['current_school_details_array']['currency_rate']['rate_of_conversion'].toString(),
            expression: map['current_school_details_array']['currency_rate']['expression'].toString(),
            currencyName: map['current_school_details_array']['currency_rate']['currency_name'].toString(),
            countryName: map['current_school_details_array']['currency_rate']['country_name'].toString(),
            countryAbr: map['current_school_details_array']['currency_rate']['country_abbr'].toString(),
            deleted: map['current_school_details_array']['currency_rate']['is_deleted'].toString()!='no',
          )
        )
      ));
    }
  }

  @override
  Future<List<Students>> fetchStudentFees({String apiToken, String studentId}) async{
    // TODO: implement fetchStudentFees
    try {
      print(MyStrings.domain + MyStrings.viewStudentFeesUrl + apiToken + '/$studentId');
      final response = await http.get(MyStrings.domain + MyStrings.viewStudentFeesUrl + apiToken + '/$studentId');

      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _students.clear();
      if (map["return_data"].length < 1) {
        throw ApiException(
            "No Fees available");
      }

      _populateStudentFeesLists(map["return_data"], map);
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return _students;
  }

  void _populateStudentFeesLists(List result, Map map) {
    for (int i = 0; i < result.length; i++) {
      List<Fees> fees=List();
      for (int j=0; j<result[i]['fees_details'].length; j++){
        fees.add(Fees(
            id: result[i]['fees_details'][j]['id'].toString(),
            uniqueId: result[i]['fees_details'][j]['unique_id'].toString(),
            title: result[i]['fees_details'][j]['title'].toString(),
            division: result[i]['fees_details'][j]['division'].toString(),
            amount: result[i]['fees_details'][j]['amount'].toString(),
            date: '${result[i]['fees_details'][j]['created_at']
                .toString()}, ${result[i]['fees_details'][j]['updated_at'].toString()}',
            deleted: result[i]['fees_details'][j]['is_deleted'].toString() != 'no',
            classId: result[i]['fees_details'][j]['class_tb_id'].toString(),
            recordId: result[i]['fees_details'][j]['fee_category_id'].toString(),
            feesRecord: new FeesRecord(
                id: result[i]['fee_category']['id'].toString(),
                uniqueId: result[i]['fee_category']['unique_id'].toString(),
                title: result[i]['fee_category']['title'].toString(),
                type: result[i]['fee_category']['fee_type'].toString(),
                description: result[i]['fee_category']['description'].toString(),
                date: '${result[i]['fee_category']['created_at'].toString()}, ${result[i]['fee_category']['updated_at'].toString()}',
                sessionId: result[i]['fee_category']['session_i'].toString(),
                termId: result[i]['fee_category']['term_id'].toString(),
                deleted: result[i]['fee_category']['is_deleted'].toString() != 'no'
            )
        ));
      }
      List<FeesPaymentDetail> feePaymentDetails=List();
      for (int k=0; k<result[i]['payment_details'].length; k++){
        feePaymentDetails.add(FeesPaymentDetail(
            id: result[i]['payment_details'][k]['id'].toString(),
            uniqueId: result[i]['payment_details'][k]['unique_id'].toString(),
            feeId: result[i]['payment_details'][k]['paid_fee_id'].toString(),
            amountPaid: result[i]['payment_details'][k]['amount_paid'].toString(),
            paymentOption:  result[i]['payment_details'][k]['payment_option'].toString(),
            paymentProof: result[i]['payment_details'][k]['payment_proof'].toString(),
            status: result[i]['payment_details'][k]['status'].toString(),
            deleted: result[i]['payment_details'][k]['is_deleted'].toString()!='no',
            paymentProofLink: ''
        ));
      }
      _students.add(new Students(
          id: result[i]['student_details']["id"].toString(),
          uniqueId: result[i]['student_details']["unique_id"].toString(),
          fName: result[i]['student_details']["firstname"].toString(),
          mName: result[i]['student_details']["othernames"].toString(),
          lName: result[i]['student_details']["lastname"].toString(),
          email: result[i]['student_details']["email"].toString(),
          phone: result[i]['student_details']["phone"].toString(),
          gender: result[i]['student_details']["sex"].toString(),
          passport: result[i]['student_details']["passport"].toString(),
          dob: result[i]['student_details']["birthday"].toString(),
          bloodGroup: result[i]['student_details']["blood_group"].toString(),
          genotype: result[i]['student_details']["genotype"].toString(),
          healthHistory: result[i]['student_details']["health_history"].toString(),
          admissionNumber: result[i]['student_details']["addmission_number"].toString(),
          genAdmissionNumber: result[i]['student_details']["gen_addmission_number"].toString(),
          residentAddress: result[i]['student_details']["resident_address"].toString(),
          city: result[i]['student_details']["city"].toString(),
          state: result[i]['student_details']["state"].toString(),
          nationality: result[i]['student_details']["nationality"].toString(),
          passportLink: '',
          sessions: Sessions(
            id: result[i]['student_details']["session"]['id'].toString(),
            uniqueId: result[i]['student_details']["session"]['unique_id'].toString(),
            sessionDate: result[i]['student_details']["session"]['session_date'].toString(),
            startAndEndDate: '${result[i]['student_details']["session"]['session_start_date'].toString()}, ${result[i]['student_details']["session"]['session_end_date'].toString()}',
            admissionNumberPrefix: result[i]['student_details']["session"]['admission_no_prefix'].toString(),
            status: result[i]['student_details']["session"]['status'].toString(),
          ),
          currency: Currency(
            id: result[i]['student_details']["currency_details"]['id'].toString(),
            uniqueId: result[i]['student_details']["currency_details"]['unique_id'].toString(),
            baseCurrency: result[i]['student_details']["currency_details"]['base_currency'].toString(),
            secondCurrency: result[i]['student_details']["currency_details"]['second_currency'].toString(),
            rateOfConversion: result[i]['student_details']["currency_details"]['rate_of_conversion'].toString(),
            expression: result[i]['student_details']["currency_details"]['expression'].toString(),
            countryName: result[i]['student_details']["currency_details"]['currency_name'].toString(),
            countryAbr: result[i]['student_details']["currency_details"]['country_abbr'].toString(),
            deleted: result[i]['student_details']["currency_details"]['is_deleted'].toString()!='no',
          ),
          feesPayment: FeesPayment(
              id: result[i]['id'].toString(),
              uniqueId: result[i]['unique_id'].toString(),
              studentId: result[i]['students_id'].toString(),
              recordId: result[i]['fee_category_id'].toString(),
              totalAmount: result[i]['total_amount'].toString(),
              amountPaid: result[i]['amount_paid'].toString(),
              balance: result[i]['balance'].toString(),
              status: result[i]['status'].toString(),
              deleted: result[i]['is_deleted'].toString() != 'no',
              fees: fees,
              paymentDetails: feePaymentDetails
          ),
          school: School(
              name: map['current_school_details_array']['name'].toString(),
              email: map['current_school_details_array']['contact_email'].toString(),
              phone: map['current_school_details_array']['contact_phone_number'].toString(),
              preferredCurrencyId: map['current_school_details_array']['prefered_currency'].toString(),
              currency: Currency(
                id: map['current_school_details_array']['currency_rate']['id'].toString(),
                uniqueId: map['current_school_details_array']['currency_rate']['unique_id'].toString(),
                baseCurrency: map['current_school_details_array']['currency_rate']['base_currency'].toString(),
                secondCurrency: map['current_school_details_array']['currency_rate']['second_currency'].toString(),
                rateOfConversion: map['current_school_details_array']['currency_rate']['rate_of_conversion'].toString(),
                expression: map['current_school_details_array']['currency_rate']['expression'].toString(),
                currencyName: map['current_school_details_array']['currency_rate']['currency_name'].toString(),
                countryName: map['current_school_details_array']['currency_rate']['country_name'].toString(),
                countryAbr: map['current_school_details_array']['currency_rate']['country_abbr'].toString(),
                deleted: map['current_school_details_array']['currency_rate']['is_deleted'].toString()!='no',
              )
          )
      ));
    }
  }
}

