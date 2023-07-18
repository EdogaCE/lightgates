import 'package:url_launcher/url_launcher.dart';


class LaunchRequest{

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchCaller(String phoneNumber) async {
    String url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchWhasapp(int phoneNumber) async {
    String whatsappUrl = "whatsapp://send?phone=$phoneNumber";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
    }

  launchMessage(String phoneNumber) async {
    // Android
   // const uri = 'sms:+39 348 060 888?body=hello%20there';
    String uri = 'sms:$phoneNumber?body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      //const uri = 'sms:0039-222-060-888';
       uri = 'sms:$phoneNumber';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }
}