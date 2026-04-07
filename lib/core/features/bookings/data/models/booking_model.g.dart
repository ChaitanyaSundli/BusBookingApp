// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: (json['id'] as num).toInt(),
  tripId: (json['trip_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  boardingStopId: (json['boarding_stop_id'] as num?)?.toInt(),
  dropStopId: (json['drop_stop_id'] as num?)?.toInt(),
  status: json['status'] as String,
  totalPrice: (json['total_price'] as num).toDouble(),
  createdAt: json['created_at'] as String?,
  trip: json['trip'] == null
      ? null
      : TripModel.fromJson(json['trip'] as Map<String, dynamic>),
  passengers: (json['passengers'] as List<dynamic>?)
      ?.map((e) => PassengerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'user_id': instance.userId,
      'boarding_stop_id': instance.boardingStopId,
      'drop_stop_id': instance.dropStopId,
      'status': instance.status,
      'total_price': instance.totalPrice,
      'created_at': instance.createdAt,
      'trip': instance.trip,
      'passengers': instance.passengers,
    };

PassengerModel _$PassengerModelFromJson(Map<String, dynamic> json) =>
    PassengerModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      age: (json['age'] as num).toInt(),
      gender: (json['gender'] as num).toInt(),
    );

Map<String, dynamic> _$PassengerModelToJson(PassengerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'age': instance.age,
      'gender': instance.gender,
    };
