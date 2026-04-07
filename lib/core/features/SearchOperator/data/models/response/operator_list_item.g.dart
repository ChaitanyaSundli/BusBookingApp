// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperatorListItem _$OperatorListItemFromJson(Map<String, dynamic> json) =>
    OperatorListItem(
      operatorId: (json['operator_id'] as num).toInt(),
      operatorName: json['operator_name'] as String,
      totalBuses: (json['total_buses'] as num).toInt(),
      lowestPrice: (json['lowest_price'] as num).toDouble(),
    );

Map<String, dynamic> _$OperatorListItemToJson(OperatorListItem instance) =>
    <String, dynamic>{
      'operator_id': instance.operatorId,
      'operator_name': instance.operatorName,
      'total_buses': instance.totalBuses,
      'lowest_price': instance.lowestPrice,
    };
