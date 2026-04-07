import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../models/response/operator_list_wrapper.dart';

part 'search_bus_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class SearchBusApi {

  factory SearchBusApi(Dio dio, {String baseUrl}) = _SearchBusApi;

  //http://localhost:3000/api/v1/public/operators?source=Indore&destination=Manali&date=2026-04-04
  @GET('/public/operators')
  Future<OperatorListWrapper> getOperatorList(
      @Query("source") String source,
      @Query("destination") String destination,
      @Query("date") String date,
      );

  @GET("/public/operators/all")
  Future<Map<String, dynamic>> getAllOperators();

  @GET("/public/operators/{operator_id}")
  Future<Map<String, dynamic>> getOperatorOverview(
    @Path("operator_id") int operatorId,
  );
}