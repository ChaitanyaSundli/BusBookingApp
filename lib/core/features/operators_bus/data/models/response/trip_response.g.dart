// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripResponse _$TripResponseFromJson(Map<String, dynamic> json) => TripResponse(
  message: json['message'] as String,
  count: (json['count'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripResponseToJson(TripResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'count': instance.count,
      'data': instance.data,
    };
