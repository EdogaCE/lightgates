import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pal/blocs/advert/advert.dart';
import 'package:school_pal/requests/get/view_adverts_request.dart';
import 'package:school_pal/requests/get/view_wallet_request.dart';
import 'package:school_pal/requests/posts/update_advert_requests.dart';
import 'package:school_pal/utils/exceptions.dart';
import 'package:school_pal/res/strings.dart';

class AdvertBloc extends Bloc<AdvertEvents, AdvertStates>{
  final ViewAdvertsRepository viewAdvertsRepository;
  final UpdateAdvertRepository updateAdvertRepository;
  final ViewWalletRepository viewWalletRepository;
  AdvertBloc({this.viewAdvertsRepository, this.updateAdvertRepository, this.viewWalletRepository})
      : super(AdvertInitialState());


  @override
  Stream<AdvertStates> mapEventToState(AdvertEvents event) async* {
    // TODO: implement mapEventToState
    if(event is ViewAdvertsEvent){
      yield AdvertsLoading();
      try{
        final adverts=await viewAdvertsRepository.fetchAdverts(userUniqueId: event.userUniqueId);
        yield AdvertsLoaded(adverts);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewUserAdvertsEvent){
      yield AdvertsLoading();
      try{
        final adverts=await viewAdvertsRepository.fetchUserAdverts();
        yield AdvertsLoaded(adverts);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is CaptureAdImpressionEvent){
      yield AdvertsProcessing();
      try{
        final advert=await updateAdvertRepository.captureAdImpression(userUniqueId: event.userUniqueId, adUniqueId: event.adUniqueId, impression: event.impression);
        yield ImpressionCaptured(adverts: advert, impression: event.impression, nextPosition: event.nextPosition, randomly: event.randomly);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString(), impression: event.impression, nextPosition: event.nextPosition, randomly: event.randomly);
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is CreateAdCampaignEvent){
      yield AdvertsProcessing();
      try{
        final message=await updateAdvertRepository.createAdvertCampaign(budget: event.budget, caption: event.caption, startDate: event.startDate, endDate: event.endDate, driveTrafficTo: event.driveTrafficTo, webAppUrl: event.webAppUrl, whatsAppNo: event.whatsAppNo, countryCode: event.countryCode, images: event.images, appUrl: event.appUrl, webUrl: event.webUrl);
        yield AdCampaignCreated(message);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is UpdateAdCampaignEvent){
      yield AdvertsProcessing();
      try{
        final message=await updateAdvertRepository.updateAdvertCampaign(addCampaignId: event.addCampaignId, budget: event.budget, caption: event.caption, startDate: event.startDate, endDate: event.endDate, driveTrafficTo: event.driveTrafficTo, webAppUrl: event.webAppUrl, whatsAppNo: event.whatsAppNo, countryCode: event.countryCode, images: event.images, appUrl: event.appUrl, webUrl: event.webUrl);
        yield AdCampaignUpdated(message);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ChangeDateFromEvent){
      yield DateFromChanged(event.from);
    }else if(event is ChangeDateToEvent){
      yield DateToChanged(event.to);
    }else if(event is ChangeDriveTrafficToEvent){
      yield DriveTrafficToChanged(event.value);
    }else if(event is SelectImageEvent){
      yield ImageSelected(event.path);
    }else if(event is ValidateAdvertEvent){
      //yield AdvertsProcessing();
      try{
        final message=await updateAdvertRepository.validateAdvert(budget: event.budget, startDate: event.startDate, endDate: event.endDate);
        yield AdvertValidated(message);
      } on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is ViewWalletBalanceEvent){
      //yield AdvertsProcessing();
      try{
        final school=await viewWalletRepository.fetchTransactionHistories();
        yield WalletBalanceLoaded(school);
      }  on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is PauseOrCancelAdvertEvent){
      yield AdvertsProcessing();
      try{
        final message=await viewAdvertsRepository.pauseOrCancelAdvert(adCampaignId: event.adCampaignId, option: event.option);
        yield AdvertPausedOrCancelled(message: message);
      }  on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }else if(event is RestartAdvertEvent){
      yield AdvertsProcessing();
      try{
        final message=await viewAdvertsRepository.restartAdvert(adCampaignId: event.adCampaignId);
        yield AdvertRestarted(message: message);
      }  on NetworkError{
        yield AdvertNetworkErr(MyStrings.networkErrorMessage);
      }on ApiException catch(e){
        yield AdvertViewError(message: e.toString());
      }on SystemError{
        yield AdvertNetworkErr(MyStrings.systemErrorMessage);
      }
    }

  }

}