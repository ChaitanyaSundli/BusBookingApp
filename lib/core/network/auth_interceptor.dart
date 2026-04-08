import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart'; // ← import go_router
import 'package:quick_bus/core/router/app_router.dart';
import '../utils/local_storage/session_manager.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = SessionManager();

    if (session.token == null) {
      await session.loadSession();
    }

    if (session.token != null) {
      final tokenPreview = session.token!.length > 10
          ? '${session.token!.substring(0, 10)}...'
          : session.token;
      options.headers['Authorization'] = 'Bearer ${session.token}';
    } else {
      print('NO token found');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final session = SessionManager();
      await session.clearSession();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null) {
          GoRouter.of(context).go('/login');  // ✅ correct usage
        }
      });
    }
    return handler.next(err);
  }
}