import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:school_pal/models/contact.dart';

class Group extends Equatable {
  final String id;
  final String uniqueId;
  final String schoolId;
  final String creatorId;
  final String creatorType;
  final String name;
  final String description;
  final String memberIds;
  final String image;
  final String imageLink;
  final List<Contact> members;
  final String date;
  final bool deleted;

  Group({
    this.id,
    this.uniqueId,
    this.schoolId,
    this.creatorId,
    this.creatorType,
    this.name,
    this.description,
    this.memberIds,
    this.image,
    this.imageLink,
    this.members,
    this.date,
    this.deleted
  });

  @override
  List<Object> get props => [
    id,
    uniqueId,
    schoolId,
    creatorId,
    creatorType,
    name,
    description,
    memberIds,
    image,
    imageLink,
    members,
    date,
    deleted
  ];
}