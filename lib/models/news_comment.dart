import 'package:equatable/equatable.dart';

class NewsComment extends Equatable {
  final String id;
  final String uniqueId;
  final String name;
  final String email;
  final String content;

  NewsComment(
      {this.id,
        this.uniqueId,
        this.name,
        this.email,
        this.content
      });

  @override
  // TODO: implement props
  List<Object> get props => [
    id,
    uniqueId,
    name,
    email,
    content
  ];
}
