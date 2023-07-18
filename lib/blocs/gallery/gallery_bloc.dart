import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/gallery/gallery.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/requests/get/populate_spinners_request.dart';
import 'package:school_pal/requests/get/view_school_gallery_request.dart';
import 'package:school_pal/requests/posts/add_event_gallery_requests.dart';
import 'package:school_pal/res/strings.dart';

class GalleryBloc extends Bloc<GalleryEvents, GalleryStates>{
  final ViewSchoolGalleryRepository viewSchoolGalleryRepository;
  final AddEventGalleryRepository addEventGalleryRepository;
  GalleryBloc({this.viewSchoolGalleryRepository, this.addEventGalleryRepository}) : super(GalleryInitial());

  @override
  Stream<GalleryStates> mapEventToState(GalleryEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ViewGalleryEvent){
      yield GalleryLoading();
      try{
        final gallery=await viewSchoolGalleryRepository.fetchGallery(event.apiToken);
        yield GalleryLoaded(gallery);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is DeleteGalleryEvent){
      yield Processing();
      try{
        final message=await viewSchoolGalleryRepository.deleteGallery(event.galleryId);
        yield GalleryDeleted(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is AddGalleryEvent){
      yield Processing();
      try{
        final message=await addEventGalleryRepository.addGallery(title: event.title, sessionId: event.sessionId, description: event.description, images: event.images, videos: event.videos, date: event.date);
        yield GalleryAdded(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateGalleryEvent){
      yield Processing();
      try{
        final message=await addEventGalleryRepository.updateGallery(galleryId: event.galleryId, title: event.title, sessionId: event.sessionId, description: event.description, images: event.images, imagesToDelete: event.imagesToDelete, videos: event.videos, date: event.date);
        yield GalleryUpdated(message);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    } else if(event is GetSessionsEvent){
      yield GalleryLoading();
      try{
        final sessions=await getSessionSpinnerValue(event.apiToken);
        yield SessionsLoaded(sessions);
      } on NetworkError{
        yield NetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield ViewError(e.toString());
      }on SystemError{
        yield NetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is SelectSessionEvent){
      yield SessionSelected(event.session);
    }else if(event is LoadImagesFromEvent){
      yield ImagesLoaded(event.images);
    }else if(event is AddLinkToListEvent){
      yield LinkAddedToList(event.link);
    }else if(event is RemoveLinkToListEvent){
      yield LinkRemovedFromList(event.link);
    }else if(event is ChangeDateEvent){
      yield EventDateChanged(event.date);
    }else if(event is AddGalleryImageEvent){
      yield Processing();
      try{
        final imageName=await addEventGalleryRepository.addGalleryImage(galleryId: event.galleryId, fileField: event.fileField, fileType: event.fileType);
        yield GalleryImageAdded(imageName);
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