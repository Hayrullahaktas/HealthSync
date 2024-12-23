class LoginResponse {
  final String userId;
  final String email;
  final String token;
  final String refreshToken;
  final UserProfile userProfile;

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
      userProfile: UserProfile(
        name: json['profile']['name'],
        height: json['profile']['height'].toDouble(),
        weight: json['profile']['weight'].toDouble(),
        age: json['profile']['age'],
        isDarkMode: false, // Default value, will be set from local storage
        dailyGoal: 10000, // Default value, will be set from local storage
      ),
    );
  }
}
