import 'package:equatable/equatable.dart';

abstract class DashboardEvents extends Equatable{
  const DashboardEvents();
}

class ChangeBarItemEvent extends DashboardEvents{
  final int index;
  ChangeBarItemEvent(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];

}

class ViewFAQsEvent extends DashboardEvents{
  final bool localDB;
  const ViewFAQsEvent({this.localDB});
  @override
  // TODO: implement props
  List<Object> get props => [localDB];

}

class ChangeStepEvent extends DashboardEvents{
  final int index;
  ChangeStepEvent(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];

}

class ViewNewsEvent extends DashboardEvents{
  final bool localDB;
  const ViewNewsEvent({this.localDB});
  @override
  // TODO: implement props
  List<Object> get props => [localDB];

}

class ViewSingleNewsEvent extends DashboardEvents{
  final String newsId;
  const ViewSingleNewsEvent(this.newsId);
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class AddFaqEvent extends DashboardEvents{
  final String question;
  final String answer;
  const AddFaqEvent(this.question, this.answer);
  @override
  // TODO: implement props
  List<Object> get props => [question, answer];

}

class UpdateFaqEvent extends DashboardEvents{
  final String id;
  final String question;
  final String answer;
  const UpdateFaqEvent(this.id, this.question, this.answer);
  @override
  // TODO: implement props
  List<Object> get props => [id, question, answer];

}

class DeleteFaqsEvent extends DashboardEvents{
  final String id;
  const DeleteFaqsEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}

class AddNewsEvent extends DashboardEvents{
  final String title;
  final String content;
  final String tags;
  const AddNewsEvent(this.title, this.content, this.tags);
  @override
  // TODO: implement props
  List<Object> get props => [title, content, tags];

}

class UpdateNewsEvent extends DashboardEvents{
  final String id;
  final String title;
  final String content;
  final String tags;
  const UpdateNewsEvent(this.id, this.title, this.content, this.tags);
  @override
  // TODO: implement props
  List<Object> get props => [id,title, content, tags];

}

class DeleteNewsEvent extends DashboardEvents{
  final String id;
  const DeleteNewsEvent(this.id);
  @override
  // TODO: implement props
  List<Object> get props => [id];

}

class ViewSchoolProfileEvent extends DashboardEvents{
  final String apiToken;
  final String loggedInAs;
  const ViewSchoolProfileEvent(this.apiToken, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, loggedInAs];

}

class ViewTeacherProfileEvent extends DashboardEvents{
  final String apiToken;
  final String teacherId;
  final String loggedInAs;
  const ViewTeacherProfileEvent(this.apiToken, this.teacherId, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, teacherId, loggedInAs];

}

class ViewStudentProfileEvent extends DashboardEvents{
  final String apiToken;
  final String studentId;
  final String loggedInAs;
  const ViewStudentProfileEvent(this.apiToken, this.studentId, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken, studentId, loggedInAs];

}

class AddTagToListEvent extends DashboardEvents{
  final String tag;
  const AddTagToListEvent(this.tag);
  @override
  // TODO: implement props
  List<Object> get props => [tag];

}

class RemoveTagToListEvent extends DashboardEvents{
  final String tag;
  const RemoveTagToListEvent(this.tag);
  @override
  // TODO: implement props
  List<Object> get props => [tag];

}

class AddNewsCommentEvent extends DashboardEvents{
  final String newsId;
  final String userId;
  final String comment;
  const AddNewsCommentEvent(this.newsId, this.userId, this.comment);
  @override
  // TODO: implement props
  List<Object> get props => [newsId, userId, comment];

}

class UpdateNewsCommentEvent extends DashboardEvents{
  final String commentId;
  final String newsId;
  final String userId;
  final String comment;
  const UpdateNewsCommentEvent(this.commentId, this.newsId, this.userId, this.comment);
  @override
  // TODO: implement props
  List<Object> get props => [commentId, newsId, userId, comment];

}

class DeleteNewsCommentEvent extends DashboardEvents{
  final String commentId;
  const DeleteNewsCommentEvent(this.commentId);
  @override
  // TODO: implement props
  List<Object> get props => [commentId];

}

class LogoutEvent extends DashboardEvents{
  final String loggedInAs;
  final String platform;
  const LogoutEvent(this.loggedInAs, this.platform);
  @override
  // TODO: implement props
  List<Object> get props => [loggedInAs, platform];

}