import 'package:meta/meta.dart';
import 'package:school_pal/res/prefrences.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/utils/system.dart';

abstract class BillPaymentRepository {
  Future<String> makePayment({@required String customer, @required String amount, @required String billCategoryKey});
}

class BillPaymentRequests implements BillPaymentRepository{

  @override
  Future<String> makePayment({String customer, String amount, String billCategoryKey}) async {
    String _successMessage;
    try {
      await http.post(MyStrings.domain + MyStrings.billPaymentUrl+await getApiToken(), body: {
        "customer": customer,
        "amount": amount,
        "bill_category_key": billCategoryKey
      }).then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        Map map = json.decode(response.body);
        if (map["status"].toString() != 'true') {
          throw ApiException(
              handelServerError(response: map));
        }

        _successMessage=map['success_message'];

      });
    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      print(e.toString());
      throw SystemError();
    }

    return _successMessage;
  }


}


