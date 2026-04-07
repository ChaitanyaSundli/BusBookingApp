import 'package:json_annotation/json_annotation.dart';
import '../../../../features/operators_bus/data/models/response/trip_model.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel {
  final int id;
  @JsonKey(name: 'trip_id')
  final int tripId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'boarding_stop_id')
  final int? boardingStopId;
  @JsonKey(name: 'drop_stop_id')
  final int? dropStopId;
  final String status;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  // These might be included in a detailed response
  final TripModel? trip;
  final List<PassengerModel>? passengers;

  BookingModel({
    required this.id,
    required this.tripId,
    required this.userId,
    this.boardingStopId,
    this.dropStopId,
    required this.status,
    required this.totalPrice,
    this.createdAt,
    this.trip,
    this.passengers,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);
}

@JsonSerializable()
class PassengerModel {
  final int id;
  final String name;
  final String? phone;
  final int age;
  final int gender; // 0: male, 1: female, 2: other

  PassengerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.age,
    required this.gender,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) =>
      _$PassengerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PassengerModelToJson(this);
}
