import 'package:dio/dio.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../../core/constants/auth_constants.dart';
import '../../core/services/jwt_service.dart';
import '../../core/services/oauth_service.dart';
import '../datasources/local/storage/secure_storage.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final JwtService _jwtService;
  final OAuthService _oAuthService;

  AuthRepository({
    required Dio dio,
    required SecureStorageService secureStorage,
    required JwtService jwtService,
    required OAuthService oAuthService,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _jwtService = jwtService,
        _oAuthService = oAuthService;

  // Email/Password ile giriş
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AuthConstants.loginEndpoint,
        data: LoginRequest(email: email, password: password).toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _saveTokens(loginResponse.token, loginResponse.refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Kayıt olma
  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        AuthConstants.registerEndpoint,
        data: RegisterRequest(
          email: email,
          password: password,
          name: name,
        ).toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _saveTokens(loginResponse.token, loginResponse.refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Google ile giriş
  Future<bool> signInWithGoogle() async {
    try {
      final googleAuth = await _oAuthService.signInWithGoogle();
      if (googleAuth == null) return false;

      final response = await _dio.post(
        AuthConstants.googleAuthEndpoint,
        data: {
          'idToken': googleAuth.idToken,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _saveTokens(loginResponse.token, loginResponse.refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Facebook ile giriş
  Future<bool> signInWithFacebook() async {
    try {
      final facebookAuth = await _oAuthService.signInWithFacebook();
      if (facebookAuth == null) return false;

      final response = await _dio.post(
        AuthConstants.facebookAuthEndpoint,
        data: {
          'accessToken': facebookAuth['token'],
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _saveTokens(loginResponse.token, loginResponse.refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Token yenileme
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getSecureData(AuthConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        AuthConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _saveTokens(loginResponse.token, loginResponse.refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Çıkış yapma
  Future<void> logout() async {
    try {
      await _oAuthService.signOutGoogle();
      await _oAuthService.signOutFacebook();
      await _secureStorage.deleteSecureData(AuthConstants.accessTokenKey);
      await _secureStorage.deleteSecureData(AuthConstants.refreshTokenKey);
    } catch (e) {
      // Handle error
    }
  }

  // Token'ları kaydet
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.saveSecureData(AuthConstants.accessTokenKey, accessToken);
    await _secureStorage.saveSecureData(AuthConstants.refreshTokenKey, refreshToken);
  }

  // Token kontrolü
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getSecureData(AuthConstants.accessTokenKey);
      if (token == null) return false;

      if (_jwtService.isTokenExpired(token)) {
        return await refreshToken();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Kullanıcı ID'sini al
  Future<String?> getUserId() async {
    final token = await _secureStorage.getSecureData(AuthConstants.accessTokenKey);
    if (token == null) return null;
    return _jwtService.getUserIdFromToken(token);
  }
}