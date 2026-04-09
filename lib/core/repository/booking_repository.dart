// lib/core/features/booking/data/repository/booking_repository.dart
import 'package:dio/dio.dart';
import '../api/booking_api.dart';
import '../models/request/booking_request.dart';
import '../models/response/booking.dart';
import '../models/response/booking_details.dart';
import '../models/response/booking_response.dart';

class BookingRepository {
  final BookingApi api;
  final Dio dio;

  BookingRepository(this.api, this.dio);

  Future<CreateBookingResponse> createBooking(CreateBookingRequest request) async {
    try {
      final dynamic response = await api.createBooking(request);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      return CreateBookingResponse.fromJson(json);
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Booking failed');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<List<Booking>> getBookings() async {
    try {
      final dynamic response = await api.getBookings();
      print('Bookings response: $response');
      if (response is List) {
        return response.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      rethrow;
    }
  }

  Future<BookingDetail> getBookingDetails(int id) async {
    try {
      final dynamic response = await api.getBookingDetails(id);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      return BookingDetail.fromJson(json);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Booking not found');
      }
      throw _handleDioError(e, fallback: 'Failed to fetch booking details');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<CancelBookingResponse> cancelBooking(int id) async {
    try {
      final dynamic response = await api.cancelBooking(id);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      return CancelBookingResponse.fromJson(json);
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to cancel booking');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  String _handleDioError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['error'] != null) return data['error'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) return errors.first.toString();
        return errors.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return fallback;
  }
}