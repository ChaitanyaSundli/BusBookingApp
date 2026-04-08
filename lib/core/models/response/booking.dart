// lib/core/features/booking/data/models/booking.dart
import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  final int id;
  final String status;
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  final TripInfo trip;
  final List<BookingSeat> seats;

  Booking({
    required this.id,
    required this.status,
    this.paymentStatus,
    required this.trip,
    required this.seats,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}

@JsonSerializable()
class TripInfo {
  final int id;
  final String name;
  @JsonKey(name: 'departure_time')
  final String departureTime;
  @JsonKey(name: 'arrival_time')
  final String arrivalTime;
  @JsonKey(name: 'travel_date')
  final String travelDate;

  TripInfo({
    required this.id,
    required this.name,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelDate,
  });

  factory TripInfo.fromJson(Map<String, dynamic> json) => _$TripInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TripInfoToJson(this);
}

@JsonSerializable()
class BookingSeat {
  @JsonKey(name: 'seat_number')
  final String seatNumber;
  @JsonKey(name: 'seat_type')
  final String seatType;
  final String deck;
  final double price;

  BookingSeat({
    required this.seatNumber,
    required this.seatType,
    required this.deck,
    required this.price,
  });

  factory BookingSeat.fromJson(Map<String, dynamic> json) => _$BookingSeatFromJson(json);
  Map<String, dynamic> toJson() => _$BookingSeatToJson(this);
}