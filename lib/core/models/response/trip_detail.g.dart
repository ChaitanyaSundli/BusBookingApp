// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripDetail _$TripDetailFromJson(Map<String, dynamic> json) => TripDetail(
  id: (json['id'] as num?)?.toInt(),
  travelStartDate: json['travel_start_date'] as String?,
  departureTime: json['departure_time'] as String?,
  arrivalTime: json['arrival_time'] as String?,
  status: json['status'] as String?,
  availableSeats: (json['available_seats'] as num?)?.toInt(),
  bus: json['bus'] == null
      ? null
      : Bus.fromJson(json['bus'] as Map<String, dynamic>),
  route: json['route'] == null
      ? null
      : Route.fromJson(json['route'] as Map<String, dynamic>),
  operator: json['operator'] == null
      ? null
      : Operator.fromJson(json['operator'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
  tripSeats: (json['trip_seats'] as List<dynamic>?)
      ?.map((e) => TripSeatDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripDetailToJson(TripDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'travel_start_date': instance.travelStartDate,
      'departure_time': instance.departureTime,
      'arrival_time': instance.arrivalTime,
      'status': instance.status,
      'available_seats': instance.availableSeats,
      'bus': instance.bus,
      'route': instance.route,
      'operator': instance.operator,
      'created_at': instance.createdAt,
      'trip_seats': instance.tripSeats,
    };

TripSeatDetail _$TripSeatDetailFromJson(Map<String, dynamic> json) =>
    TripSeatDetail(
      id: (json['id'] as num?)?.toInt(),
      seatNumber: json['seat_number'] as String?,
      seatType: json['seat_type'] as String?,
      deck: json['deck'] as String?,
      seatPrice: (json['seat_price'] as num?)?.toDouble(),
      status: json['status'] as String?,
      rowNumber: (json['row_number'] as num?)?.toInt(),
      colNumberFromJson: (json['col_number'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TripSeatDetailToJson(TripSeatDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seat_number': instance.seatNumber,
      'seat_type': instance.seatType,
      'deck': instance.deck,
      'seat_price': instance.seatPrice,
      'status': instance.status,
      'row_number': instance.rowNumber,
      'col_number': instance.colNumberFromJson,
    };
