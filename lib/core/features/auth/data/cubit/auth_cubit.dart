import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_bus/core/utils/local_storage/session_manager.dart';
import '../../data/repository/auth_repository.dart';
import '../models/response/login_response.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;

  AuthCubit(this.repo) : super(AuthInitial()) {
    initialize();
  }

  Future<void> initialize() async {
    final loggedIn = await repo.isLoggedIn();
    if (loggedIn) {
      emit(AuthSessionActive());
      return;
    }
    emit(AuthUnauthenticated());
  }

  Future<void> login(String email, String password, {bool rememberMe = true}) async {
    emit(AuthLoading());

    try {
      final res = await repo.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      await SessionManager().loadSession();
      emit(AuthSuccess(res));
      emit(AuthSessionActive());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final res = await repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      await SessionManager().loadSession();
      emit(AuthRegisterSuccess());
      emit(AuthSuccess(res));
      emit(AuthSessionActive());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
   }

  Future<void> logout() async {
    await repo.logout();
    emit(AuthUnauthenticated());
  }
}
