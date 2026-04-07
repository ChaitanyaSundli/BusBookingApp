import 'package:json_annotation/json_annotation.dart';
import 'package:quick_bus/core/features/home/data/models/stop_model.dart';


part 'stops_wrapper.g.dart';

@JsonSerializable()
class StopsWrapper {

  final List<StopModel> data;
  final String message;

  StopsWrapper({required this.data, required this.message});

  factory StopsWrapper.fromJson(Map<String, dynamic> json) =>
      _$StopsWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$StopsWrapperToJson(this);
}
