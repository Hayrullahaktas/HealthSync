import 'package:dio/dio.dart';
import 'package:health_sync/core/constants/storage_constants.dart';  // Tam yolu ile import
import 'package:health_sync/core/constants/api_constants.dart';      // Tam yolu ile import
import 'package:health_sync/data/datasources/local/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get token from secure storage
    final credentials = await _secureStorage.getUserCredentials();
    final token = credentials['token'];

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final credentials = await _secureStorage.getUserCredentials();
        final userId = credentials[StorageConstants.keyUserId];

        if (userId != null) {
          final response = await _dio.post(
            '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
            data: {'userId': userId},
          );

          if (response.statusCode == 200) {
            // Save new token
            await _secureStorage.saveSecureData(
              StorageConstants.keyUserToken,
              response.data['token'],
            );

            // Retry original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer ${response.data['token']}';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Refresh token failed, user needs to login again
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}