import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/response/trip_response.dart';

part 'trips_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class TripsApi {
  factory TripsApi(Dio dio, {String baseUrl}) = _TripsApi;

  @GET("public/operator_trips")
  Future<TripResponse> getOperatorTrips(
    @Query("source") String source,
    @Query("destination") String destination,
    @Query("date") String date,
    @Query("operator_id") int operatorId,
  );

  @GET("public/trips/{trip_id}/seats")
  Future<Map<String, Object?>> getTripSeats(@Path("trip_id") int tripId);

  @GET("public/trips/{trip_id}")
  Future<Map<String, Object?>> getTripDetail(@Path("trip_id") int tripId);

  @GET("bus_operators/{operator_id}/buses/{bus_id}/seat_layout")
  Future<Map<String, Object?>> getBusSeatLayout(
    @Path("operator_id") int operatorId,
    @Path("bus_id") int busId,
  );

  @GET("trips/{trip_id}/boarding_points")
  Future<Map<String, Object?>> getBoardingPoints(@Path("trip_id") int tripId);

  @GET("trips/{trip_id}/drop_points")
  Future<Map<String, Object?>> getDroppingPoints(@Path("trip_id") int tripId);
}
