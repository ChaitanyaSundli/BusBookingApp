// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripsWrapper _$TripsWrapperFromJson(Map<String, dynamic> json) => TripsWrapper(
  message: json['message'] as String?,
  count: (json['count'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Trip.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripsWrapperToJson(TripsWrapper instance) =>
    <String, dynamic>{
      'message': instance.message,
      'count': instance.count,
      'data': instance.data,
    };
