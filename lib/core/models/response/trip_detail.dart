// lib/core/features/trips/data/models/trip_detail.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:quick_bus/core/models/response/trip.dart';

part 'trip_detail.g.dart';

@JsonSerializable()
class TripDetail {
  final int? id;
  @JsonKey(name: 'travel_start_date')
  final String? travelStartDate;
  @JsonKey(name: 'departure_time')
  final String? departureTime;
  @JsonKey(name: 'arrival_time')
  final String? arrivalTime;
  final String? status;
  @JsonKey(name: 'available_seats')
  final int? availableSeats;
  final Bus? bus;
  final Route? route;
  final Operator? operator;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'trip_seats')
  final List<TripSeatDetail>? tripSeats;

  TripDetail({
    this.id,
    this.travelStartDate,
    this.departureTime,
    this.arrivalTime,
    this.status,
    this.availableSeats,
    this.bus,
    this.route,
    this.operator,
    this.createdAt,
    this.tripSeats,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) =>
      _$TripDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TripDetailToJson(this);
}

@JsonSerializable()
class TripSeatDetail {
  final int? id;
  @JsonKey(name: 'seat_number')
  final String? seatNumber;
  @JsonKey(name: 'seat_type')
  final String? seatType;
  final String? deck;
  @JsonKey(name: 'seat_price')
  final double? seatPrice;
  final String? status;
  @JsonKey(name: 'row_number')
  final int? rowNumber; // From server, if present
  @JsonKey(name: 'col_number')
  final int? colNumberFromJson; // From server, if present

  TripSeatDetail({
    this.id,
    this.seatNumber,
    this.seatType,
    this.deck,
    this.seatPrice,
    this.status,
    this.rowNumber,
    this.colNumberFromJson,
  });

  // ------------------------------------------------------------
  // Computed properties (not from JSON directly)
  // ------------------------------------------------------------

  /// Effective row identifier for seat layout.
  /// Prefer server-provided rowNumber; otherwise parse from seatNumber.
  String get effectiveRow {
    final match = RegExp(r'^[LU](\d+)(\d)$').firstMatch(seatNumber ?? '');
    return match?.group(1) ?? '';
  }

  /// Effective column number for seat layout.
  /// Prefer server-provided colNumber; otherwise parse from seatNumber.
  int get effectiveCol {
    final match = RegExp(r'^[LU](\d+)(\d)$').firstMatch(seatNumber ?? '');
    return int.tryParse(match?.group(2) ?? '') ?? 0;
  }

  /// Row index for sorting (A=0, B=1, etc.)
  int get rowIndex {
    final row = effectiveRow;
    if (row.isEmpty) return 0;
    final firstChar = row.codeUnitAt(0);
    if (firstChar >= 65 && firstChar <= 90) return firstChar - 65; // A-Z
    if (firstChar >= 97 && firstChar <= 122) return firstChar - 97; // a-z
    return int.tryParse(row) ?? 0; // fallback for numeric rows
  }

  String get deckPrefix => (deck?.toLowerCase() == 'lower') ? 'L' : 'U';

  factory TripSeatDetail.fromJson(Map<String, dynamic> json) =>
      _$TripSeatDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TripSeatDetailToJson(this);
}
