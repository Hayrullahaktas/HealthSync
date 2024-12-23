import 'package:dio/dio.dart';
import '../../../models/common/api_response.dart';
import '../../../models/health/health_metrics_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/api_exceptions.dart';

class HealthMetricsApi {
  final Dio _dio;

  HealthMetricsApi(this._dio);

  // Kullanıcının günlük sağlık metriklerini getir
  Future<ApiResponse<HealthMetricsModel>> getDailyMetrics(
      int userId,
      DateTime date,
      ) async {
    try {
      final response = await _dio.get(
        ApiConstants.dailyMetrics,
        queryParameters: {
          'user_id': userId,
          'date': date.toIso8601String(),
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => HealthMetricsModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Yeni sağlık metriği kaydet
  Future<ApiResponse<HealthMetricsModel>> createHealthMetrics(
      HealthMetricsModel metrics,
      ) async {
    try {
      final response = await _dio.post(
        ApiConstants.healthMetrics,
        data: metrics.toMap(),
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => HealthMetricsModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Sağlık metriği güncelle
  Future<ApiResponse<HealthMetricsModel>> updateHealthMetrics(
      HealthMetricsModel metrics,
      ) async {
    if (metrics.id == null) {
      throw ValidationException({'id': ['Health Metrics ID is required']});
    }

    try {
      final response = await _dio.put(
        '${ApiConstants.healthMetrics}/${metrics.id}',
        data: metrics.toMap(),
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => HealthMetricsModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Tarih aralığına göre sağlık metrikleri özeti
  Future<ApiResponse<HealthMetricsSummary>> getHealthMetricsSummary(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        ApiConstants.healthMetrics,
        queryParameters: {
          'user_id': userId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => HealthMetricsSummary.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Haftalık sağlık metrikleri
  Future<ApiResponse<HealthMetricsSummary>> getWeeklyMetrics(
      int userId,
      DateTime weekStartDate,
      ) async {
    try {
      final response = await _dio.get(
        ApiConstants.weeklyMetrics,
        queryParameters: {
          'user_id': userId,
          'week_start': weekStartDate.toIso8601String(),
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => HealthMetricsSummary.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException();

      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            final errors = (error.response?.data['errors'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(key, (value as List).cast<String>()));
            return ValidationException(
              errors ?? {},
              error.response?.data['message'],
            );
          case 401:
            return UnauthorizedException(error.response?.data['message']);
          case 404:
            return NotFoundException(error.response?.data['message']);
          case 500:
            return ServerException(error.response?.data['message']);
          default:
            return UnknownException(error.response?.data['message']);
        }

      default:
        return UnknownException();
    }
  }
}