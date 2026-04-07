import 'package:json_annotation/json_annotation.dart';

part 'route_stop_model.g.dart';

@JsonSerializable()
class RouteStopModel {
  final int id;
  @JsonKey(name: 'stopname')
  final String stopname;
  @JsonKey(name: 'cityname')
  final String cityname;
  final String? address;
  final String? time;

  RouteStopModel({
    required this.id,
    required this.stopname,
    required this.cityname,
    this.address,
    this.time,
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) =>
      _$RouteStopModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteStopModelToJson(this);
}
