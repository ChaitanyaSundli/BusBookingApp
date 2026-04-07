import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/stops_wrapper.dart';

part 'home_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class HomeApi {
  factory HomeApi(Dio dio, {String baseUrl}) = _HomeApi;

  @GET('/stops')
  Future<StopsWrapper> getStops(@Query("q") String query);

}