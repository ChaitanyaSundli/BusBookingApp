import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/request/login_request.dart';
import '../models/request/signup_request.dart';
import '../models/response/login_response.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "api/v1/")
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST("auth/sign_in")
  Future<LoginResponse> login(
    @Body() LoginRequest request,
  );

  @POST("auth/passenger/register")
  Future<LoginResponse> register(
    @Body() SignupRequest request,
  );
}
