import 'package:dio/dio.dart';

import '../utils/local_storage/session_manager.dart';


class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = SessionManager();

    // Load if null
    if (session.token == null) {
      await session.loadSession();
    }

    if (session.token != null) {
      options.headers['Authorization'] = 'Bearer ${session.token}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the server says the token is invalid (401)
    if (err.response?.statusCode == 401) {
      final session = SessionManager();
      await session.clearSession(); // Wipe token and user data

      // Logic to navigate to Login Screen goes here
      // e.g., navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    }
    return handler.next(err);
  }
}
