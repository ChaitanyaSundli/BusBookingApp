// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingResponse _$CreateBookingResponseFromJson(
  Map<String, dynamic> json,
) => CreateBookingResponse(
  success: json['success'] as bool,
  bookingId: (json['booking_id'] as num?)?.toInt(),
  seats: (json['seats'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  totalPrice: (json['total_price'] as num?)?.toDouble(),
  paymentId: (json['payment_id'] as num?)?.toInt(),
  status: json['status'] as String?,
  error: json['error'] as String?,
  errors: json['errors'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CreateBookingResponseToJson(
  CreateBookingResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'booking_id': instance.bookingId,
  'seats': instance.seats,
  'total_price': instance.totalPrice,
  'payment_id': instance.paymentId,
  'status': instance.status,
  'error': instance.error,
  'errors': instance.errors,
};

CancelBookingResponse _$CancelBookingResponseFromJson(
  Map<String, dynamic> json,
) => CancelBookingResponse(
  success: json['success'] as bool,
  status: json['status'] as String?,
  message: json['message'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$CancelBookingResponseToJson(
  CancelBookingResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'status': instance.status,
  'message': instance.message,
  'error': instance.error,
};
