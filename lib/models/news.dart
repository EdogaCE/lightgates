import 'package:equatable/equatable.dart';
import 'package:school_pal/models/news_comment.dart';

class News extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String title;
  final String content;
  final String views;
  final String tags;
  final String date;
  final List<NewsComment> comments;

  News(
      {this.id,
        this.uniqueId,
        this.schoolId,
        this.title,
        this.content,
        this.views,
        this.tags,
        this.date,
        this.comments
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    schoolId,
    title,
    content,
    views,
    tags,
    date,
    comments
  ];
}
