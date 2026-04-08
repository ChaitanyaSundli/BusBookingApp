// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingRequest _$CreateBookingRequestFromJson(
  Map<String, dynamic> json,
) => CreateBookingRequest(
  tripId: (json['trip_id'] as num).toInt(),
  boardingStopId: (json['boarding_stop_id'] as num).toInt(),
  dropStopId: (json['drop_stop_id'] as num).toInt(),
  seatIds: (json['seat_ids'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  passengers: (json['passengers'] as List<dynamic>)
      .map((e) => PassengerRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateBookingRequestToJson(
  CreateBookingRequest instance,
) => <String, dynamic>{
  'trip_id': instance.tripId,
  'boarding_stop_id': instance.boardingStopId,
  'drop_stop_id': instance.dropStopId,
  'seat_ids': instance.seatIds,
  'passengers': instance.passengers,
};

PassengerRequest _$PassengerRequestFromJson(Map<String, dynamic> json) =>
    PassengerRequest(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: (json['gender'] as num).toInt(),
    );

Map<String, dynamic> _$PassengerRequestToJson(PassengerRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
    };
