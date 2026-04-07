import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final UserLoginRequest user;

  LoginRequest({required this.user});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class UserLoginRequest {
  final String email;
  final String password;

  UserLoginRequest({
    required this.email,
    required this.password,
  });

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginRequestToJson(this);
}