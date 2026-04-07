import 'package:dio/dio.dart';
import 'package:quick_bus/core/utils/local_storage/session_manager.dart';

import '../api/booking_api.dart';
import '../models/request/create_booking_request.dart';
import '../models/response/create_booking_response.dart';

class BookingRepository {
  final BookingApi api;

  BookingRepository(this.api);

  Future<CreateBookingResponse> createBooking(CreateBookingRequest request) async {
    try {
      final session = SessionManager();
      await session.loadSession();
      final token = session.token;
      if (token == null || token.isEmpty) {
        throw Exception('Login required');
      }

      final response = await api.createBooking('Bearer $token', request.toJson());
      return CreateBookingResponse.fromJson(response);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception('Failed to create booking');
    }
  }
}
