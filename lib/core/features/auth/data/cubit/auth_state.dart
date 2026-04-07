part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSessionActive extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse response;

  AuthSuccess(this.response);


}

class AuthRegisterSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
