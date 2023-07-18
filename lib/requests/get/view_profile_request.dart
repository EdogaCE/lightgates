import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:school_pal/models/classes.dart';
import 'package:school_pal/models/currency.dart';
import 'package:school_pal/models/developer.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/sessions.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/subjects.dart';
import 'package:school_pal/models/teachers.dart';
import 'package:school_pal/models/terms.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/utils/system.dart';

abstract class ViewProfileRepository {
  Future<Developer> fetchDeveloperProfile(String apiToken);
  Future<School> fetchSchoolProfile(String apiToken);
  Future<Teachers> fetchTeacherProfile(String apiToken, String teacherId);
  Future<Students> fetchStudentProfile(String apiToken, String studentId);
}

class ViewProfileRequest implements ViewProfileRepository {
  @override
  Future<Developer> fetchDeveloperProfile(String apiToken) async{
    // TODO: implement fetchDeveloperProfile
    Developer developer;
    try {
      final response = await http
          .get(MyStrings.domain + MyStrings.viewDeveloperProfileUrl + apiToken);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString()!= 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map developerDetails = map['return_data'];
      developer=Developer(
          id: developerDetails['id'].toString().replaceAll('null', ''),
          uniqueId: developerDetails['unique_id'].toString().replaceAll('null', ''),
          siteName: developerDetails['site_name'].toString().replaceAll('null', ''),
          frontEndBaseUrl: developerDetails['front_end_base_url'].toString().replaceAll('null', ''),
          backEndBaseUrl: developerDetails['backend_base_url'].toString().replaceAll('null', ''),
          loginUrl: developerDetails['login_url'].toString().replaceAll('null', ''),
          registerUrl: developerDetails['register_url'].toString().replaceAll('null', ''),
          phone1: developerDetails['phone_number'].toString().replaceAll('null', ''),
          phone2: developerDetails['phone_number_2'].toString().replaceAll('null', ''),
          emailAddress1: developerDetails['email_address'].toString().replaceAll('null', ''),
          emailAddress2: developerDetails['email_address_2'].toString().replaceAll('null', ''),
          address1: developerDetails['address_1'].toString().replaceAll('null', ''),
          address2: developerDetails['address_2'].toString().replaceAll('null', ''),
          facebook: developerDetails['face_book'].toString().replaceAll('null', ''),
          instagram: developerDetails['instagram'].toString().replaceAll('null', ''),
          twitter: developerDetails['twitter'].toString().replaceAll('null', ''),
          deleted: developerDetails['is_deleted'].toString().replaceAll('null', '')=='yes'
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return developer;
  }

  @override
  Future<School> fetchSchoolProfile(String apiToken) async {
    School school;
    try {
      print(MyStrings.domain + MyStrings.viewSchoolProfileUrl + apiToken);
      final response = await http.get(MyStrings.domain + MyStrings.viewSchoolProfileUrl + apiToken);
      Map map = json.decode(response.body);
      logPrint(map.toString());

      if (map["status"].toString()!= 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map schoolDetails = map['return_data']['single_school_detail'];
      school=School(
          id: schoolDetails['id'].toString().replaceAll('null', '').replaceAll('null', ''),
          uniqueId: schoolDetails['unique_id'].toString().replaceAll('null', ''),
          userName: schoolDetails['username'].toString().replaceAll('null', ''),
          password: schoolDetails['password'].toString().replaceAll('null', ''),
          name: schoolDetails['name'].toString().replaceAll('null', ''),
          email: schoolDetails['contact_email'].toString().replaceAll('null', ''),
          phone: schoolDetails['contact_phone_number'].toString().replaceAll('null', ''),
          address: schoolDetails['address'].toString().replaceAll('null', ''),
          town: schoolDetails['town'].toString().replaceAll('null', ''),
          lga: schoolDetails['lga'].toString().replaceAll('null', ''),
          city: schoolDetails['state'].toString().replaceAll('null', ''),
          nationality: schoolDetails['nationality'].toString().replaceAll('null', ''),
          slogan: schoolDetails['slogan'].toString().replaceAll('null', ''),
          status: schoolDetails['verification_status'].toString().replaceAll('null', ''),
          image: schoolDetails['image'].toString().replaceAll('null', ''),
          cacFile: schoolDetails['cac_file'].toString().replaceAll('null', ''),
          otherFile: schoolDetails['otherfile'].toString().replaceAll('null', ''),
          poBox: schoolDetails['p_o_box'].toString().replaceAll('null', ''),
          website: schoolDetails['school_website'].toString().replaceAll('null', ''),
          facebook: schoolDetails['facebook'].toString().replaceAll('null', ''),
          instagram: schoolDetails['instagram'].toString().replaceAll('null', ''),
          twitter: schoolDetails['twitter'].toString().replaceAll('null', ''),
          imageLink: map['return_data']['school_logo_path'].toString().replaceAll('null', ''),
          activeSession: (map['active_session'].isNotEmpty)?map['active_session']['session_date'].toString().replaceAll('null', ''):'',
          activeTerm: (map['active_term'].isNotEmpty)?map['active_term']['term'].toString().replaceAll('null', ''):'',
          preferredCurrencyId: schoolDetails['prefered_currency'].toString().replaceAll('null', ''),
          currency: Currency(
            id: schoolDetails['currency_rate']['id'].toString().replaceAll('null', ''),
            uniqueId: schoolDetails['currency_rate']['unique_id'].toString().replaceAll('null', ''),
            baseCurrency: schoolDetails['currency_rate']['base_currency'].toString().replaceAll('null', ''),
            secondCurrency: schoolDetails['currency_rate']['second_currency'].toString().replaceAll('null', ''),
            rateOfConversion: schoolDetails['currency_rate']['rate_of_conversion'].toString().replaceAll('null', ''),
            expression: schoolDetails['currency_rate']['expression'].toString().replaceAll('null', ''),
            currencyName: schoolDetails['currency_rate']['currency_name'].toString().replaceAll('null', ''),
            countryName: schoolDetails['currency_rate']['country_name'].toString().replaceAll('null', ''),
            countryAbr: schoolDetails['currency_rate']['country_abbr'].toString().replaceAll('null', ''),
            deleted: schoolDetails['currency_rate']['is_deleted'].toString().replaceAll('null', '')!='no',
          ),
          developerCharge: schoolDetails['developer_charge'].toString().replaceAll('null', ''),
          resultCommentSwitch: schoolDetails['result_comment_switch'].toString().replaceAll('null', ''),
          keyToTraitRating: schoolDetails['key_to_trait_rating'].toString().replaceAll('null', ''),
          numOfTerm: schoolDetails['no_of_terms'].toString().replaceAll('null', ''),
          numOfCumulativeTest: schoolDetails['no_of_cumulative_test'].toString().replaceAll('null', '0'),
          admissionNumPrefix: schoolDetails['admission_no_prefix'].toString().replaceAll('null', ''),
          initialAdmissionNum: schoolDetails['initial_admission_no'].toString().replaceAll('null', ''),
          testExamScoreLimit: schoolDetails['test_exam_score_limit'].toString().replaceAll('null', ''),
          behaviouralSkillTestsHeadings: schoolDetails['behavioural_skill_tests_headings'].toString().replaceAll('null', ''),
          useCumulativeResult: schoolDetails['use_of_cummulative_result'].toString().replaceAll('null', '')=='yes',
          useCustomAdmissionNum: schoolDetails['use_of_custom_admission_number'].toString().replaceAll('null', '')=='yes',
          useClassCategoryStatus: schoolDetails['class_category_status'].toString().replaceAll('null', '')=='yes',
          useOfSignatureOnResults: schoolDetails['use_of_signature_on_results'].toString().replaceAll('null', '')=='yes',
          userChatId: schoolDetails['sender_id_for_chat'].toString().replaceAll('null', ''),
          userChatType: schoolDetails['type_of_user_for_chat'].toString().replaceAll('null', ''),
          pendingFees: schoolDetails['dashboard_details']['confirmed_payment_array']['confirmed_balance'].toString().replaceAll('null', '0'),
          confirmedFees: schoolDetails['dashboard_details']['confirmed_payment_array']['confirmed_amount_paid'].toString().replaceAll('null', '0'),
          numberOfStudents: schoolDetails['dashboard_details']['all_students_array']['count_students'].toString().replaceAll('null', '0'),
          numberOfTeachers: schoolDetails['dashboard_details']['all_teachers_array']['count_teachers'].toString().replaceAll('null', '0'),
          numberOfSubjects: schoolDetails['dashboard_details']['all_subjects_array']['count_subjects'].toString().replaceAll('null', '0'),
          deleted: schoolDetails['is_deleted'].toString().replaceAll('null', '')=='yes'
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return school;
  }

  @override
  Future<Teachers> fetchTeacherProfile(
      String apiToken, String teacherId) async {
    // TODO: implement fetchTeacherProfile
    print(MyStrings.domain +
        MyStrings.viewTeacherProfileUrl +
        apiToken +
        "/" +
        teacherId);
    Teachers teachers;
    List<String> _subjects=List();
    List<String> _classes=List();
    List<Subjects> _subjectsDetail=List();
    List<Classes> _classesDetail=List();
    List<Classes> _formClasses=List();
    List<Terms> _formTerms=List();
    List<Sessions> _formSessions=List();
    try {
      final response = await http.get(MyStrings.domain +
          MyStrings.viewTeacherProfileUrl +
          apiToken +
          "/" +
          teacherId);
      Map map = json.decode(response.body);
      logPrint(map.toString());

      if (map["status"].toString()!= 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map teacherDetails = map['return_data']['teacher_details'];
      try{
        if (teacherDetails['formTeacherDetailsArray'].isNotEmpty) {
          for (var clas in teacherDetails['formTeacherDetailsArray']) {
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

      try{
        List teacherSub = map['return_data']["subject_details_array"];
        List teacherClass = map['return_data']["all_class_details_array"];
        if (teacherSub.isNotEmpty && teacherClass.isNotEmpty) {
          for (var subject in teacherSub) {
            _subjects.add(subject["title"].toString());
            _subjectsDetail.add(Subjects(
                id: subject["id"].toString().replaceAll('null', ''),
                uniqueId: subject["unique_id"].toString().replaceAll('null', ''),
                title: subject["title"].toString().replaceAll('null', ''),
                status: subject["status"].toString().replaceAll('null', '')
            ));
          }
          for (var clas in teacherClass) {
            _classes.add('${clas["class_label_details"]["label"].toString().replaceAll('null', '')} '
                '${clas["class_category_details"]["category"].toString().replaceAll('null', '')}');
            _classesDetail.add(Classes(
                id: clas["class_details_array"]["id"].toString().replaceAll('null', ''),
                uniqueId: clas["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
                status: clas["class_details_array"]["status"].toString().replaceAll('null', ''),
                category:clas["class_category_details"]["category"].toString().replaceAll('null', ''),
                label: clas["class_label_details"]["label"].toString().replaceAll('null', ''),
                level: clas["class_level_details"]["level"].toString().replaceAll('null', '')
            ));
          }
        }
      }on NoSuchMethodError{}

      teachers=Teachers(
          id: teacherDetails['id'].toString().replaceAll('null', ''),
          uniqueId: teacherDetails['unique_id'].toString().replaceAll('null', ''),
          role: teacherDetails['role'].toString().replaceAll('null', ''),
          title: teacherDetails['title'].toString().replaceAll('null', ''),
          fName: teacherDetails['firstname'].toString().replaceAll('null', ''),
          mName: teacherDetails['othernames'].toString().replaceAll('null', ''),
          lName: teacherDetails['lastname'].toString().replaceAll('null', ''),
          userName: teacherDetails['username'].toString().replaceAll('null', ''),
          password: teacherDetails['password'].toString().replaceAll('null', ''),
          gender: teacherDetails['sex'].toString().replaceAll('null', ''),
          phone: teacherDetails['phone'].toString().replaceAll('null', ''),
          email: teacherDetails['email'].toString().replaceAll('null', ''),
          passport: teacherDetails['passport'].toString().replaceAll('null', ''),
          address: teacherDetails['contact_address'].toString().replaceAll('null', ''),
          city: teacherDetails['city'].toString().replaceAll('null', ''),
          state: teacherDetails['state'].toString().replaceAll('null', ''),
          nationality: teacherDetails['country'].toString().replaceAll('null', ''),
          salary: teacherDetails['salary'].toString().replaceAll('null', ''),
          dob: teacherDetails['birthday'].toString().replaceAll('null', ''),
          subjects: _subjects,
          classes: _classes,
          employmentStatus: teacherDetails['employment_status'].toString().replaceAll('null', ''),
          passportLink: map['return_data']['path_teacher_passport'].toString().replaceAll('null', ''),
          activeSession: map['active_session']['session_date']??'',
          activeTerm: map['active_term']['term']??'',
          currency: Currency(
            id: teacherDetails['currency_details']['id'].toString().replaceAll('null', ''),
            uniqueId: teacherDetails['currency_details']['unique_id'].toString().replaceAll('null', ''),
            baseCurrency: teacherDetails['currency_details']['base_currency'].toString().replaceAll('null', ''),
            secondCurrency: teacherDetails['currency_details']['second_currency'].toString().replaceAll('null', ''),
            rateOfConversion: teacherDetails['currency_details']['rate_of_conversion'].toString().replaceAll('null', ''),
            expression: teacherDetails['currency_details']['expression'].toString().replaceAll('null', ''),
            currencyName: teacherDetails['currency_details']['currency_name'].toString().replaceAll('null', ''),
            countryName: teacherDetails['currency_details']['country_name'].toString().replaceAll('null', ''),
            countryAbr: teacherDetails['currency_details']['country_abbr'].toString().replaceAll('null', ''),
            deleted: teacherDetails['currency_details']['is_deleted'].toString().replaceAll('null', '')!='no',
          ),
          preferredCurrencyId: teacherDetails['prefered_currency'].toString().replaceAll('null', ''),
          bankCode: teacherDetails['bank_code'].toString().replaceAll('null', ''),
          bankName: teacherDetails['bank_name'].toString().replaceAll('null', ''),
          bankAccountNumber: teacherDetails['bank_account_number'].toString().replaceAll('null', ''),
          formClasses: _formClasses,
          formTerm: _formTerms,
          formSession: _formSessions,
          isFormTeacher: teacherDetails['form_teacher_status'].toString().replaceAll('null', '')=='yes',
          school: School(
            id: map['return_data']['teacher_details']['school_id'].toString(),
            name: map['current_school_details_array']['name'].toString(),
            phone:  map['current_school_details_array']['contact_phone_number'].toString(),
            email:  map['current_school_details_array']['contact_email'].toString(),
            resultCommentSwitch:  map['current_school_details_array']['result_comment_switch'].toString(),
          ),
          userChatId: teacherDetails['sender_id_for_chat'].toString().replaceAll('null', ''),
          userChatType: teacherDetails['type_of_user_for_chat'].toString().replaceAll('null', ''),
          learningMaterialsCount: map['return_data']['teacher_dashboard_details']['learning_materials_count'].toString().replaceAll('null', '0'),
          assessmentsCount: map['return_data']['teacher_dashboard_details']['teacher_assessments_count'].toString().replaceAll('null', '0'),
          confirmedResultsCount: map['return_data']['teacher_dashboard_details']['confirmed_results_count'].toString().replaceAll('null', '0'),
          pendingResultsCount: map['return_data']['teacher_dashboard_details']['pending_results_count'].toString().replaceAll('null', '0'),
          numberOfClassTeaching: map['return_data']['teacher_dashboard_details']['class_teaching_count'].toString().replaceAll('null', '0'),
          numberOfClassForming: map['return_data']['teacher_dashboard_details']['formTeachers_count'].toString().replaceAll('null', '0'),
          signatoryArea: teacherDetails['signatory_area'].toString().replaceAll('null', ''),
          signatoryAreaUrl: map['return_data']['path_to_teacher_signatory'].toString().replaceAll('null', ''),
          deleted: teacherDetails['is_deleted'].toString().replaceAll('null', '')=='yes'
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return teachers;
  }

  @override
  Future<Students> fetchStudentProfile(String apiToken, String studentId) async{
    // TODO: implement fetchStudentProfile
    Students students;
    print(MyStrings.domain +
        MyStrings.viewStudentProfileUrl +
        apiToken +
        "/" +
        studentId);
    try {
      final response = await http.get(MyStrings.domain +
          MyStrings.viewStudentProfileUrl +
          apiToken +
          "/" +
          studentId);
      Map map = json.decode(response.body);
      print(map);

      if (map["status"].toString()!= 'true') {
        throw ApiException(
            handelServerError(response: map));
      }

      Map details = map['return_data'];
      students=Students(
          id: details["students_details_array"][0]["id"].toString().replaceAll('null', ''),
          uniqueId: details["students_details_array"][0]["unique_id"].toString().replaceAll('null', ''),
          userName: details["students_details_array"][0]["username"].toString().replaceAll('null', ''),
          password: details["students_details_array"][0]["password"].toString().replaceAll('null', ''),
          phone: details["students_details_array"][0]["phone"].toString().replaceAll('null', ''),
          state: details["students_details_array"][0]["state"].toString().replaceAll('null', ''),
          city: details["students_details_array"][0]["city"].toString().replaceAll('null', ''),
          email: details["students_details_array"][0]["email"].toString().replaceAll('null', ''),
          gender: details["students_details_array"][0]["sex"].toString().replaceAll('null', ''),
          activeTerm: map['active_term']['term'].toString().replaceAll('null', ''),
          activeSession: map['active_session']['session_date'].toString().replaceAll('null', ''),
          nationality: details["students_details_array"][0]["nationality"].toString().replaceAll('null', ''),
          passportLink: details["students_passprt_link"].toString().replaceAll('null', ''),
          admissionNumber: details["students_details_array"][0]["addmission_number"].toString().replaceAll('null', ''),
          bloodGroup: details["students_details_array"][0]["blood_group"].toString().replaceAll('null', ''),
          dob: details["students_details_array"][0]["birthday"].toString().replaceAll('null', ''),
          fName: details["students_details_array"][0]["firstname"].toString().replaceAll('null', ''),
          genAdmissionNumber: details["students_details_array"][0]["gen_addmission_number"].toString().replaceAll('null', ''),
          genotype: details["students_details_array"][0]["genotype"].toString().replaceAll('null', ''),
          healthHistory: details["students_details_array"][0]["health_history"].toString().replaceAll('null', ''),
          lName: details["students_details_array"][0]["lastname"].toString().replaceAll('null', ''),
          mName: details["students_details_array"][0]["othernames"].toString().replaceAll('null', ''),
          parentId: details["parent_details_array"][0]["id"].toString().replaceAll('null', ''),
          parentAddress: details["parent_details_array"][0]["parent_address"].toString().replaceAll('null', ''),
          parentEmail: details["parent_details_array"][0]["parent_email"].toString().replaceAll('null', ''),
          parentName: details["parent_details_array"][0]["parent_full_name"].toString().replaceAll('null', ''),
          parentOccupation: details["parent_details_array"][0]["parents_occupation"].toString().replaceAll('null', ''),
          parentPassport: details["parent_details_array"][0]["parent_passport"].toString().replaceAll('null', ''),
          parentPhone: details["parent_details_array"][0]["parent_phone"].toString().replaceAll('null', ''),
          parentTitle: details["parent_details_array"][0]["parent_title"].toString().replaceAll('null', ''),
          particularSchoolDetails: details["particular_scholl_details"].toString().replaceAll('null', ''),
          passport: details["students_details_array"][0]["passport"].toString().replaceAll('null', ''),
          residentAddress: details["students_details_array"][0]["resident_address"].toString().replaceAll('null', ''),
          parentPassportLink: details["parents_passport_link"].toString().replaceAll('null', ''),
          stClass: "${details["class_details_array"][0]["class_label_details"]["label"]} ${details["class_details_array"][0]["class_category_details"]["category"]}",
          classes: Classes(
              status: details["class_details_array"][0]["class_details_array"]["status"].toString().replaceAll('null', ''),
              id: details["class_details_array"][0]["class_details_array"]["id"].toString().replaceAll('null', ''),
              uniqueId: details["class_details_array"][0]["class_details_array"]["unique_id"].toString().replaceAll('null', ''),
              date:'${details["class_details_array"][0]["class_details_array"]["created_at"]}, ${details["class_details_array"][0]["class_details_array"]["updated_at"]}',
              category: details["class_details_array"][0]["class_category_details"]["category"].toString().replaceAll('null', ''),
              label: details["class_details_array"][0]["class_label_details"]["label"].toString().replaceAll('null', ''),
              level: details["class_details_array"][0]["class_level_details"]["level"].toString().replaceAll('null', '')
          ),
          sessions: Sessions(
              uniqueId:  details["students_details_array"][0]["session"]["unique_id"].toString().replaceAll('null', ''),
              id: details["students_details_array"][0]["session"]["id"].toString().replaceAll('null', ''),
              status: details["students_details_array"][0]["session"]["status"].toString().replaceAll('null', ''),
              startAndEndDate: '${details["students_details_array"][0]["session"]["session_start_date"].toString().replaceAll('null', '')}, ${details["students_details_array"][0]["session"]["session_end_date"].toString().replaceAll('null', '')}',
              sessionDate: details["students_details_array"][0]["session"]["session_date"].toString().replaceAll('null', ''),
              admissionNumberPrefix: details["students_details_array"][0]["session"]["admission_no_prefix"].toString().replaceAll('null', '')
          ),
          school: School(
            name: map['current_school_details_array']['name'].toString().replaceAll('null', ''),
            email: map['current_school_details_array']['contact_email'].toString().replaceAll('null', ''),
            phone: map['current_school_details_array']['contact_phone_number'].toString().replaceAll('null', ''),
            address: map['current_school_details_array']['address'].toString().replaceAll('null', ''),
            town: map['current_school_details_array']['town'].toString().replaceAll('null', ''),
            lga: map['current_school_details_array']['lga'].toString().replaceAll('null', ''),
            city: map['current_school_details_array']['city'].toString().replaceAll('null', ''),
            nationality: map['current_school_details_array']['nationality'].toString().replaceAll('null', ''),
            slogan: map['current_school_details_array']['slogan'].toString().replaceAll('null', ''),
            status: map['current_school_details_array']['status'].toString().replaceAll('null', ''),
            image: map['current_school_details_array']['image'].toString().replaceAll('null', ''),
            cacFile: map['current_school_details_array']['cac_file'].toString().replaceAll('null', ''),
            otherFile: map['current_school_details_array']['otherfile'].toString().replaceAll('null', ''),
            poBox: map['current_school_details_array']['p_o_box'].toString().replaceAll('null', ''),
            twitter: map['current_school_details_array']['twitter'].toString().replaceAll('null', ''),
            facebook: map['current_school_details_array']['facebook'].toString().replaceAll('null', ''),
            website: map['current_school_details_array']['school_website'].toString().replaceAll('null', ''),
            instagram: map['current_school_details_array']['instagram'].toString().replaceAll('null', ''),
          ),
          preferredCurrencyId: details["students_details_array"][0]["prefered_currency"].toString().replaceAll('null', ''),
          currency: Currency(
            id: details["students_details_array"][0]["currency_details"]["id"].toString().replaceAll('null', ''),
            uniqueId: details["students_details_array"][0]["currency_details"]["unique_id"].toString().replaceAll('null', ''),
            baseCurrency: details["students_details_array"][0]["currency_details"]["base_currency"].toString().replaceAll('null', ''),
            secondCurrency: details["students_details_array"][0]["currency_details"]["second_currency"].toString().replaceAll('null', ''),
            rateOfConversion: details["students_details_array"][0]["currency_details"]["rate_of_conversion"].toString().replaceAll('null', ''),
            expression: details["students_details_array"][0]["currency_details"]["expression"].toString().replaceAll('null', ''),
            currencyName: details["students_details_array"][0]["currency_details"]["currency_name"].toString().replaceAll('null', ''),
            countryName: details["students_details_array"][0]["currency_details"]["country_name"].toString().replaceAll('null', ''),
            countryAbr: details["students_details_array"][0]["currency_details"]["country_abbr"].toString().replaceAll('null', ''),
            deleted: details["students_details_array"][0]["currency_details"]["is_deleted"].toString().replaceAll('null', '')!='no',
          ),
          boardingStatus: details["students_details_array"][0]['boarding_status'].toString().replaceAll('null', '')=='yes',
          userChatId: details["students_details_array"][0]['sender_id_for_chat'].toString().replaceAll('null', ''),
          userChatType: details["students_details_array"][0]['type_of_user_for_chat'].toString().replaceAll('null', ''),
          assessmentsCount: details["student_dashboard_details"]["student_assessments_count"].toString().replaceAll('null', '0'),
          learningMaterialsCount: details["student_dashboard_details"]["learning_materials_count"].toString().replaceAll('null', '0'),
          eventsCount: details["student_dashboard_details"]["events_count"].toString().replaceAll('null', '0'),
          pendingFees: details["student_dashboard_details"]["pending_fees_sum"].toString().replaceAll('null', '0'),
          deleted: details["students_details_array"][0]['is_deleted'].toString().replaceAll('null', '')!='no'
      );

    } on SocketException {
      throw NetworkError();
    } on FormatException catch (e) {
      throw SystemError();
    }

    return students;
  }

}
