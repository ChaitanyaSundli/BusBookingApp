// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_booking_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostBookingDetail _$PostBookingDetailFromJson(Map<String, dynamic> json) =>
    PostBookingDetail(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String?,
      boardingStop: BoardingStop.fromJson(
        json['boarding_stop'] as Map<String, dynamic>,
      ),
      dropStop: DropStop.fromJson(json['drop_stop'] as Map<String, dynamic>),
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => Passenger.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookingSeats: (json['booking_seats'] as List<dynamic>)
          .map((e) => DetailedBookingSeat.fromJson(e as Map<String, dynamic>))
          .toList(),
      trip: PostTripDetail.fromJson(json['trip'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostBookingDetailToJson(PostBookingDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'payment_status': instance.paymentStatus,
      'boarding_stop': instance.boardingStop,
      'drop_stop': instance.dropStop,
      'passengers': instance.passengers,
      'booking_seats': instance.bookingSeats,
      'trip': instance.trip,
    };

BoardingStop _$BoardingStopFromJson(Map<String, dynamic> json) => BoardingStop(
  id: (json['id'] as num).toInt(),
  stopName: json['stop_name'] as String,
  cityName: json['city_name'] as String,
);

Map<String, dynamic> _$BoardingStopToJson(BoardingStop instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stop_name': instance.stopName,
      'city_name': instance.cityName,
    };

DropStop _$DropStopFromJson(Map<String, dynamic> json) => DropStop(
  id: (json['id'] as num).toInt(),
  stopName: json['stop_name'] as String,
  cityName: json['city_name'] as String,
);

Map<String, dynamic> _$DropStopToJson(DropStop instance) => <String, dynamic>{
  'id': instance.id,
  'stop_name': instance.stopName,
  'city_name': instance.cityName,
};

Passenger _$PassengerFromJson(Map<String, dynamic> json) => Passenger(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
);

Map<String, dynamic> _$PassengerToJson(Passenger instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'age': instance.age,
  'gender': instance.gender,
};

DetailedBookingSeat _$DetailedBookingSeatFromJson(Map<String, dynamic> json) =>
    DetailedBookingSeat(
      seatPrice: (json['seat_price'] as num).toDouble(),
      tripSeat: TripSeat.fromJson(json['trip_seat'] as Map<String, dynamic>),
      passenger: Passenger.fromJson(json['passenger'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DetailedBookingSeatToJson(
  DetailedBookingSeat instance,
) => <String, dynamic>{
  'seat_price': instance.seatPrice,
  'trip_seat': instance.tripSeat,
  'passenger': instance.passenger,
};

TripSeat _$TripSeatFromJson(Map<String, dynamic> json) => TripSeat(
  seatPrice: (json['seat_price'] as num).toDouble(),
  seat: Seat.fromJson(json['seat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TripSeatToJson(TripSeat instance) => <String, dynamic>{
  'seat_price': instance.seatPrice,
  'seat': instance.seat,
};

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
  seatNumber: json['seat_number'] as String,
  seatType: json['seat_type'] as String,
  deck: json['deck'] as String,
);

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
  'seat_number': instance.seatNumber,
  'seat_type': instance.seatType,
  'deck': instance.deck,
};

PostTripDetail _$PostTripDetailFromJson(Map<String, dynamic> json) =>
    PostTripDetail(
      id: (json['id'] as num).toInt(),
      departureTime: json['departure_time'] as String,
      arrivalTime: json['arrival_time'] as String,
      travelStartDate: json['travel_start_date'] as String,
      route: Route.fromJson(json['route'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostTripDetailToJson(PostTripDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'departure_time': instance.departureTime,
      'arrival_time': instance.arrivalTime,
      'travel_start_date': instance.travelStartDate,
      'route': instance.route,
    };

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
  sourceCity: json['source_city'] as String,
  destinationCity: json['destination_city'] as String,
  totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
  routeStops: (json['route_stops'] as List<dynamic>)
      .map((e) => RouteStop.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
  'source_city': instance.sourceCity,
  'destination_city': instance.destinationCity,
  'total_distance_km': instance.totalDistanceKm,
  'route_stops': instance.routeStops,
};

RouteStop _$RouteStopFromJson(Map<String, dynamic> json) => RouteStop(
  id: (json['id'] as num).toInt(),
  stopName: json['stop_name'] as String,
  cityName: json['city_name'] as String,
  stopOrder: (json['stop_order'] as num).toInt(),
);

Map<String, dynamic> _$RouteStopToJson(RouteStop instance) => <String, dynamic>{
  'id': instance.id,
  'stop_name': instance.stopName,
  'city_name': instance.cityName,
  'stop_order': instance.stopOrder,
};
