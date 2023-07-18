import 'package:school_pal/blocs/dashboard/dashboard_events.dart';
import 'package:school_pal/blocs/dashboard/dashboard_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/requests/get/view_faqs_news_request.dart';
import 'package:school_pal/requests/get/view_profile_request.dart';
import 'package:school_pal/requests/posts/add_edit_faq_news_requests.dart';
import 'package:school_pal/requests/posts/logout_request.dart';
import 'package:school_pal/res/strings.dart';
import 'package:school_pal/utils/exceptions.dart';

class DashboardBloc extends Bloc<DashboardEvents, DashboardStates>{
  final ViewFAQsNewsRepository viewFAQsNewsRepository;
  final ViewProfileRepository viewProfileRepository;
  final CreateFaqNewsRepository createFaqNewsRepository;
  final LogoutRepository logoutRepository;
  DashboardBloc({this.viewProfileRepository, this.viewFAQsNewsRepository, this.createFaqNewsRepository, this.logoutRepository}) : super(InitialState());

  @override
  Stream<DashboardStates> mapEventToState(DashboardEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ChangeBarItemEvent){
      yield BarItemChanged(event.index);
    }else if(event is ViewFAQsEvent){
      yield Loading();
      try{
        final faqs=await viewFAQsNewsRepository.fetchFAQs(localDb: event.localDB);
        yield FAQsLoaded(faqs);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewNewsEvent){
      yield Loading();
      try{
        final news=await viewFAQsNewsRepository.fetchNews(localDb: event.localDB);
        yield NewsLoaded(news);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewSingleNewsEvent){
      yield Loading();
      try{
        final news=await viewFAQsNewsRepository.fetchSingleNews(event.newsId);
        yield SingleNewsLoaded(news);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewSchoolProfileEvent){
      try{
        final school=await viewProfileRepository.fetchSchoolProfile(event.apiToken);
        yield SchoolProfileLoaded(school, event.loggedInAs);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewTeacherProfileEvent){
      try{
        final teacher=await viewProfileRepository.fetchTeacherProfile(event.apiToken, event.teacherId);
        yield TeacherProfileLoaded(teacher, event.loggedInAs);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewStudentProfileEvent){
      try{
        final student=await viewProfileRepository.fetchStudentProfile(event.apiToken, event.studentId);
        yield StudentProfileLoaded(student, event.loggedInAs);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddFaqEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.addFaq(question: event.question, answer: event.answer);
        yield FAQsAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateFaqEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.updateFaq(id: event.id, question: event.question, answer: event.answer);
        yield FAQsUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddNewsEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.addNews(title: event.title, content: event.content, tags: event.tags);
        yield NewsAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateNewsEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.updateNews(id: event.id, title: event.title, content: event.content, tags: event.tags);
        yield NewsUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteFaqsEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.deleteFaq(id: event.id);
        yield FAQsDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteNewsEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.deleteNews(id: event.id);
        yield NewsDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddTagToListEvent){
      yield TagAddedToList(event.tag);
    }else if(event is RemoveTagToListEvent){
      yield TagRemovedFromList(event.tag);
    }else if(event is AddNewsCommentEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.addNewsComment(newsId: event.newsId, userId: event.userId, comment: event.comment);
        yield NewsCommentAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateNewsCommentEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.updateNewsComment(commentId: event.commentId, newsId: event.newsId, userId: event.userId, comment: event.comment);
        yield NewsCommentUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteNewsCommentEvent){
      yield Processing();
      try{
        final message=await createFaqNewsRepository.deleteNewsComment(commentId: event.commentId);
        yield NewsCommentDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeStepEvent){
      yield StepChanged(event.index);
    }else if(event is LogoutEvent){
      yield LoggingOut();
      String message='Logout Successful';
      try{
        switch (event.loggedInAs){
          case MyStrings.school:
            {
              message = await logoutRepository.logSchoolOut(platform: event.platform);
              break;
            }
          case MyStrings.teacher:
            {
              message = await logoutRepository.logTeacherOut(platform: event.platform);
              break;
            }
          case MyStrings.student:
            {
              message = await logoutRepository.logStudentOut(platform: event.platform);
              break;
            }
        }
        yield LogoutSuccessful(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }
  }
}