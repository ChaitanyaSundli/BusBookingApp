import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

class DioClient {
  static const String _defaultBaseUrl = 'http://172.30.1.152:3000';
  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);

  static Dio getDio() {
    return Dio(
      BaseOptions(
        baseUrl: _configuredBaseUrl,
        headers: {'Accept': 'application/json'},
      ),
    )..interceptors.addAll([
        LogInterceptor(responseBody: true, requestBody: true, responseHeader: false),
        AuthInterceptor(),
      ]);
  }
}
