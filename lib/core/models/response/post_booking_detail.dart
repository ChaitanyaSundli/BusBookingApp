// lib/core/features/booking/data/models/post_booking_detail.dart
import 'package:json_annotation/json_annotation.dart';

part 'post_booking_detail.g.dart';

@JsonSerializable()
class PostBookingDetail {
  final int id;
  final String status;
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  @JsonKey(name: 'boarding_stop')
  final BoardingStop boardingStop;
  @JsonKey(name: 'drop_stop')
  final DropStop dropStop;
  final List<Passenger> passengers;
  @JsonKey(name: 'booking_seats')
  final List<DetailedBookingSeat> bookingSeats;
  final PostTripDetail trip;

  PostBookingDetail({
    required this.id,
    required this.status,
    this.paymentStatus,
    required this.boardingStop,
    required this.dropStop,
    required this.passengers,
    required this.bookingSeats,
    required this.trip,
  });

  factory PostBookingDetail.fromJson(Map<String, dynamic> json) =>
      _$PostBookingDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PostBookingDetailToJson(this);
}

@JsonSerializable()
class BoardingStop {
  final int id;
  @JsonKey(name: 'stop_name')
  final String stopName;
  @JsonKey(name: 'city_name')
  final String cityName;

  BoardingStop({required this.id, required this.stopName, required this.cityName});

  factory BoardingStop.fromJson(Map<String, dynamic> json) =>
      _$BoardingStopFromJson(json);
  Map<String, dynamic> toJson() => _$BoardingStopToJson(this);
}

@JsonSerializable()
class DropStop {
  final int id;
  @JsonKey(name: 'stop_name')
  final String stopName;
  @JsonKey(name: 'city_name')
  final String cityName;

  DropStop({required this.id, required this.stopName, required this.cityName});

  factory DropStop.fromJson(Map<String, dynamic> json) => _$DropStopFromJson(json);
  Map<String, dynamic> toJson() => _$DropStopToJson(this);
}

@JsonSerializable()
class Passenger {
  final int id;
  final String name;
  final int age;
  final String gender;

  Passenger({required this.id, required this.name, required this.age, required this.gender});

  factory Passenger.fromJson(Map<String, dynamic> json) => _$PassengerFromJson(json);
  Map<String, dynamic> toJson() => _$PassengerToJson(this);
}

@JsonSerializable()
class DetailedBookingSeat {
  @JsonKey(name: 'seat_price')
  final double seatPrice;
  @JsonKey(name: 'trip_seat')
  final TripSeat tripSeat;
  final Passenger passenger;

  DetailedBookingSeat({
    required this.seatPrice,
    required this.tripSeat,
    required this.passenger,
  });

  factory DetailedBookingSeat.fromJson(Map<String, dynamic> json) =>
      _$DetailedBookingSeatFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedBookingSeatToJson(this);
}

@JsonSerializable()
class TripSeat {
  @JsonKey(name: 'seat_price')
  final double seatPrice;
  final Seat seat;

  TripSeat({required this.seatPrice, required this.seat});

  factory TripSeat.fromJson(Map<String, dynamic> json) => _$TripSeatFromJson(json);
  Map<String, dynamic> toJson() => _$TripSeatToJson(this);
}

@JsonSerializable()
class Seat {
  @JsonKey(name: 'seat_number')
  final String seatNumber;
  @JsonKey(name: 'seat_type')
  final String seatType;
  final String deck;

  Seat({
    required this.seatNumber,
    required this.seatType,
    required this.deck,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}

@JsonSerializable()
class PostTripDetail {
  final int id;
  @JsonKey(name: 'departure_time')
  final String departureTime;
  @JsonKey(name: 'arrival_time')
  final String arrivalTime;
  @JsonKey(name: 'travel_start_date')
  final String travelStartDate;
  final Route route;

  PostTripDetail({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelStartDate,
    required this.route,
  });

  factory PostTripDetail.fromJson(Map<String, dynamic> json) => _$PostTripDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PostTripDetailToJson(this);
}

@JsonSerializable()
class Route {
  @JsonKey(name: 'source_city')
  final String sourceCity;
  @JsonKey(name: 'destination_city')
  final String destinationCity;
  @JsonKey(name: 'total_distance_km')
  final double totalDistanceKm;
  @JsonKey(name: 'route_stops')
  final List<RouteStop> routeStops;

  Route({
    required this.sourceCity,
    required this.destinationCity,
    required this.totalDistanceKm,
    required this.routeStops,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);
}

@JsonSerializable()
class RouteStop {
  final int id;
  @JsonKey(name: 'stop_name')
  final String stopName;
  @JsonKey(name: 'city_name')
  final String cityName;
  @JsonKey(name: 'stop_order')
  final int stopOrder;

  RouteStop({
    required this.id,
    required this.stopName,
    required this.cityName,
    required this.stopOrder,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) => _$RouteStopFromJson(json);
  Map<String, dynamic> toJson() => _$RouteStopToJson(this);
}