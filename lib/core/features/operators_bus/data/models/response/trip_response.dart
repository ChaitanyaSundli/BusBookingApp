import 'package:json_annotation/json_annotation.dart';
import 'trip_model.dart';

part 'trip_response.g.dart';

@JsonSerializable()
class TripResponse {
  final String message;
  final int count;
  final List<TripModel> data;

  TripResponse({
    required this.message,
    required this.count,
    required this.data,
  });

  factory TripResponse.fromJson(Map<String, dynamic> json) =>
      _$TripResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TripResponseToJson(this);
}