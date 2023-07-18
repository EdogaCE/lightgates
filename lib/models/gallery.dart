import 'package:equatable/equatable.dart';
import 'package:school_pal/models/sessions.dart';

class Gallery extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String sessionId;
  final String title;
  final String description;
  final String images;
  final String videos;
  final String date;
  final Sessions sessions;
  final String imageUrl;
  final bool deleted;

  Gallery(
      {this.id,
      this.uniqueId,
      this.schoolId,
      this.sessionId,
      this.title,
      this.description,
      this.images,
      this.videos,
      this.date,
      this.sessions,
      this.imageUrl,
      this.deleted});

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        uniqueId,
        schoolId,
        sessionId,
        title,
        description,
        images,
        videos,
        date,
        sessions,
        imageUrl,
        deleted
      ];
}
