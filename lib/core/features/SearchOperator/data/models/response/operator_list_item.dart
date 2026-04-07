import 'package:json_annotation/json_annotation.dart';

part 'operator_list_item.g.dart';

@JsonSerializable()
class OperatorListItem {
  // operator_id: operator.id,
  // operator_name: operator.company_name,
  // total_buses: operator_trips.count,
  // lowest_price: operator_trips
  @JsonKey(name: "operator_id")
  final int operatorId;
  @JsonKey(name: "operator_name")
  final String operatorName;
  @JsonKey(name: "total_buses")
  final int totalBuses;
  @JsonKey(name: "lowest_price")
  final double lowestPrice;

  OperatorListItem({
    required this.operatorId,
    required this.operatorName,
    required this.totalBuses,
    required this.lowestPrice,
  });
  factory OperatorListItem.fromJson(Map<String, dynamic> json) =>
      _$OperatorListItemFromJson(json);

  Map<String, dynamic> toJson() => _$OperatorListItemToJson(this);
}
