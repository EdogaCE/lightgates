
 class MyStrings{
  static const String appName="Lightgates Educational";
  static const String iosVersion="1.0.3";
  static const String androidVersion="1.0.4";
  static const String minLaunchesBeforeRating="10";
  static const String androidPlatformId="mobile-android";
  static const String iosPlatformId="mobile-ios";
  //Users
  static const String teacher="teacher";
  static const String student="student";
  static const String school="school";
  //Ui Strings
  //static const String pageOneWriteUp="First write-up goes here and techocraft located in Enugu state";
  //static const String pageTwoWriteUp="Second write-up goes here and my name is collins company name is techocraft located in Enugu state";
  //static const String pageThreeWriteUp="Third write-up goes here and my name is collins company name is techocraft";
  static const String logOut="Are you sure you want to logout?";
  static const String networkErrorMessage="Network error, try again later";
  static const String systemErrorMessage="System error, please contact administrator";
  static const String searchErrorMessage="Oops... No data to search";
  static const String impressionCapturedError="Impression have been already captured";
  static const String verificationErrorMessage="Sorry your account is not yet activated, at this stage you are not allow to perform this action, kindly exercise patience while we activate your account.";
  static const String firsTimeLoginMessage="Welcome to $appName, we would like to guide you through the initial setups to help perfect your account";
  static const String updateAndroidMessage="A newer version of $appName, has been uploaded to play store, please update your app to continue";
  static const String updateIOSMessage="A newer version of $appName, has been uploaded to app store, please update your app to continue";
  static const String rateAppMessage="If you enjoy using $appName, would you mind taking a moment to rate it? it won't take more than a minute. Thanks for your support!";
  static const String welcomeTitle="Welcome";
  static const String welcomeMessage="What can I help you with?";
  //Setup steps messages
  static const String stepOneMessage="CREATE SESSIONS AND ACTIVATE ONE, You are required to add at least one school session and activate one of the sessions added";
  static const String stepTwoMessage="CREATE TERMS AND ACTIVATE ONE, You are required to add at least one school term and activate one of the terms added";
  static const String stepThreeMessage="CREATE CLASS LABELS, You are required to add at least one class label e.g primary1, primary2, jss1, sss1... according to your school's format.";
  static const String stepFourMessage="CREATE CLASS CATEGORIES, You are required to add at least one class category e.g apple, orange, blue, green, A, B, C... according to your school's format.";
  static const String stepFiveMessage="CREATE CLASS LEVELS,, You are required to add at least one class level e.g 1,2,3... or 100, 200, 300..., according to your school's format.";
  static const String stepSixMessage="CREATE CLASSES, You are required to add at least one class. A class is a combination of class label, class categories and class level e.g Jss1 Apple(Level 100).";
  static const String stepSevenMessage="CREATE SUBJECTS, You are required to add at least one subject e.g english, mathematics... according to your school's format.";
  static const String stepCompletionMessage="Congratulations!, you have successfully completed the initial setup for your system. You can now move on to adding teachers and students, you can also goto your settings page and customize your system according to your school preference";

  //Dashboard side drawer button parents
  static const String navAssignments='Assignments';
  static const String navLearningMaterials='Learning Materials';
  static const String navCalender='Calender';
  static const String navGallery='Gallery';
  static const String navSubjects='Subjects';
  static const String navSalary='Salary';
  static const String navFees='Fees';
  static const String navChats='Chats';
  static const String navVerifyPickUpId='Verify Pick-up Id';
  static const String navGeneratePickUpId='Generate Pick-up Id';
  static const String navGames='Games';
  static const String navDictionary='Dictionary';
  static const String navAdvertise='Advertise';
  static const String navClass='Class';
  static const String navContact='Contact';
  static const String navWallet='Wallet';
  static const String navTeachers='Teachers';
  static const String navStudents='Students';
  static const String navSchool='School';
  static const String navResults='Results';
  static const String navSignOut='Sign Out';
  //Dashboard side drawer button children
  static const String navAllClass='All Class';
  static const String navAllClassCategories='All Class Category';
  static const String navAllClassLabels='All Class Label';
  static const String navAllClassLevels='All Class Levels';
  static const String navViewSessions='View Sessions';
  static const String navViewTerms='View Terms';
  static const String navViewGradingSystem='Grading System';
  static const String navViewWallet='View Wallet';
  static const String navCreatePayStackAccount='Create PayStack Account';
  static const String navCreateFlutterWaveAccount='Create FlutterWave Account';
  static const String navAboutSchool='About School';
  static const String navAllStudents='All Students';
  static const String navAllStudentsByClass='Students In A Class';
  static const String navAllTeachers='All Teachers';
  static const String navAllTeachersByClass='Teachers In A Class';
  static const String navCreateTicket='Create Ticket';
  static const String navContactDeveloper='Contact Developer';
  static const String navPendingResults='Pending Results';
  static const String navVerifiedResults='Verified Results';
  static const String navTermlyResults='Termly Results';
  static const String navCumulativeResults='Cumulative Results';
  static const String navBehaviouralSkills='Behavioural Skills';
  static const String navAttendance='Attendance';
  static const String navBills='Bill Payment';
  //Dashboard content button
  static const String bntTeachers="View Teachers";
  static const String bntStudents="View Students";
  static const String bntGallery="Gallery";
  static const String bntAssignments="Assignments";
  static const String bntResults="Results";
  static const String bntDictionary="Dictionary";
  static const String bntCalender="Calender";
  static const String principalsComments="Principal\'s Comments";

  //Res URLs
  static const String logoPath='lib/assets/images/logo.png';
  static const String pageOneImagePath='lib/assets/images/school_board.png';
  static const String pageTwoImagePath='lib/assets/images/school_kids.png';
  static const String pageThreeImagePath='lib/assets/images/school_bird.png';
  static const String networkError='lib/assets/images/network_error.svg';
  static const String noData='lib/assets/images/no_data.svg';

  //Api URLs
  static const String domain='https://schools.lightgates.app/';
  static const String getAppVersionUrl='api/return_app_version';
  static const String schoolLoginUrl='api/school/login';
  static const String registerUrl='api/school/register/post';
  static const String resentVerificationEmailUrl='api/resend_mail/';
  static const String verificationVideo='api/school/update_video/';
  static const String viewStudentsUrl='api/school/view_all_students/';
  static const String viewTeachersUrl='api/teachers/all/';
  static const String viewClassesUrl='api/classTb/get_all_class_with_details/';
  static const String viewClassCategoriesUrl='api/classCategory/all/';
  static const String viewClassLabelsUrl='api/classLabels/all/';
  static const String viewClassLevelsUrl='api/classLevels/all/';
  static const String addClassCategoriesUrl='api/classCategory/store/';
  static const String editClassCategoriesUrl='api/classCategory/update/';
  static const String deleteClassCategoriesUrl='api/classCategory/delete/';
  static const String addClassLabelUrl='api/classLabel/store/';
  static const String editClassLabelUrl='api/classLabel/update/';
  static const String deleteClassLabelUrl='api/classLabel/delete/';
  static const String addClassLevelUrl='api/classLevel/store/';
  static const String editClassLevelUrl='api/classLevel/update/';
  static const String deleteClassLevelUrl='api/classLevel/delete/';
  static const String addClassUrl='api/classTb/store/';
  static const String editClassUrl='api/classTb/update/';
  static const String deleteClassUrl='api/classTb/delete/';
  static const String viewSubjectsUrl='api/subject/all/';
  static const String addSubjectUrl='api/subject/store/';
  static const String editSubjectUrl='api/subject/update/';
  static const String deleteSubjectUrl='api/subject/delete/';
  static const String viewFAQUrl='api/school/show_all_faqs/';
  static const String addFAQUrl='api/school/create_new_faqs/';
  static const String updateFAQUrl='api/school/update_faqs/';
  static const String deleteFAQUrl='api/school/delete_faqs/';
  static const String viewNewsUrl='api/blog/all/';
  static const String viewSingleNewsUrl='api/blog/show/';
  static const String addNewsUrl='api/blog/store/';
  static const String addNewsCommentUrl='api/blogComment/store/';
  static const String updateNewsCommentUrl='api/blogComment/update/';
  static const String deleteNewsCommentUrl='api/blogComment/delete/';
  static const String updateNewsUrl='api/blog/update/';
  static const String deleteNewsUrl='api/blog/delete/';
  static const String viewSchoolProfileUrl='api/school/show/';
  static const String updateSchoolProfileUrl='api/school/update/';
  static const String updateSchoolSettingsUrl='api/school/update_school_settings/';
  static const String changeSchoolPasswordUrl='api/school/edit_password/';
  static const String schoolLogoutUrl='api/school/logout/';
  static const String uploadSchoolLogoUrl='api/school/upload_school_logo/';
  static const String viewAssessmentsUrl='api/school/show_assessment/';
  static const String viewSchoolSessionsUrl='api/school/show_session/';
  static const String activateSchoolSessionsUrl='api/school/make_a_session_active/';
  static const String addSchoolSessionsUrl='api/school/register_session/';
  static const String updateSchoolSessionsUrl='api/school/update_session/';
  static const String viewSchoolTermUrl='api/school/show_term/';
  static const String activateSchoolTermUrl='api/school/make_a_term_active/';
  static const String addSchoolTermUrl='api/school/register_term/';
  static const String rearrangeSchoolTermUrl='api/school/update_cumulative_setup/';
  static const String updateSchoolTermUrl='api/school/update_term/';
  static const String viewSchoolEventsUrl='api/school/view_calender_event/';
  static const String addSchoolEventsUrl='api/school/store_new_calender_event/';
  static const String updateSchoolEventsUrl='api/school/update_calender_event/';
  static const String deleteSchoolEventsUrl='api/school/delete_calender_event/';
  static const String verifyPickUpIdUrl='api/pickUpPupil/showStudentViaInput/';
  static const String viewTicketWithCommentUrl='api/ticket/all/';
  static const String viewTicketCategoriesUrl='api/ticketCategory/all/';
  static const String createTicketUrl='api/ticket/store/';
  static const String createTicketCommentUrl='api/ticketComment/store/';
  static const String viewAllSchoolUrl='api/schools/all';
  static const String viewSchoolGalleryUrl='api/schoolGallery/all/';
  static const String deleteSchoolGalleryUrl='api/schoolGallery/delete_a_gallery/';
  static const String addSchoolGalleryUrl='api/schoolGallery/store/';
  static const String updateGalleryUrl='api/schoolGallery/update/';
  static const String viewLearningMaterialsUrl='api/school/view_all_learning_materials/';
  static const String viewSalaryRecordUrl='api/school/get_main_payment_records_for_teacher/';
  static const String viewParticularSalaryRecordUrl='api/school/get_one_main_payment_records_for_teacher/';
  static const String createParticularSalaryRecordUrl='api/school/store_main_payment_records_for_teacher/';
  static const String updateParticularSalaryRecordUrl='api/school/update_main_payment/';
  static const String updateTeacherSalaryPaymentRecordUrl='api/school/update_teacher_payment_status/';
  static const String payTeachersSalaryWithFlutterWaveUrl='api/school/pay_teachers_with_flutter_wave/';
  static const String viewPendingClassResultUrl='api/result/select_result_list_by_class_session_term/';
  static const String viewConfirmedClassResultUrl='api/result/select_confirmed_result_list_by_class_session_term/';
  static const String viewPendingSubjectResultUrl='api/result/select_result_for_admin_view_with_subject_class_session_term/';
  static const String viewConfirmedSubjectResultUrl='api/result/get_all_result_for_a_subject_class_session_term/';
  static const String approveResultUrl='api/result/save_confirmed_result/';
  static const String declineResultUrl='api/result/decline_result/';
  static const String addAssessmentsUrl='api/school/create_assessment/';
  static const String updateAssessmentsUrl='api/school/update_assessment/';
  static const String addLearningMaterialsUrl='api/school/learning_material_upload/';
  static const String updateLearningMaterialsUrl='api/school/update_learning_materials/';
  static const String viewFeesRecordUrl='api/feeCategory/all/';
  static const String createParticularFeesRecordUrl='api/feeCategory/store/';
  static const String updateParticularFeesRecordUrl='api/feeCategory/update/';
  static const String viewFeesUrl='api/fee/all/';
  static const String deleteParticularFeesRecordUrl='api/feeCategory/delete/';
  static const String undoDeleteParticularFeesRecordUrl='api/feeCategory/undo_delete/';
  static const String deleteParticularFeesUrl='api/fee/delete/';
  static const String createParticularFeesUrl='api/fee/store/';
  static const String updateParticularFeesUrl='api/fee/update/';
  static const String viewFeesPaymentsUrl='api/fee/show_all_student_fees/';
  static const String viewOutstandingFeesPaymentsUrl='api/fee/get_outstanding_payments/';
  static const String viewFeesPaymentsByDateUrl='api/fee/get_payments_by_date/';
  static const String confirmFeesPaymentsUrl='api/fee/confirm_fee_payment/';
  static const String deactivateDefaultStudentUrl='api/fee/deactivate_student/';
  static const String viewAllCurrenciesUrl='api/currency/get_all_currency/';
  static const String addFormTeacherUrl='api/teacher/assign_form_teacher/';
  static const String removeFormTeacherUrl='api/teacher/remove_form_teacher/';
  static const String addTeacherClassSubjectUrl='api/teacherClassSubject/store/';
  static const String updateTeacherClassSubjectUrl='api/teacherClassSubject/update/';
  static const String removeTeacherClassSubjectUrl='api/teacherClassSubject/delete/';
  static const String viewWalletFoundHistoryUrl='api/fee/view_all_top_up_invoice/';
  static const String viewFlutterWaveBankCodesUrl='api/get_flutter_wave_bank_codes';
  static const String viewPayStackBankCodesUrl='api/get_paystack_bank_codes';
  static const String addFlutterWaveAccountUrl='api/payments/create_flutter_wave_sub_account/';
  static const String addPayStackAccountUrl='api/payments/create_pay_stack_sub_account/';
  static const String foundSchoolWalletUrl='api/payments/top_up_amount_to_wallet/';
  static const String viewStudentsAttendanceInterfaceUrl='api/teacher/get_values_for_attendance_interface/';
  static const String viewStudentsBehaviouralSkillsInterfaceUrl='api/teacher/get_values_for_behavioural_skills/';
  static const String addStudentsAttendanceUrl='api/teacher/process_attendance_submission/';
  static const String addStudentsBehaviouralSkillsUrl='api/teacher/process_behavioural_skill_scores/';
  static const String viewSchoolGradesUrl='api/result/get_school_grades_details/';
  static const String addSchoolGradesUrl='api/result/save_grade_details/';
  static const String updateSchoolGradesUrl='api/result/update_grades_details/';
  static const String deleteSchoolGradesUrl='api/result/delete_grade_details_remark/';
  static const String restoreSchoolGradesUrl='api/result/undo_delete_grade_details_remark/';
  static const String viewDeveloperProfileUrl='api/dev/get_developer_settings/';
  static const String forgotPasswordUrl='api/forgetPassword';
  static const String verifyOptUrl='api/resetTokenPost';
  static const String resetPasswordUrl='api/resetPassword';
  static const String viewPrincipalCommentsUrl='api/result/get_principal_comment_by_term_session/';
  static const String viewTeacherCommentsUrl='api/result/get_class_teacher_comment_by_session_term_class/';
  static const String addPrincipalCommentsUrl='api/result/save_principal_comment/';
  static const String addTeacherCommentsUrl='api/result/save_class_teacher_comment/';
  static const String updatePrincipalCommentsUrl='api/result/update_principal_comment/';
  static const String updateTeacherCommentsUrl='api/result/update_class_teacher_comment/';
  static const String deletePrincipalCommentsUrl='api/result/delete_principals_remark/';
  static const String deleteTeacherCommentsUrl='api/result/delete_class_teacher_remark/';
  static const String restorePrincipalCommentsUrl='api/result/undo_delete_principals_remark/';
  static const String restoreTeacherCommentsUrl='api/result/undo_class_teacher_remark_delete/';
  static const String viewChatContactsUrl='api/chat/contacts/';
  static const String viewChatGroupsUrl='api/chat/get_group_head/';
  static const String viewChatsUrl='api/chat/get_chat/';
  static const String viewChatMessagesUrl='api/chat/get_single_chat/';
  static const String updateChatReadMessagesUrl='api/chat/update_chat_read_receipt/';
  static const String createGroupUrl='api/chat/create_group_chats/';
  static const String addGroupMembersUrl='api/chat/add_members_to_group/';
  static const String sendFirebaseTokenUrl='api/chat/update_fcm_token/';
  static const String sendChatMessageUrl='api/chat/send_chat/';
  static const String updateFirstTimeLoginUrl='api/school/update_first_time_login/';
  static const String updateFirstTimeSetupPageUrl='api/school/update_first_time_setup_page/';
  static const String viewNotificationsUrl='api/notifications/notification_selector_all/';
  static const String viewNotificationUrl='api/notifications/notification_selector/';
  static const String viewAdvertsUrl='api/adverts/select_ads_campaign_for_display/';
  static const String viewUserAdvertsUrl='api/adverts/call_to_select_all_ads_campaign/';
  static const String captureAdImpressionUrl='api/adverts/capture_ads_impression/';
  static const String viewBillPaymentCategoryUrl='api/advert/get_bill_categories/';
  static const String billPaymentUrl='api/advert/create_bills_payment/';
  static const String createAdCampaignUrl='api/adverts/store_ads_campaign/';
  static const String updateAdCampaignUrl='api/adverts/update_ads_campaign/';
  static const String adValidatorUrl='api/adverts/advert_validator/';
  static const String pauseOrCancelAdCampaignUrl='api/adverts/pause_or_cancel_ads_campaign/';
  static const String restartAdCampaignUrl='api/adverts/ads_campaign_re_start/';
  static const String topUpDetailsUrl='api/fee/view_top_up_invoice/';
  //Teacher urls
  static const String teacherLoginUrl='api/teacher_login';
  static const String viewTeacherProfileUrl='api/teacher/show/';
  static const String uploadTeacherImageUrl='api/teacher/updateTeacherImage/';
  static const String createTeacherProfileUrl='api/teacher/store/';
  static const String updateTeacherProfileUrl='api/teacher/update/';
  static const String changeTeacherPasswordUrl='api/teacher/update_teacher_password/';
  static const String teacherLogOutUrl='api/teacher/logout_teacher/';
  static const String uploadTeacherSignatoryUrl='api/teacher/upload_signature_for_result/';
  //Student urls
  static const String studentLoginUrl='api/students_login';
  static const String viewStudentProfileUrl='api/school/view_single_students/';
  static const String uploadStudentImageUrl='api/school/edit_student_passport/';
  static const String updateStudentProfileUrl='api/school/update_a_students_profile/';
  static const String createStudentProfileUrl='api/school/store_students_data_via_form/';
  static const String deleteStudentProfileUrl='api/school/delete_students/';
  static const String changeStudentPasswordUrl='api/school/edit_students_password/';
  static const String updateParentProfileUrl='api/school/update_parents_profile/';
  static const String changeParentImageUrl='api/school/upload_parent_passport/';
  static const String generatePickUpIdUrl='api/pickUpPupil/store/';
  static const String viewStudentResultUrl='api/result/download_students_result/';
  static const String viewStudentCumulativeResultUrl='api/result/download_students_cummulative_result/';
  static const String viewStudentFeesUrl='api/fee/show_single_fees_for_student/';
  static const String studentFeesPaymentGatewayUrl='api/payments/gateway_payment/';
  static const String studentLogOutUrl='api/school/student_logout/';
  static const String flutterWaveSubAccountUrl='api/school/sub_accounts_flutter_wave/';
  static const String payStackSubAccountUrl='api/school/sub_accounts_paystack/';
  //Frontend urls
  static const String frontEndDomain='https://lightgates.app/';
  static const String gamesUrl='play_games';
  static const String dictionaryUrl='dictionary_page';
  static const String advertisementSetupUrl='activities/create-ads?devops=';
}