// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopPoint _$StopPointFromJson(Map<String, dynamic> json) => StopPoint(
  id: (json['id'] as num).toInt(),
  cityName: json['city_name'] as String,
  stopName: json['stop_name'] as String,
  stopAddress: json['stop_address'] as String?,
  stopOrder: (json['stop_order'] as num).toInt(),
  kmFromSource: (json['km_from_source'] as num).toDouble(),
  scheduledArrivalTime: json['scheduled_arrival_time'] as String?,
  scheduledDepartureTime: json['scheduled_departure_time'] as String?,
  isBoardingPoint: json['is_boarding_point'] as bool,
  isDropPoint: json['is_drop_point'] as bool,
);

Map<String, dynamic> _$StopPointToJson(StopPoint instance) => <String, dynamic>{
  'id': instance.id,
  'city_name': instance.cityName,
  'stop_name': instance.stopName,
  'stop_address': instance.stopAddress,
  'stop_order': instance.stopOrder,
  'km_from_source': instance.kmFromSource,
  'scheduled_arrival_time': instance.scheduledArrivalTime,
  'scheduled_departure_time': instance.scheduledDepartureTime,
  'is_boarding_point': instance.isBoardingPoint,
  'is_drop_point': instance.isDropPoint,
};
