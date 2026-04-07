import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'booking_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class BookingApi {
  factory BookingApi(Dio dio, {String baseUrl}) = _BookingApi;

  @POST("public/bookings")
  Future<Map<String, dynamic>> createBooking(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> request,
  );
}
