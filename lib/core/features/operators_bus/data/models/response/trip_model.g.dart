// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
  id: (json['id'] as num).toInt(),
  departureTime: json['departure_time'] as String,
  arrivalTime: json['arrival_time'] as String,
  availableSeats: (json['available_seats'] as num).toInt(),
  durationMins: (json['duration_mins'] as num).toInt(),
  price: (json['price'] as num?)?.toDouble(),
  bus: BusModel.fromJson(json['bus'] as Map<String, dynamic>),
  operator: OperatorModel.fromJson(json['operator'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
  'id': instance.id,
  'departure_time': instance.departureTime,
  'arrival_time': instance.arrivalTime,
  'available_seats': instance.availableSeats,
  'duration_mins': instance.durationMins,
  'price': instance.price,
  'bus': instance.bus,
  'operator': instance.operator,
};

BusModel _$BusModelFromJson(Map<String, dynamic> json) => BusModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  number: json['number'] as String?,
  type: (json['type'] as num?)?.toInt(),
  deck: (json['deck'] as num?)?.toInt(),
);

Map<String, dynamic> _$BusModelToJson(BusModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'number': instance.number,
  'type': instance.type,
  'deck': instance.deck,
};

OperatorModel _$OperatorModelFromJson(Map<String, dynamic> json) =>
    OperatorModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$OperatorModelToJson(OperatorModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
