// lib/data/models/auth/login_response.dart

import '../user_model.dart';  // UserModel'i import ediyoruz

class LoginResponse {
  final String userId;
  final String email;
  final String token;
  final String refreshToken;
  final UserModel userProfile;  // UserProfile yerine UserModel kullanıyoruz

  LoginResponse({
    required this.userId,
    required this.email,
    required this.token,
    required this.refreshToken,
    required this.userProfile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['user_id'],
      email: json['email'],
      token: json['token'],
      refreshToken: json['refresh_token'],
      userProfile: UserModel(  // UserModel constructor'ını kullanıyoruz
        name: json['profile']['name'],
        height: json['profile']['height'].toDouble(),
        weight: json['profile']['weight'].toDouble(),
        age: json['profile']['age'],
        createdAt: DateTime.now(),  // veya json['profile']['created_at'] eğer API'den geliyorsa
      ),
    );
  }
}