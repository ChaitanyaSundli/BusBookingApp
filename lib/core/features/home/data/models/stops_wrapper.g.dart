// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stops_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopsWrapper _$StopsWrapperFromJson(Map<String, dynamic> json) => StopsWrapper(
  data: (json['data'] as List<dynamic>)
      .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String,
);

Map<String, dynamic> _$StopsWrapperToJson(StopsWrapper instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};
