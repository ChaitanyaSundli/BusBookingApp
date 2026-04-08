// lib/core/features/trips/data/models/trip.dart
import 'package:json_annotation/json_annotation.dart';

part 'trip.g.dart';

@JsonSerializable()
class Trip {
  final int? id;
  @JsonKey(name: 'travel_start_date')
  final String? travelStartDate;
  @JsonKey(name: 'departure_time')
  final String? departureTime;
  @JsonKey(name: 'arrival_time')
  final String? arrivalTime;
  final String? status;
  @JsonKey(name: 'available_seats')
  final int? availableSeats;
  final Bus? bus;
  final Route? route;
  final Operator? operator;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'trip_seats')
  final List<TripSeatPrice>? tripSeats;

  Trip({
    this.id,
    this.travelStartDate,
    this.departureTime,
    this.arrivalTime,
    this.status,
    this.availableSeats,
    this.bus,
    this.route,
    this.operator,
    this.createdAt,
    this.tripSeats,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);
}

@JsonSerializable()
class Bus {
  final int? id;
  @JsonKey(name: 'bus_name')
  final String? busName;
  @JsonKey(name: 'bus_type')
  final String? busType;
  @JsonKey(name: 'bus_no')
  final String? busNo;
  final int? deck;

  Bus({
    this.id,
    this.busName,
    this.busType,
    this.busNo,
    this.deck,
  });

  factory Bus.fromJson(Map<String, dynamic> json) => _$BusFromJson(json);
  Map<String, dynamic> toJson() => _$BusToJson(this);
}

@JsonSerializable()
class Route {
  final int? id;
  @JsonKey(name: 'source_city')
  final String? sourceCity;
  @JsonKey(name: 'destination_city')
  final String? destinationCity;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  @JsonKey(name: 'route_stops')
  final List<RouteStop>? routeStops;

  Route({
    this.id,
    this.sourceCity,
    this.destinationCity,
    this.distanceKm,
    this.routeStops,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

@JsonSerializable()
class RouteStop {
  final int? id;
  @JsonKey(name: 'city_name')
  final String? cityName;
  @JsonKey(name: 'stop_name')
  final String? stopName;
  @JsonKey(name: 'stop_order')
  final int? stopOrder;
  @JsonKey(name: 'km_from_source')
  final double? kmFromSource;
  @JsonKey(name: 'is_boarding_point')
  final bool? isBoardingPoint;
  @JsonKey(name: 'is_drop_point')
  final bool? isDropPoint;

  RouteStop({
    this.id,
    this.cityName,
    this.stopName,
    this.stopOrder,
    this.kmFromSource,
    this.isBoardingPoint,
    this.isDropPoint,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) => _$RouteStopFromJson(json);
  Map<String, dynamic> toJson() => _$RouteStopToJson(this);
}

@JsonSerializable()
class Operator {
  final int? id;
  @JsonKey(name: 'company_name')
  final String? companyName;

  Operator({
    this.id,
    this.companyName,
  });

  factory Operator.fromJson(Map<String, dynamic> json) => _$OperatorFromJson(json);
  Map<String, dynamic> toJson() => _$OperatorToJson(this);
}

@JsonSerializable()
class TripSeatPrice {
  final int? id;
  @JsonKey(name: 'seat_price')
  final double? seatPrice;

  TripSeatPrice({
    this.id,
    this.seatPrice,
  });

  factory TripSeatPrice.fromJson(Map<String, dynamic> json) => _$TripSeatPriceFromJson(json);
  Map<String, dynamic> toJson() => _$TripSeatPriceToJson(this);
}