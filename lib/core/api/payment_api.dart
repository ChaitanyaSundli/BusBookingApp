// lib/core/features/payment/data/api/payment_api.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'payment_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class PaymentApi {
  factory PaymentApi(Dio dio, {String baseUrl}) = _PaymentApi;

  @POST("payments")
  Future<dynamic> createPayment(@Body() Map<String, dynamic> body);
}