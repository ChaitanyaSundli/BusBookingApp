// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteStopModel _$RouteStopModelFromJson(Map<String, dynamic> json) =>
    RouteStopModel(
      id: (json['id'] as num).toInt(),
      stopname: json['stopname'] as String,
      cityname: json['cityname'] as String,
      address: json['address'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$RouteStopModelToJson(RouteStopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stopname': instance.stopname,
      'cityname': instance.cityname,
      'address': instance.address,
      'time': instance.time,
    };
