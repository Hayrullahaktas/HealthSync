import 'package:dio/dio.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/auth_constants.dart';
import '../datasources/local/storage/secure_storage.dart';
import './storage_repository.dart';
import '../models/user_model.dart';

class ApiRepository {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final StorageRepository _storageRepository;

  ApiRepository({
    required Dio dio,
    required SecureStorageService secureStorage,
    required StorageRepository storageRepository,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _storageRepository = storageRepository;

  // Email/Password Login
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('Login isteği gönderiliyor...');
      print('Email: ${request.email}');
      print('Request URL: ${ApiConstants.baseUrl}${ApiConstants.login}');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.login}', // login endpoint
        data: request.toJson(),
      );

      print('Login yanıtı alındı: ${response.data}');

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save credentials
      await _secureStorage.saveUserCredentials(
        userId: loginResponse.userId,
        email: loginResponse.email,
        token: loginResponse.token,
      );

      // Save user profile
      await _storageRepository.saveUserProfile(
        name: loginResponse.userProfile.name,
        height: loginResponse.userProfile.height,
        weight: loginResponse.userProfile.weight,
        age: loginResponse.userProfile.age,
      );

      print('Login başarılı!');
      print('Kullanıcı ID: ${loginResponse.userId}');
      print('Token: ${loginResponse.token}');

      return loginResponse;
    } catch (e) {
      print('Login hatası: $e');
      if (e is DioException) {
        final error = _handleDioError(e);
        print('API hatası: ${error.toString()}');
        throw error;
      }
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      print('Register isteği gönderiliyor...');
      print('Email: ${request.email}');
      print('Request URL: ${ApiConstants.baseUrl}${ApiConstants.register}');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.register}',
        data: request.toJson(),
      );

      print('Register yanıtı alındı: ${response.data}');

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save credentials and profile
      await _secureStorage.saveUserCredentials(
        userId: loginResponse.userId,
        email: loginResponse.email,
        token: loginResponse.token,
      );

      await _storageRepository.saveUserProfile(
        name: request.name,
        height: request.height,
        weight: request.weight,
        age: request.age,
      );

      print('Register başarılı!');
      print('Kullanıcı ID: ${loginResponse.userId}');
      print('Token: ${loginResponse.token}');

      return loginResponse;
    } catch (e) {
      print('Register hatası: $e');
      if (e is DioException) {
        final error = _handleDioError(e);
        print('API hatası: ${error.toString()}');
        throw error;
      }
      throw Exception('Registration failed: $e');
    }
  }

  // Google Login
  Future<LoginResponse> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${AuthConstants.googleAuthEndpoint}',
        data: {
          'id_token': idToken,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await _secureStorage.saveUserCredentials(
        userId: loginResponse.userId,
        email: loginResponse.email,
        token: loginResponse.token,
      );

      await _storageRepository.saveUserProfile(
        name: loginResponse.userProfile.name,
        height: loginResponse.userProfile.height,
        weight: loginResponse.userProfile.weight,
        age: loginResponse.userProfile.age,
      );

      return loginResponse;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Google login failed: $e');
    }
  }

  // Facebook Login
  Future<LoginResponse> loginWithFacebook(String accessToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${AuthConstants.facebookAuthEndpoint}',
        data: {
          'access_token': accessToken,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await _secureStorage.saveUserCredentials(
        userId: loginResponse.userId,
        email: loginResponse.email,
        token: loginResponse.token,
      );

      await _storageRepository.saveUserProfile(
        name: loginResponse.userProfile.name,
        height: loginResponse.userProfile.height,
        weight: loginResponse.userProfile.weight,
        age: loginResponse.userProfile.age,
      );

      return loginResponse;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Facebook login failed: $e');
    }
  }

  // Update User Profile
  Future<void> updateUserProfile(UserModel profile) async {
    try {
      await _dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.updateProfile}',
        data: {
          'name': profile.name,
          'height': profile.height,
          'weight': profile.weight,
          'age': profile.age,
          'created_at': profile.createdAt.toIso8601String(),
        },
      );

      // Update local storage
      await _storageRepository.saveUserProfile(
        name: profile.name,
        height: profile.height,
        weight: profile.weight,
        age: profile.age,
      );
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Profile update failed: $e');
    }
  }

  // Refresh Token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${AuthConstants.refreshTokenEndpoint}',
        data: {
          'refresh_token': refreshToken,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await _secureStorage.saveUserCredentials(
        userId: loginResponse.userId,
        email: loginResponse.email,
        token: loginResponse.token,
      );

      return loginResponse;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Token refresh failed: $e');
    }
  }

  // Error Handler
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(ApiConstants.networkError);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return Exception(ApiConstants.unauthorizedError);
        }
        return Exception(error.response?.data['message'] ?? ApiConstants.serverError);
      default:
        return Exception(ApiConstants.unknownError);
    }
  }
}