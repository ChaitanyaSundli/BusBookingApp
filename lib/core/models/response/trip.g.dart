// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
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
      ?.map((e) => TripSeatPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
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

Bus _$BusFromJson(Map<String, dynamic> json) => Bus(
  id: (json['id'] as num?)?.toInt(),
  busName: json['bus_name'] as String?,
  busType: json['bus_type'] as String?,
  busNo: json['bus_no'] as String?,
  deck: (json['deck'] as num?)?.toInt(),
);

Map<String, dynamic> _$BusToJson(Bus instance) => <String, dynamic>{
  'id': instance.id,
  'bus_name': instance.busName,
  'bus_type': instance.busType,
  'bus_no': instance.busNo,
  'deck': instance.deck,
};

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
  id: (json['id'] as num?)?.toInt(),
  sourceCity: json['source_city'] as String?,
  destinationCity: json['destination_city'] as String?,
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
  routeStops: (json['route_stops'] as List<dynamic>?)
      ?.map((e) => RouteStop.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
  'id': instance.id,
  'source_city': instance.sourceCity,
  'destination_city': instance.destinationCity,
  'distance_km': instance.distanceKm,
  'route_stops': instance.routeStops,
};

RouteStop _$RouteStopFromJson(Map<String, dynamic> json) => RouteStop(
  id: (json['id'] as num?)?.toInt(),
  cityName: json['city_name'] as String?,
  stopName: json['stop_name'] as String?,
  stopOrder: (json['stop_order'] as num?)?.toInt(),
  kmFromSource: (json['km_from_source'] as num?)?.toDouble(),
  isBoardingPoint: json['is_boarding_point'] as bool?,
  isDropPoint: json['is_drop_point'] as bool?,
);

Map<String, dynamic> _$RouteStopToJson(RouteStop instance) => <String, dynamic>{
  'id': instance.id,
  'city_name': instance.cityName,
  'stop_name': instance.stopName,
  'stop_order': instance.stopOrder,
  'km_from_source': instance.kmFromSource,
  'is_boarding_point': instance.isBoardingPoint,
  'is_drop_point': instance.isDropPoint,
};

Operator _$OperatorFromJson(Map<String, dynamic> json) => Operator(
  id: (json['id'] as num?)?.toInt(),
  companyName: json['company_name'] as String?,
);

Map<String, dynamic> _$OperatorToJson(Operator instance) => <String, dynamic>{
  'id': instance.id,
  'company_name': instance.companyName,
};

TripSeatPrice _$TripSeatPriceFromJson(Map<String, dynamic> json) =>
    TripSeatPrice(
      id: (json['id'] as num?)?.toInt(),
      seatPrice: (json['seat_price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TripSeatPriceToJson(TripSeatPrice instance) =>
    <String, dynamic>{'id': instance.id, 'seat_price': instance.seatPrice};
