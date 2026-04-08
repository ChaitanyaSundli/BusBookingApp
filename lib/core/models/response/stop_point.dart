// lib/core/features/trips/data/models/stop_point.dart
import 'package:json_annotation/json_annotation.dart';

part 'stop_point.g.dart';

@JsonSerializable()
class StopPoint {
  final int id;
  @JsonKey(name: 'city_name')
  final String cityName;
  @JsonKey(name: 'stop_name')
  final String stopName;
  @JsonKey(name: 'stop_address')
  final String? stopAddress;
  @JsonKey(name: 'stop_order')
  final int stopOrder;
  @JsonKey(name: 'km_from_source')
  final double kmFromSource;
  @JsonKey(name: 'scheduled_arrival_time')
  final String? scheduledArrivalTime;
  @JsonKey(name: 'scheduled_departure_time')
  final String? scheduledDepartureTime;
  @JsonKey(name: 'is_boarding_point')
  final bool isBoardingPoint;
  @JsonKey(name: 'is_drop_point')
  final bool isDropPoint;

  StopPoint({
    required this.id,
    required this.cityName,
    required this.stopName,
    this.stopAddress,
    required this.stopOrder,
    required this.kmFromSource,
    this.scheduledArrivalTime,
    this.scheduledDepartureTime,
    required this.isBoardingPoint,
    required this.isDropPoint,
  });

  factory StopPoint.fromJson(Map<String, dynamic> json) => _$StopPointFromJson(json);
  Map<String, dynamic> toJson() => _$StopPointToJson(this);
}