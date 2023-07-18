import 'package:equatable/equatable.dart';
import 'package:school_pal/models/advert.dart';
import 'package:school_pal/models/school.dart';

abstract class AdvertStates extends Equatable{
  const AdvertStates();
}

class AdvertInitialState extends AdvertStates{
  const AdvertInitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class AdvertsLoading extends AdvertStates{
  const AdvertsLoading();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AdvertsProcessing extends AdvertStates{
  const AdvertsProcessing();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AdvertsLoaded extends AdvertStates{
  final List<Advert> adverts;
  const AdvertsLoaded(this.adverts);
  @override
  // TODO: implement props
  List<Object> get props => [adverts];
}

class ImpressionCaptured extends AdvertStates{
  final List<Advert> adverts;
  final String impression;
  final int nextPosition;
  final bool randomly;
  const ImpressionCaptured({this.adverts, this.impression, this.nextPosition, this.randomly});
  @override
  // TODO: implement props
  List<Object> get props => [adverts, impression, nextPosition, randomly];
}

class AdCampaignCreated extends AdvertStates{
  final String message;
  const AdCampaignCreated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class AdCampaignUpdated extends AdvertStates{
  final String message;
  const AdCampaignUpdated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class AdvertValidated extends AdvertStates{
  final String message;
  const AdvertValidated(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class AdvertPausedOrCancelled extends AdvertStates {
  final String message;
  const AdvertPausedOrCancelled({this.message});
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class AdvertRestarted extends AdvertStates {
  final String message;
  const AdvertRestarted({this.message});
  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class DateFromChanged extends AdvertStates{
  final DateTime from;
  const DateFromChanged(this.from);
  @override
  // TODO: implement props
  List<Object> get props => [from];

}

class DateToChanged extends AdvertStates{
  final DateTime to;
  const DateToChanged(this.to);
  @override
  // TODO: implement props
  List<Object> get props => [to];

}

class DriveTrafficToChanged extends AdvertStates {
  final String value;
  const DriveTrafficToChanged(this.value);
  @override
  // TODO: implement props
  List<Object> get props => [value];
}

class ImageSelected extends AdvertStates {
  final String path;
  const ImageSelected(this.path);
  @override
  // TODO: implement props
  List<Object> get props => [path];
}

class WalletBalanceLoaded extends AdvertStates{
  final List<School> school;
  const WalletBalanceLoaded(this.school);
  @override
  // TODO: implement props
  List<Object> get props => [school];
}

class AdvertViewError extends AdvertStates{
  final String message;
  final String impression;
  final int nextPosition;
  final bool randomly;
  const AdvertViewError({this.message, this.impression, this.nextPosition, this.randomly});
  @override
  // TODO: implement props
  List<Object> get props => [message, impression, nextPosition, randomly];
}

class AdvertNetworkErr extends AdvertStates{
  final String message;
  const AdvertNetworkErr(this.message);
  @override
  // TODO: implement props
  List<Object> get props => [message];
}
