import 'package:json_annotation/json_annotation.dart';

import 'operator_list_item.dart';

part 'operator_list_wrapper.g.dart';

@JsonSerializable()
class OperatorListWrapper {
  final List<OperatorListItem> data;
  final String message;
  final int count;

  OperatorListWrapper({
    required this.data,
    required this.message,
    required this.count,
  });

  factory OperatorListWrapper.fromJson(Map<String, dynamic> json) =>
      _$OperatorListWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$OperatorListWrapperToJson(this);
}
