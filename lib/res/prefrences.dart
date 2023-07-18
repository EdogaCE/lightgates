import 'package:school_pal/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

saveLoginDetailsToSF(bool loggedIn, String id, String uniqueId, String username, String phone, String email,
    String address, String apiToken, String userChatId, String userChatType, String loggedInAs,
    bool verificationStatus, String videoForVerification, bool firstTimeLogin) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('LOGGED_IN', loggedIn);
  prefs.setString('ID', id);
  prefs.setString('UNIQUE_ID', uniqueId);
  prefs.setString('USERNAME', username);
  prefs.setString('CONTACT_PHONE', phone);
  prefs.setString('CONTACT_EMAIL', email);
  prefs.setString('ADDRESS', address);
  prefs.setString('API_TOKEN', apiToken);
  prefs.setString('LOGGED_IN_AS', loggedInAs);
  prefs.setString('USER_CHAT_ID', userChatId);
  prefs.setString('USER_CHAT_TYPE', userChatType);
  prefs.setBool('VERIFICATION_STATUS', verificationStatus);
  prefs.setString('VIDEO_FOR_VERIFICATION', videoForVerification);
  prefs.setBool('FIRST_TIME_LOGIN', firstTimeLogin);
}

saveStudentDashboardDetailsToSF({String assessmentsCount, String learningMaterialsCount, String eventsCount, String pendingFees, String studentClass, String currency}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ASSESSMENTS_COUNT', assessmentsCount);
  prefs.setString('LEARNING_MATERIALS_COUNT', learningMaterialsCount);
  prefs.setString('EVENTS_COUNT', eventsCount);
  prefs.setString('PENDING_FEES', pendingFees);
  prefs.setString('STUDENT_CLASS', studentClass);
  prefs.setString('CURRENCY', currency);
}

saveTeacherDashboardDetailsToSF({String assessmentsCount, String learningMaterialsCount, String pendingResultsCount, String confirmedResultsCount, String numberOfClassTeaching, String numberOfClassForming, bool formTeacher, String commentSwitch, String currency}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ASSESSMENTS_COUNT', assessmentsCount);
  prefs.setString('LEARNING_MATERIALS_COUNT', learningMaterialsCount);
  prefs.setString('PENDING_RESULTS_COUNT', pendingResultsCount);
  prefs.setString('CONFIRMED_RESULTS_COUNT', confirmedResultsCount);
  prefs.setString('NUMBER_OF_CLASS_TEACHING', numberOfClassTeaching);
  prefs.setString('NUMBER_OF_CLASS_FORMING', numberOfClassForming);
  prefs.setBool('FORM_TEACHER', formTeacher);
  prefs.setString('RESULT_COMMENT_SWITCH', commentSwitch);
  prefs.setString('CURRENCY', currency);
}

saveSchoolDashboardDetailsToSF({String numberOfStudents, String numberOfTeachers, String numberOfSubjects, String pendingFees, String confirmedFees, String currency}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('NUMBER_OF_STUDENTS', numberOfStudents);
  prefs.setString('NUMBER_OF_TEACHERS', numberOfTeachers);
  prefs.setString('NUMBER_OF_SUBJECTS', numberOfSubjects);
  prefs.setString('PENDING_FEES', pendingFees);
  prefs.setString('CONFIRMED_FEES', confirmedFees);
  prefs.setString('CURRENCY', currency);
}

saveFirebaseTokenToSF(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('FIREBASE_TOKEN', token);
}

saveFirstTimeSetupPageToSF(String page) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('FIRST_TIME_SETUP_PAGE', page);
}

updateFirstTimeLogin(bool firstTimeLogin) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('FIRST_TIME_LOGIN', firstTimeLogin);
}

saveLaunchesToSF(int launches) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('LAUNCHES', launches);
}

saveDoNotOpenAgainToSF(bool doNotOpenAgain) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('DO_NOT_OPEN_AGAIN', doNotOpenAgain);
}

doNotOpenAgain() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool doNotOpenAgain = prefs.getBool('DO_NOT_OPEN_AGAIN') ?? false;
  return doNotOpenAgain;
}

launches() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int launches = prefs.getInt('LAUNCHES') ?? 0;
  return launches;
}

isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Check if logged-in
  bool loggedIn = prefs.getBool('LOGGED_IN') ?? false;
  return loggedIn;
}

getApiToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Get api token of who logged-in
  String apiToken = prefs.getString('API_TOKEN') ?? " ";
  return apiToken;
}

getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Get api token of who logged-in
  String id = prefs.getString('ID') ?? " ";
  return id;
}

getLoggedInAs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Get who logged-in
  String loggedInAs = prefs.getString('LOGGED_IN_AS') ?? " ";
  return loggedInAs;
}

getStudentClass() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String studClass = prefs.getString('STUDENT_CLASS') ?? " ";
  return studClass;
}

getUserCurrency() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String currency = prefs.getString('CURRENCY') ?? " ";
  return currency;
}

getResultCommentSwitch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String commentSwitch = prefs.getString('RESULT_COMMENT_SWITCH') ?? " ";
  return commentSwitch;
}

getFirebaseToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String fcmToken = prefs.getString('FIREBASE_TOKEN') ?? " ";
  return fcmToken;
}

getFirstTimeSetupPage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String page = prefs.getString('FIRST_TIME_SETUP_PAGE') ?? " ";
  return page;
}

retrieveLoginDetailsFromSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return logged-in values
  String id = prefs.getString('ID') ?? " ";
  String uniqueId = prefs.getString('UNIQUE_ID') ?? " ";
  String username = prefs.getString('USERNAME') ?? " ";
  String email = prefs.getString('CONTACT_EMAIL') ?? " ";
  String phone = prefs.getString('CONTACT_PHONE') ?? " ";
  String address = prefs.getString('ADDRESS') ?? " , , , , ";
  String apiToken = prefs.getString('API_TOKEN') ?? " ";
  bool formTeacher = prefs.getBool('FORM_TEACHER') ?? false;
  String userChatId = prefs.getString('USER_CHAT_ID') ?? " ";
  String userChatType = prefs.getString('USER_CHAT_TYPE') ?? " ";
  String assessmentsCount= prefs.getString('ASSESSMENTS_COUNT') ?? "0";
  String learningMaterialsCount= prefs.getString('LEARNING_MATERIALS_COUNT') ?? "0";
  String eventsCount= prefs.getString('EVENTS_COUNT') ?? "0";
  String pendingFees= prefs.getString('PENDING_FEES') ?? "0";
  final String pendingResultsCount= prefs.getString('PENDING_RESULTS_COUNT') ?? "0";
  final String confirmedResultsCount= prefs.getString('CONFIRMED_RESULTS_COUNT') ?? "0";
  final String numberOfClassTeaching= prefs.getString('NUMBER_OF_CLASS_TEACHING') ?? "0";
  final String numberOfClassForming= prefs.getString('NUMBER_OF_CLASS_FORMING') ?? "0";
  final String numberOfStudents= prefs.getString('NUMBER_OF_STUDENTS') ?? "0";
  final String numberOfTeachers= prefs.getString('NUMBER_OF_TEACHERS') ?? "0";
  final String numberOfSubjects= prefs.getString('NUMBER_OF_SUBJECTS') ?? "0";
  final String confirmedFees= prefs.getString('CONFIRMED_FEES') ?? "0";
  final bool verificationStatus = prefs.getBool('VERIFICATION_STATUS') ?? false;
  final String videoForVerification = prefs.getString('VIDEO_FOR_VERIFICATION') ?? " ";
  final bool firstTimeLogin = prefs.getBool('FIRST_TIME_LOGIN') ?? false;
  return User(
    logoName: '',
    appName: '',
    id: id,
    uniqueId: uniqueId,
    userName: username,
    contactEmail: email,
    contactPhone: phone,
    address: address.split(',')[0],
    town: address.split(',')[1],
    lga: address.split(',')[2],
    city: address.split(',')[3],
    nationality: address.split(',')[4],
    image: '',
    apiToken: apiToken,
    isFormTeacher: formTeacher,
    userChatId: userChatId,
    userChatType: userChatType,
    assessmentsCount: assessmentsCount,
    learningMaterialsCount: learningMaterialsCount,
    eventsCount: eventsCount,
    pendingFees: pendingFees,
    confirmedFees: confirmedFees,
    numberOfSubjects: numberOfSubjects,
    numberOfTeachers: numberOfTeachers,
    numberOfStudents: numberOfStudents,
    numberOfClassForming: numberOfClassForming,
    numberOfClassTeaching: numberOfClassTeaching,
    confirmedResultsCount: confirmedResultsCount,
    pendingResultsCount: pendingResultsCount,
    videoForVerification: videoForVerification,
    verificationStatus: verificationStatus,
    firstTimeLogin: firstTimeLogin
  );
}

clearLoginDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("LOGGED_IN");
  prefs.remove("USERNAME");
  prefs.remove("CONTACT_EMAIL");
  prefs.remove("ADDRESS");
  prefs.remove("API_TOKEN");
  prefs.remove("ID");
  prefs.remove("CONTACT_PHONE");
  prefs.remove("LOGGED_IN_AS");
  prefs.remove("STUDENT_CLASS");
  prefs.remove("CURRENCY");
  prefs.remove('FORM_TEACHER');
  prefs.remove('RESULT_COMMENT_SWITCH');
  prefs.remove("USER_CHAT_ID");
  prefs.remove("USER_CHAT_TYPE");
  prefs.remove("ASSESSMENTS_COUNT");
  prefs.remove("LEARNING_MATERIALS_COUNT");
  prefs.remove("EVENTS_COUNT");
  prefs.remove("PENDING_FEES");
  prefs.remove("FIREBASE_TOKEN");
  prefs.remove("PENDING_RESULTS_COUNT");
  prefs.remove("CONFIRMED_RESULTS_COUNT");
  prefs.remove("NUMBER_OF_CLASS_TEACHING");
  prefs.remove("NUMBER_OF_CLASS_FORMING");
  prefs.remove("NUMBER_OF_STUDENTS");
  prefs.remove("NUMBER_OF_TEACHERS");
  prefs.remove("NUMBER_OF_SUBJECTS");
  prefs.remove("PENDING_FEES");
  prefs.remove("CONFIRMED_FEES");
  prefs.remove("FIRST_TIME_SETUP_PAGE");
  prefs.remove('UNIQUE_ID');
}
