// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  paymentStatus: json['payment_status'] as String?,
  trip: TripInfo.fromJson(json['trip'] as Map<String, dynamic>),
  seats: (json['seats'] as List<dynamic>)
      .map((e) => BookingSeat.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'payment_status': instance.paymentStatus,
  'trip': instance.trip,
  'seats': instance.seats,
};

TripInfo _$TripInfoFromJson(Map<String, dynamic> json) => TripInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  departureTime: json['departure_time'] as String,
  arrivalTime: json['arrival_time'] as String,
  travelDate: json['travel_date'] as String,
);

Map<String, dynamic> _$TripInfoToJson(TripInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'departure_time': instance.departureTime,
  'arrival_time': instance.arrivalTime,
  'travel_date': instance.travelDate,
};

BookingSeat _$BookingSeatFromJson(Map<String, dynamic> json) => BookingSeat(
  seatNumber: json['seat_number'] as String,
  seatType: json['seat_type'] as String,
  deck: json['deck'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$BookingSeatToJson(BookingSeat instance) =>
    <String, dynamic>{
      'seat_number': instance.seatNumber,
      'seat_type': instance.seatType,
      'deck': instance.deck,
      'price': instance.price,
    };
