import 'package:equatable/equatable.dart';

abstract class AdvertEvents extends Equatable{
  const AdvertEvents();
}


class ViewAdvertsEvent extends AdvertEvents{
  final String userUniqueId;
  const ViewAdvertsEvent({this.userUniqueId});
  @override
  // TODO: implement props
  List<Object> get props => [userUniqueId];

}

class ViewUserAdvertsEvent extends AdvertEvents{
  const ViewUserAdvertsEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class CreateAdvertsEvent extends AdvertEvents{
  const CreateAdvertsEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class CaptureAdImpressionEvent extends AdvertEvents{
  final String userUniqueId;
  final String adUniqueId;
  final String impression;
  final int nextPosition;
  final bool randomly;
  CaptureAdImpressionEvent({this.userUniqueId, this.adUniqueId, this.impression, this.nextPosition, this.randomly});
  @override
  // TODO: implement props
  List<Object> get props => [userUniqueId, adUniqueId, impression, nextPosition, randomly];
}

class CreateAdCampaignEvent extends AdvertEvents{
  final String budget;
  final String startDate;
  final String endDate;
  final String driveTrafficTo;
  final String caption;
  final String webAppUrl;
  final String webUrl;
  final String appUrl;
  final String whatsAppNo;
  final String countryCode;
  final List<String> images;
  CreateAdCampaignEvent({this.budget, this.startDate, this.endDate, this.driveTrafficTo, this.caption, this.webAppUrl, this.webUrl, this.appUrl, this.whatsAppNo, this.countryCode, this.images});
  @override
  // TODO: implement props
  List<Object> get props => [budget, startDate, endDate, driveTrafficTo, caption, webAppUrl, whatsAppNo, countryCode, images];
}

class UpdateAdCampaignEvent extends AdvertEvents{
  final String addCampaignId;
  final String budget;
  final String startDate;
  final String endDate;
  final String driveTrafficTo;
  final String caption;
  final String webAppUrl;
  final String webUrl;
  final String appUrl;
  final String whatsAppNo;
  final String countryCode;
  final List<String> images;
  UpdateAdCampaignEvent({this.addCampaignId, this.budget, this.startDate, this.endDate, this.driveTrafficTo, this.caption, this.webAppUrl, this.webUrl, this.appUrl, this.whatsAppNo, this.countryCode, this.images});
  @override
  // TODO: implement props
  List<Object> get props => [addCampaignId, budget, startDate, endDate, driveTrafficTo, caption, webAppUrl, whatsAppNo, countryCode, images];
}

class ChangeDateFromEvent extends AdvertEvents{
  final DateTime from;
  const ChangeDateFromEvent(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class ChangeDateToEvent extends AdvertEvents{
  final DateTime to;
  const ChangeDateToEvent(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class ChangeDriveTrafficToEvent extends AdvertEvents {
  final String value;
  const ChangeDriveTrafficToEvent(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class SelectImageEvent extends AdvertEvents {
  final String path;
  const SelectImageEvent(this.path);
  @override
  // TODO: implement props
  List<Object> get props => [path];
}

class ValidateAdvertEvent extends AdvertEvents {
  final String budget;
  final String startDate;
  final String endDate;
  const ValidateAdvertEvent({this.budget, this.startDate, this.endDate});
  @override
  // TODO: implement props
  List<Object> get props => [budget, startDate, endDate];
}

class ViewWalletBalanceEvent extends AdvertEvents{
  const ViewWalletBalanceEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class PauseOrCancelAdvertEvent extends AdvertEvents {
  final String adCampaignId;
  final String option;
  const PauseOrCancelAdvertEvent({this.adCampaignId, this.option});
  @override
  // TODO: implement props
  List<Object> get props => [adCampaignId, option];
}

class RestartAdvertEvent extends AdvertEvents {
  final String adCampaignId;
  const RestartAdvertEvent({this.adCampaignId});
  @override
  // TODO: implement props
  List<Object> get props => [adCampaignId];
}