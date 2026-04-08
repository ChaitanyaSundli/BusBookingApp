import 'package:json_annotation/json_annotation.dart';
import 'package:quick_bus/core/models/response/trip.dart';

part 'trips_wrapper.g.dart';

@JsonSerializable()
class TripsWrapper {
  final String? message;
  final int? count;
  final List<Trip>? data;

  TripsWrapper({this.message, this.count, this.data});

  factory TripsWrapper.fromJson(Map<String, dynamic> json) =>
      _$TripsWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$TripsWrapperToJson(this);
}