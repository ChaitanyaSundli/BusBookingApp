// lib/core/features/auth/data/repository/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:quick_bus/core/utils/local_storage/session_manager.dart';
import '../api/auth_api.dart';
import '../models/request/login_request.dart';
import '../models/request/signup_request.dart';
import '../models/response/login_response.dart';

class AuthRepository {
  final AuthApi api;
  final Dio dio;

  AuthRepository(this.api, this.dio);

  Future<LoginResponse> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await api.login(
        LoginRequest(
          user: UserLoginRequest(email: email, password: password),
        ),
      );
      await SessionManager().saveSession(
        response.token,
        response.user,
        persist: rememberMe,
      );
      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Login failed',
      );
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<LoginResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await api.register(
        SignupRequest(
          user: SignupUserRequest(
            name: name,
            email: email,
            phone: phone,
            password: password,
          ),
        ),
      );
      await SessionManager().saveSession(response.token, response.user);
      return response;
    } on DioException catch (e) {
      final errors = e.response?.data['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw Exception(errors.first.toString());
      }
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() => SessionManager().clearSession();

  Future<bool> isLoggedIn() async {
    await SessionManager().loadSession();
    return SessionManager().token != null;
  }
}