import 'package:equatable/equatable.dart';
import 'package:school_pal/models/ad_impression.dart';
import 'package:school_pal/models/currency.dart';

class Advert extends Equatable {
  final String id;
  final String uniqueId;
  final String userUniqueId;
  final String title;
  final String budget;
  final String startDate;
  final String endDate;
  final String driveTrafficTo;
  final String whatsAppNo;
  final String countryCode;
  final String websiteAppUrl;
  final String primaryText;
  final String description;
  final String image;
  final String imageUrl;
  final String status;
  final String amountSpent;
  final int totalReach;
  final int totalView;
  final int totalClick;
  final Currency preferredCurrency;
  final List<AdImpression> adImpressions;
  final bool deleted;

  Advert({this.id, this.uniqueId, this.userUniqueId, this.title, this.budget, this.startDate, this.endDate, this.driveTrafficTo, this.whatsAppNo, this.countryCode, this.websiteAppUrl, this.primaryText, this.description, this.image, this.imageUrl, this.status, this.amountSpent, this.totalReach, this.totalView, this.totalClick, this.preferredCurrency, this.adImpressions, this.deleted});

  @override
  // TODO: implement props
  List<Object> get props => [id, uniqueId, userUniqueId, title, budget, startDate, endDate, driveTrafficTo, whatsAppNo, countryCode, websiteAppUrl, primaryText, description, image, imageUrl, status, amountSpent, totalReach, totalView, totalClick, preferredCurrency, adImpressions, deleted];
}
