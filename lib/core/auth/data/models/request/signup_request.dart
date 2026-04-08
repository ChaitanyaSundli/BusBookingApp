class SignupRequest {
  final SignupUserRequest user;

  SignupRequest({required this.user});

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
      };
}

class SignupUserRequest {
  final String name;
  final String email;
  final String phone;
  final String password;

  SignupUserRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };
}
