import 'package:equatable/equatable.dart';
import 'package:school_pal/models/gallery.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class GalleryStates extends Equatable{
  const GalleryStates();
}

class GalleryInitial extends GalleryStates{
  const GalleryInitial();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GalleryLoading extends GalleryStates{
  const GalleryLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Processing extends GalleryStates{
  const Processing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GalleryLoaded extends GalleryStates{
  final List<Gallery> gallery;
  const GalleryLoaded(this.gallery);
  @override
  // TODO: implement props
  List<Object> get props => [gallery];
}

class SessionsLoaded extends GalleryStates{
  final List<List<String>> sessions;
  const SessionsLoaded(this.sessions);
  @override
  // TODO: implement props
  List<Object> get props => [sessions];
}

class SessionSelected extends GalleryStates{
  final String session;
  const SessionSelected(this.session);
  @override
  // TODO: implement props
  List<Object> get props => [session];

}

class ImagesLoaded extends GalleryStates{
  final List<Asset> images;
  const ImagesLoaded(this.images);
  @override
  // TODO: implement props
  List<Object> get props => [images];

}

class LinkAddedToList extends GalleryStates{
  final String link;
  const LinkAddedToList(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class LinkRemovedFromList extends GalleryStates{
  final String link;
  const LinkRemovedFromList(this.link);
  @override
  // TODO: implement props
  List<Object> get props => [link];

}

class EventDateChanged extends GalleryStates{
  final DateTime date;
  const EventDateChanged(this.date);
  @override
// TODO: implement props
  List<Object> get props => [date];

}

class GalleryDeleted extends GalleryStates{
  final String message;
  const GalleryDeleted(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class GalleryAdded extends GalleryStates{
  final String message;
  const GalleryAdded(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class GalleryImageAdded extends GalleryStates{
  final String imageName;
  const GalleryImageAdded(this.imageName);
  @override
  // TODO: implement props
  List<Object> get props => [imageName];
}

class GalleryUpdated extends GalleryStates{
  final String message;
  const GalleryUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ViewError extends GalleryStates{
  final String message;
  const ViewError(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class NetworkErr extends GalleryStates{
  final String message;
  const NetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}