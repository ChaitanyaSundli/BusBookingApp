// lib/core/features/booking/data/models/request/booking_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'booking_request.g.dart';

@JsonSerializable()
class CreateBookingRequest {
  @JsonKey(name: 'trip_id')
  final int tripId;
  @JsonKey(name: 'boarding_stop_id')
  final int boardingStopId;
  @JsonKey(name: 'drop_stop_id')
  final int dropStopId;
  @JsonKey(name: 'seat_ids')
  final List<int> seatIds;
  final List<PassengerRequest> passengers;

  CreateBookingRequest({
    required this.tripId,
    required this.boardingStopId,
    required this.dropStopId,
    required this.seatIds,
    required this.passengers,
  });

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookingRequestToJson(this);
}

// lib/core/features/booking/data/models/request/booking_request.dart
@JsonSerializable()
class PassengerRequest {
  final String name;
  final int age;
  final int gender; // ✅ Changed to int

  PassengerRequest({
    required this.name,
    required this.age,
    required this.gender,
  });

  factory PassengerRequest.fromJson(Map<String, dynamic> json) =>
      _$PassengerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PassengerRequestToJson(this);
}