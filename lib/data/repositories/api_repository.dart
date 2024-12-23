import 'package:dio/dio.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../../core/constants/api_constants.dart';
import '../datasources/local/storage/secure_storage.dart';
import './storage_repository.dart';

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

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

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

      return loginResponse;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

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

      return loginResponse;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      }
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _dio.put(
        ApiConstants.updateProfile,
        data: {
          'name': profile.name,
          'height': profile.height,
          'weight': profile.weight,
          'age': profile.age,
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