// lib/core/features/payment/data/repository/payment_repository.dart
import 'package:dio/dio.dart';
import '../api/payment_api.dart';

class PaymentRepository {
  final PaymentApi api;
  final Dio dio;

  PaymentRepository(this.api, this.dio);

  Future<Map<String, dynamic>> createPayment(int bookingId) async {
    try {
      final dynamic response = await api.createPayment({'booking_id': bookingId});
      return response as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Payment failed');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  String _handleDioError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['errors'] != null) return data['errors'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return fallback;
  }
}