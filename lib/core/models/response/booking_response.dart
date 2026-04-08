// lib/core/features/booking/data/models/response/booking_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'booking_response.g.dart';

@JsonSerializable()
class CreateBookingResponse {
  final bool success;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  final List<int>? seats;
  @JsonKey(name: 'total_price')
  final double? totalPrice;
  @JsonKey(name: 'payment_id')
  final int? paymentId;
  final String? status;
  final String? error;
  final Map<String, dynamic>? errors;

  CreateBookingResponse({
    required this.success,
    this.bookingId,
    this.seats,
    this.totalPrice,
    this.paymentId,
    this.status,
    this.error,
    this.errors,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookingResponseToJson(this);
}

@JsonSerializable()
class CancelBookingResponse {
  final bool success;
  final String? status;
  final String? message;
  final String? error;

  CancelBookingResponse({
    required this.success,
    this.status,
    this.message,
    this.error,
  });

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CancelBookingResponseToJson(this);
}