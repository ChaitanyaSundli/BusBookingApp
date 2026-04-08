// lib/core/features/trips/data/api/trips_api.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'trips_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class TripsApi {
  factory TripsApi(Dio dio, {String baseUrl}) = _TripsApi;

  @GET("trips")
  Future<dynamic> getTrips(@Queries() Map<String, dynamic> query);

  @GET("trips/{id}")
  Future<dynamic> getTripDetail(@Path("id") int id);

  @GET("trips/search")
  Future<dynamic> searchTrips(@Queries() Map<String, dynamic> query);

  @GET("trips/{id}/boarding_points")
  Future<dynamic> getBoardingPoints(
      @Path("id") int id,
      @Query("city") String? city,
      );

  @GET("trips/{id}/drop_points")
  Future<dynamic> getDropPoints(
      @Path("id") int id,
      @Query("city") String? city,
      );

  @GET("trips/{id}/stops")
  Future<dynamic> getStops(@Path("id") int id);

  @GET("routes")
  Future<dynamic> getAllRoutes();

}