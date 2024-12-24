class AuthConstants {
  // OAuth Client IDs
  static const String googleClientId = 'your-google-client-id';
  static const String facebookAppId = 'your-facebook-app-id';

  // API Endpoints
  static const String googleAuthEndpoint = '/auth/google';
  static const String facebookAuthEndpoint = '/auth/facebook';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Token Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenTypeKey = 'token_type';
  static const String expiresInKey = 'expires_in';

  // Error Messages
  static const String invalidToken = 'Invalid token';
  static const String tokenExpired = 'Token has expired';
  static const String unauthorizedAccess = 'Unauthorized access';
  static const String authenticationFailed = 'Authentication failed';

  // OAuth Scopes
  static const List<String> googleScopes = [
    'email',
    'profile',
  ];

  // JWT Claims
  static const String userIdClaim = 'user_id';
  static const String emailClaim = 'email';
  static const String rolesClaim = 'roles';

  // Token Types
  static const String bearerToken = 'Bearer';
}