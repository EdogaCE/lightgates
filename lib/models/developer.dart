import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Developer extends Equatable {
  final String id;
  final String uniqueId;
  final String siteName;
  final String frontEndBaseUrl;
  final String backEndBaseUrl;
  final String loginUrl;
  final String registerUrl;
  final String phone1;
  final String phone2;
  final String emailAddress1;
  final String emailAddress2;
  final String address1;
  final String address2;
  final String facebook;
  final String instagram;
  final String twitter;
  final bool deleted;

  Developer({
    this.id,
    this.uniqueId,
    this.siteName,
    this.frontEndBaseUrl,
    this.backEndBaseUrl,
    this.loginUrl,
    this.registerUrl,
    this.phone1,
    this.phone2,
    this.emailAddress1,
    this.emailAddress2,
    this.address1,
    this.address2,
    this.facebook,
    this.instagram,
    this.twitter,
    this.deleted
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    siteName,
    frontEndBaseUrl,
    backEndBaseUrl,
    loginUrl,
    registerUrl,
    phone1,
    phone2,
    emailAddress1,
    emailAddress2,
    address1,
    address2,
    facebook,
    instagram,
    twitter,
    deleted
  ];
}