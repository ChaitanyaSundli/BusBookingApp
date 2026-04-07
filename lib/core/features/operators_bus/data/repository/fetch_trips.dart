import 'package:dio/dio.dart';
import 'package:quick_bus/core/utils/date_time_formatter.dart';

import '../api/trips_api.dart';
import '../models/response/route_stop_model.dart';
import '../models/response/seat_model.dart';
import '../models/response/trip_model.dart';

class TripRepository {
  final TripsApi api;

  TripRepository(this.api);

  Future<List<TripModel>> fetchTrips({
    required String source,
    required String destination,
    required String date,
    required int operatorId,
  }) async {
    final res = await api.getOperatorTrips(
      source,
      destination,
      date,
      operatorId,
    );
    return res.data;
  }

  Future<List<SeatModel>> fetchTripSeats(int tripId) async {
    try {
      final res = await api.getTripSeats(tripId);
      final data = (res['data'] as List?) ?? const [];
      if (data.isNotEmpty) {
        return data
            .asMap()
            .entries
            .map((e) => _seatFromAnyMap((e.value as Map).cast<String, dynamic>(), e.key))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }

    final detail = await api.getTripDetail(tripId);
    final tripData = (detail['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final tripSeats = (tripData['trip_seats'] as List?) ?? const [];

    return tripSeats
        .asMap()
        .entries
        .map((e) => _seatFromAnyMap((e.value as Map).cast<String, dynamic>(), e.key))
        .toList();
  }

  Future<List<RouteStopModel>> fetchBoardingPoints(int tripId) async {
    final res = await api.getBoardingPoints(tripId);
    final data = (res['data'] as List?) ?? const [];
    return data.map((e) => _stopFromAnyMap((e as Map).cast<String, dynamic>())).toList();
  }

  Future<List<RouteStopModel>> fetchDroppingPoints(int tripId) async {
    final res = await api.getDroppingPoints(tripId);
    final data = (res['data'] as List?) ?? const [];
    return data.map((e) => _stopFromAnyMap((e as Map).cast<String, dynamic>())).toList();
  }

  RouteStopModel _stopFromAnyMap(Map<String, dynamic> raw) {
    final rawTime = raw['time'] ??
        raw['scheduled_departure_time'] ??
        raw['scheduled_arrival_time'];

    return RouteStopModel.fromJson({
      'id': raw['id'],
      'stopname': raw['stopname'] ?? raw['stop_name'] ?? '',
      'cityname': raw['cityname'] ?? raw['city_name'] ?? '',
      'address': raw['address'] ?? raw['stop_address'],
      'time': formatTravelTime(rawTime?.toString() ?? ''),
    });
  }

  SeatModel _seatFromAnyMap(Map<String, dynamic> raw, int index) {
    final rawDeck = (raw['deck'] ?? raw['deck_no'] ?? raw['deck_number'] ?? 'L')
        .toString()
        .toUpperCase();
    final deck = _normalizeDeck(rawDeck);
    final status = _resolveSeatStatus(raw);

    return SeatModel.fromJson({
      'id': raw['id'] ?? index + 1,
      'seatnumber': raw['seatnumber'] ?? raw['seat_number'] ?? 'S${index + 1}',
      'seattype': raw['seattype'] ?? raw['seat_type'] ?? 'seat',
      'deck': deck,
      'rownumber': _asInt(raw['rownumber'] ?? raw['row']) ?? (index ~/ 4) + 1,
      'colnumber': _asInt(raw['colnumber'] ?? raw['col']) ?? (index % 4) + 1,
      'status': status,
      'price': _asDouble(raw['price'] ?? raw['seat_price']) ?? 0,
      'tripseatid': raw['tripseatid'] ?? raw['id'],
    });
  }


  String _normalizeDeck(String rawDeck) {
    if (rawDeck.startsWith('U') ||
        rawDeck == '2' ||
        rawDeck.contains('UPPER')) {
      return 'U';
    }
    return 'L';
  }

  int _statusAsInt(dynamic value) {
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value.toInt();
    final text = value?.toString().trim().toLowerCase();
    if (text == null || text.isEmpty) return 0;
    if (text == '0' ||
        text == 'available' ||
        text == 'free' ||
        text == 'open' ||
        text == 'unbooked') {
      return 0;
    }
    if (text == '1' ||
        text == 'booked' ||
        text == 'reserved' ||
        text == 'blocked' ||
        text == 'occupied' ||
        text == 'sold') {
      return 1;
    }
    final asNum = int.tryParse(text);
    if (asNum != null) return asNum;
    return 1;
  }

  int _resolveSeatStatus(Map<String, dynamic> raw) {
    if (raw.containsKey('is_available')) {
      return _boolish(raw['is_available']) == true ? 0 : 1;
    }
    if (raw.containsKey('available')) {
      return _boolish(raw['available']) == true ? 0 : 1;
    }
    if (raw.containsKey('is_booked')) {
      return _boolish(raw['is_booked']) == true ? 1 : 0;
    }
    if (raw.containsKey('booked')) {
      return _boolish(raw['booked']) == true ? 1 : 0;
    }
    if (raw.containsKey('seat_status')) {
      return _statusAsInt(raw['seat_status']);
    }
    return _statusAsInt(raw['status']);
  }

  bool? _boolish(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    if (text == 'true' || text == 'yes' || text == 'y' || text == '1') return true;
    if (text == 'false' || text == 'no' || text == 'n' || text == '0') return false;
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
