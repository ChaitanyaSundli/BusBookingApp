import 'package:json_annotation/json_annotation.dart';

part 'stop_model.g.dart';

@JsonSerializable()
class StopModel {

  @JsonKey(name: "city_name")
  final String cityName;

  StopModel({required this.cityName});

  factory StopModel.fromJson(Map<String, dynamic> json) =>
      _$StopModelFromJson(json);

  Map<String, dynamic> toJson() => _$StopModelToJson(this);
}
