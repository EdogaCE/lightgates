import 'dart:convert';
import 'package:equatable/equatable.dart';

class LocalData extends Equatable {
  final int id;
  final String title;
  final String data;

  LocalData({this.id, this.title, this.data});

  @override
  // TODO: implement props
  List<Object> get props => [id, title, data];

  LocalData dataFromJson(String str) {
    final jsonData = json.decode(str);
    return LocalData.fromMap(jsonData);
  }

  String dataToJson(LocalData data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  factory LocalData.fromMap(Map<String, dynamic> json) => new LocalData(
    id: json["id"],
    title: json["title"],
    data: json["data"]
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "data": data
  };

}
