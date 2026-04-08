// lib/core/features/booking/data/api/booking_api.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/request/booking_request.dart';

part 'booking_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class BookingApi {
  factory BookingApi(Dio dio, {String baseUrl}) = _BookingApi;

  @POST("bookings")
  Future<dynamic> createBooking(@Body() CreateBookingRequest request);

  @GET("bookings")
  Future<dynamic> getBookings();

  @GET("bookings/{id}")
  Future<dynamic> getBookingDetails(@Path("id") int id);

  @DELETE("bookings/{id}")
  Future<dynamic> cancelBooking(@Path("id") int id);
}