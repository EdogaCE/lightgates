import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sub_account.dart';
import 'package:school_pal/models/wallet_record.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewWalletRepository{
  Future<List<School>> fetchTransactionHistories();
  Future<String> fetchTransactionHistory({String transactionId});
  Future<SubAccount> fetchFlutterWaveSubAccount();
  Future<SubAccount> fetchPayStackSubAccount();
}

class ViewWalletRequest implements ViewWalletRepository{
  List<School> _schools=new List();
  @override
  Future<List<School>> fetchTransactionHistories() async{
    // TODO: implement fetchWalletFoundHistory
    //print(MyStrings.domain+MyStrings.viewWalletFoundHistoryUrl+await getApiToken());
    try {
      final response = await http.get(MyStrings.domain+MyStrings.viewWalletFoundHistoryUrl+await getApiToken());
      Map map = json.decode(response.body);
      logPrint(map.toString());


      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      _schools.clear();
      List result=map["return_data"];
      if (result.length<1) {
        throw ApiException("No Fund history available");
      }
      _populateLists(result);

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _schools;
  }

  void _populateLists(List result){
    for(int i=0; i<result.length; i++ ){
      _schools.add(School(
        walletRecord: WalletRecord(
          id: result[i]['id'].toString(),
          uniqueId: result[i]['unique_id'].toString(),
          amount: result[i]['amount'].toString(),
          description: result[i]['description'].toString(),
          actionType: result[i]['action_type'].toString(),
          status: result[i]['status'].toString(),
          reference: result[i]['reference'].toString(),
          billPayment: result[i]['is_bill_or_airtime'].toString()=='yes',
          deleted: result[i]['is_deleted'].toString()!='no'
        ),
        id: result[i]['mainUserDetails']['id'].toString(),
        uniqueId: result[i]['mainUserDetails']['unique_id'].toString(),
        name: (result[i]['mainUserDetails']['type_of_user'].toString()=='admin')?result[i]['mainUserDetails']['name'].toString()
          :'${result[i]['mainUserDetails']['firstname'].toString()} ${result[i]['mainUserDetails']['lastname'].toString()}',
        email: (result[i]['mainUserDetails']['type_of_user'].toString()=='admin')?result[i]['mainUserDetails']['contact_email'].toString()
          :result[i]['mainUserDetails']['email'].toString(),
        phone: (result[i]['mainUserDetails']['type_of_user'].toString()=='admin')?result[i]['mainUserDetails']['contact_phone_number'].toString()
            :result[i]['mainUserDetails']['phone'].toString(),
        walletBalance: result[i]['mainUserDetails']['balance'].toString(),
        developerCharge: result[i]['mainUserDetails']['developer_charge'].toString(),
        preferredCurrencyId: result[i]['mainUserDetails']['prefered_currency'].toString(),
        currency: Currency(
          id: result[i]['mainUserDetails']['currency_rate']['id'].toString(),
          uniqueId: result[i]['mainUserDetails']['currency_rate']['unique_id'].toString(),
          baseCurrency: result[i]['mainUserDetails']['currency_rate']['base_currency'].toString(),
          secondCurrency: result[i]['mainUserDetails']['currency_rate']['second_currency'].toString(),
          rateOfConversion: result[i]['mainUserDetails']['currency_rate']['rate_of_conversion'].toString(),
          expression: result[i]['mainUserDetails']['currency_rate']['expression'].toString(),
          currencyName: result[i]['mainUserDetails']['currency_rate']['currency_name'].toString(),
          countryName: result[i]['mainUserDetails']['currency_rate']['country_name'].toString(),
          countryAbr: result[i]['mainUserDetails']['currency_rate']['country_abbr'].toString(),
          deleted: result[i]['mainUserDetails']['currency_rate']['is_deleted'].toString()!='no',
        )
      ));
    }
  }

  @override
  Future<String> fetchTransactionHistory({String transactionId}) async{
    // TODO: implement fetchTransactionHistory
    String _message;
    try {
      final response = await http.get('${MyStrings.domain+MyStrings.topUpDetailsUrl+await getApiToken()}/$transactionId/save');
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _message = map['return_data']['download_link'];

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _message;
  }

  @override
  Future<SubAccount> fetchFlutterWaveSubAccount() async{
    // TODO: implement fetchFlutterWaveSubAccount
    SubAccount _subAccount;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.flutterWaveSubAccountUrl+await getApiToken());
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _subAccount = SubAccount(
          id: map['return_data']['id'].toString(),
          accountBank: map['return_data']['account_bank']??'',
          accountNumber: map['return_data']['account_number']??'',
          bankName: map['return_data']['bank_name']??'',
          businessName: map['return_data']['business_name']??'',
          country: map['return_data']['country']??'',
          fullName: map['return_data']['full_name']??'',
          address: '',
          email: '',
          phoneOne: '',
          phoneTwo: ''
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _subAccount;
  }

  @override
  Future<SubAccount> fetchPayStackSubAccount() async{
    // TODO: implement fetchPayStackSubAccount
    SubAccount _subAccount;
    try {
      final response = await http.get(MyStrings.domain+MyStrings.payStackSubAccountUrl+await getApiToken());
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString() != 'true') {
        throw ApiException(
            handelServerError(response: map));
      }
      _subAccount = SubAccount(
          id: map['return_data']['id'].toString(),
          accountBank: map['return_data']['bank']??'',
          accountNumber: map['return_data']['account_number']??'',
          bankName: map['return_data']['settlement_bank']??'',
          businessName: map['return_data']['business_name']??'',
          country: map['return_data']['currency']??'',
          fullName: map['return_data']['business_name']??''
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _subAccount;
  }

}
