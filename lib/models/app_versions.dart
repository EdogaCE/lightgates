import 'package:equatable/equatable.dart';

class AppVersions extends Equatable {
  final String androidVersion;
  final String iosVersion;
  final String androidPlayStoreLink;
  final String iosAppStoreLink;

  AppVersions({this.androidVersion, this.iosVersion, this.androidPlayStoreLink, this.iosAppStoreLink});

  @override
  // TODO: implement props
  List<Object> get props => [androidVersion, iosVersion, androidPlayStoreLink, iosAppStoreLink];
}
