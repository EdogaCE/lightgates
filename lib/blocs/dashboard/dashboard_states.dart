import 'package:equatable/equatable.dart';
import 'package:school_pal/models/faqs.dart';
import 'package:school_pal/models/news.dart';
import 'package:school_pal/models/school.dart';
import 'package:school_pal/models/students.dart';
import 'package:school_pal/models/teachers.dart';

abstract class DashboardStates extends Equatable{
  const DashboardStates();
}

class InitialState extends DashboardStates{
  const InitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class BarItemChanged extends DashboardStates {
  final int index;
  BarItemChanged(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];
}

class Loading extends DashboardStates{
  const Loading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends DashboardStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoggingOut extends DashboardStates{
  const LoggingOut();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class FAQsLoaded extends DashboardStates{
  final List<FAQs> faqs;
  const FAQsLoaded(this.faqs);
  @override
  // TODO: implement props
  List<Object> get props => [faqs];
}

class FAQsAdded extends DashboardStates{
  final String message;
  const FAQsAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FAQsUpdated extends DashboardStates{
  final String message;
  const FAQsUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class FAQsDeleted extends DashboardStates{
  final String message;
  const FAQsDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsAdded extends DashboardStates{
  final String message;
  const NewsAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsUpdated extends DashboardStates{
  final String message;
  const NewsUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsDeleted extends DashboardStates{
  final String message;
  const NewsDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsLoaded extends DashboardStates{
  final List<News> news;
  const NewsLoaded(this.news);
  @override
  // TODO: implement props
  List<Object> get props => [news];
}

class SingleNewsLoaded extends DashboardStates{
  final News news;
  const SingleNewsLoaded(this.news);
  @override
  // TODO: implement props
  List<Object> get props => [news];
}

class SchoolProfileLoaded extends DashboardStates{
  final School school;
  final String loggedInAs;
  const SchoolProfileLoaded(this.school, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [school, loggedInAs];
}

class TeacherProfileLoaded extends DashboardStates{
  final Teachers teachers;
  final String loggedInAs;
  const TeacherProfileLoaded(this.teachers, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [teachers, loggedInAs];
}

class StudentProfileLoaded extends DashboardStates{
  final Students students;
  final String loggedInAs;
  const StudentProfileLoaded(this.students, this.loggedInAs);
  @override
  // TODO: implement props
  List<Object> get props => [students, loggedInAs];
}

class TagAddedToList extends DashboardStates{
  final String tag;
  const TagAddedToList(this.tag);
  @override
  // TODO: implement props
  List<Object> get props => [tag];

}

class TagRemovedFromList extends DashboardStates{
  final String tag;
  const TagRemovedFromList(this.tag);
  @override
  // TODO: implement props
  List<Object> get props => [tag];

}

class NewsCommentAdded extends DashboardStates{
  final String message;
  const NewsCommentAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsCommentUpdated extends DashboardStates{
  final String message;
  const NewsCommentUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NewsCommentDeleted extends DashboardStates{
  final String message;
  const NewsCommentDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class StepChanged extends DashboardStates {
  final int index;
  StepChanged(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];
}

class LogoutSuccessful extends DashboardStates{
  final String message;
  const LogoutSuccessful(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];

}

class ViewError extends DashboardStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends DashboardStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}