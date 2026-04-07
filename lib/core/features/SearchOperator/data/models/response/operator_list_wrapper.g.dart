// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_list_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperatorListWrapper _$OperatorListWrapperFromJson(Map<String, dynamic> json) =>
    OperatorListWrapper(
      data: (json['data'] as List<dynamic>)
          .map((e) => OperatorListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$OperatorListWrapperToJson(
  OperatorListWrapper instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'count': instance.count,
};
