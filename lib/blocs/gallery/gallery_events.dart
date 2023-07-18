import 'package:equatable/equatable.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class GalleryEvents extends Equatable{
  const GalleryEvents();
}

class ViewGalleryEvent extends GalleryEvents{
  final String apiToken;
  const ViewGalleryEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class GetSessionsEvent extends GalleryEvents{
  final String apiToken;
  const GetSessionsEvent(this.apiToken);
  @override
  // TODO: implement props
  List<Object> get props => [apiToken];

}

class SelectSessionEvent extends GalleryEvents{
  final String session;
  const SelectSessionEvent(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class DeleteGalleryEvent extends GalleryEvents{
  final String galleryId;
  const DeleteGalleryEvent(this.galleryId);
  @override
  // TODO: implement props
  List<Object> get props => [galleryId];

}

class UpdateGalleryEvent extends GalleryEvents{
  final String galleryId;
  final String title;
  final String sessionId;
  final String description;
  final List<String> images;
  final List<String> videos;
  final String date;
  final List<String> imagesToDelete;
  const UpdateGalleryEvent(this.galleryId, this.title, this.sessionId, this.description, this.images, this.videos, this.date, this.imagesToDelete);
  @override
  // TODO: implement props
  List<Object> get props => [galleryId, title, sessionId, description, images, videos, date, imagesToDelete];

}

class AddGalleryEvent extends GalleryEvents{
  final String title;
  final String sessionId;
  final String description;
  final List<String> images;
  final List<String> videos;
  final String date;
  const AddGalleryEvent(this.title, this.sessionId, this.description, this.images, this.videos, this.date);
  @override
  // TODO: implement props
  List<Object> get props => [title, sessionId, description, images, videos, date];

}
class AddGalleryImageEvent extends GalleryEvents{
  final String galleryId;
  final String fileField;
  final String fileType;
  const AddGalleryImageEvent(this.galleryId, this.fileField, this.fileType);
  @override
  // TODO: implement props
  List<Object> get props => [galleryId, fileField, fileType];

}

class LoadImagesFromEvent extends GalleryEvents{
  final List<Asset> images;
  const LoadImagesFromEvent(this.images);
  @override
  // TODO: implement props
  List<Object> get props => [images];

}

class AddLinkToListEvent extends GalleryEvents{
  final String link;
  const AddLinkToListEvent(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class RemoveLinkToListEvent extends GalleryEvents{
  final String link;
  const RemoveLinkToListEvent(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class ChangeDateEvent extends GalleryEvents{
final DateTime date;
const ChangeDateEvent(this.date);
@override
// TODO: implement props
List<Object> get props => [date];

}