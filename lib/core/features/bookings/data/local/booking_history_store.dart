import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../utils/local_storage/storage_stub.dart'
    if (dart.library.js_interop) '../../../../utils/local_storage/storage_web.dart';
import '../../../operators_bus/data/models/response/trip_model.dart';

class BookingHistoryItem {
  final int id;
  final int tripId;
  final String operatorName;
  final String busName;
  final String busNumber;
  final String source;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final List<String> seatNumbers;
  final int boardingStopId;
  final int dropStopId;
  final double totalPrice;
  final String createdAt;
  final String? paymentStatus;
  final double? paymentAmount;

  BookingHistoryItem({
    required this.id,
    required this.tripId,
    required this.operatorName,
    required this.busName,
    required this.busNumber,
    required this.source,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatNumbers,
    required this.boardingStopId,
    required this.dropStopId,
    required this.totalPrice,
    required this.createdAt,
    this.paymentStatus,
    this.paymentAmount,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BookingHistoryItem(
      id: json['id'] as int,
      tripId: json['tripId'] as int,
      operatorName: json['operatorName'] as String,
      busName: json['busName'] as String,
      busNumber: json['busNumber'] as String,
      source: json['source'] as String,
      destination: json['destination'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      seatNumbers: (json['seatNumbers'] as List).map((e) => '$e').toList(),
      boardingStopId: json['boardingStopId'] as int,
      dropStopId: json['dropStopId'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      paymentStatus: json['paymentStatus'] as String?,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'operatorName': operatorName,
        'busName': busName,
        'busNumber': busNumber,
        'source': source,
        'destination': destination,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'seatNumbers': seatNumbers,
        'boardingStopId': boardingStopId,
        'dropStopId': dropStopId,
        'totalPrice': totalPrice,
        'createdAt': createdAt,
        'paymentStatus': paymentStatus,
        'paymentAmount': paymentAmount,
      };

  factory BookingHistoryItem.fromFlow({
    required TripModel trip,
    required List<String> seats,
    required int boardingStopId,
    required int dropStopId,
    required double totalPrice,
  }) {
    final timestamp = DateTime.now().toUtc();
    return BookingHistoryItem(
      id: timestamp.microsecondsSinceEpoch,
      tripId: trip.id,
      operatorName: trip.operator.name,
      busName: trip.bus.name ?? 'Bus',
      busNumber: trip.bus.number ?? 'NA',
      source: '',
      destination: '',
      departureTime: trip.departureTime,
      arrivalTime: trip.arrivalTime,
      seatNumbers: seats,
      boardingStopId: boardingStopId,
      dropStopId: dropStopId,
      totalPrice: totalPrice,
      createdAt: timestamp.toIso8601String(),
      paymentStatus: null,
      paymentAmount: null,
    );
  }
}

class BookingHistoryStore {
  BookingHistoryStore._internal();

  static final BookingHistoryStore _instance = BookingHistoryStore._internal();
  factory BookingHistoryStore() => _instance;

  static const _storageKey = 'booking_history';

  final _mobileStorage = const FlutterSecureStorage();
  final _webStorage = getWebStorage();

  Future<List<BookingHistoryItem>> getBookings() async {
    final raw = await _readRaw();
    if (raw == null || raw.isEmpty) return [];

    final data = (jsonDecode(raw) as List)
        .map((e) => BookingHistoryItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return data;
  }

  Future<void> addBooking(BookingHistoryItem booking) async {
    final existing = await getBookings();
    await _saveRaw(jsonEncode([booking.toJson(), ...existing.map((e) => e.toJson())]));
  }

  Future<String?> _readRaw() async {
    if (kIsWeb) return _webStorage.read(_storageKey);
    return _mobileStorage.read(key: _storageKey);
  }

  Future<void> _saveRaw(String value) async {
    if (kIsWeb) {
      _webStorage.save(_storageKey, value);
      return;
    }
    await _mobileStorage.write(key: _storageKey, value: value);
  }
}
