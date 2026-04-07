import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class TripModel {
  final int id;

  @JsonKey(name: 'departure_time')
  final String departureTime;

  @JsonKey(name: 'arrival_time')
  final String arrivalTime;

  @JsonKey(name: 'available_seats')
  final int availableSeats;

  @JsonKey(name: 'duration_mins')
  final int durationMins;

  final double? price;
  final BusModel bus;
  final OperatorModel operator;

  TripModel({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
    required this.durationMins,
    required this.price,
    required this.bus,
    required this.operator,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}

@JsonSerializable()
class BusModel {
  final int? id;
  final String? name;
  final String? number;
  final int? type;
  final int? deck;

  BusModel({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.deck,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) =>
      _$BusModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusModelToJson(this);
}

@JsonSerializable()
class OperatorModel {
  final int id;
  final String name;

  OperatorModel({
    required this.id,
    required this.name,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) =>
      _$OperatorModelFromJson(json);

  Map<String, dynamic> toJson() => _$OperatorModelToJson(this);
}
