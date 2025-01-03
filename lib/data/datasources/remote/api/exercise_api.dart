import 'package:dio/dio.dart';
import '../../../models/common/api_response.dart';
import '../../../models/exercise_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/exceptions/api_exceptions.dart';

class ExerciseApi {
  final Dio _dio;

  ExerciseApi(this._dio);

  // Tüm egzersizleri getir
  Future<ApiResponse<List<ExerciseModel>>> getExercises({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.exercises,
        queryParameters: {
          ApiConstants.pageParam: page,
          ApiConstants.limitParam: limit,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => (json as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Kullanıcıya ait egzersizleri getir
  Future<ApiResponse<List<ExerciseModel>>> getUserExercises(
      int userId, {
        int page = 1,
        int limit = 10,
      }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.exercisesByUser}/$userId',
        queryParameters: {
          ApiConstants.pageParam: page,
          ApiConstants.limitParam: limit,
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => (json as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Yeni egzersiz oluştur
  Future<ApiResponse<ExerciseModel>> createExercise(ExerciseModel exercise) async {
    try {
      final response = await _dio.post(
        ApiConstants.exercises,
        data: exercise.toMap(),
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => ExerciseModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Egzersiz güncelle
  Future<ApiResponse<ExerciseModel>> updateExercise(ExerciseModel exercise) async {
    if (exercise.id == null) {
      throw ValidationException({'id': ['Exercise ID is required']});
    }

    try {
      final response = await _dio.put(
        '${ApiConstants.exercises}/${exercise.id}',
        data: exercise.toMap(),
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => ExerciseModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Egzersiz sil
  Future<ApiResponse<bool>> deleteExercise(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.exercises}/$id',
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => true,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Egzersiz geçmişini getir
  Future<ApiResponse<ExerciseHistory>> getExerciseHistory(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dio.get(
        ApiConstants.exerciseHistory,
        queryParameters: {
          'user_id': userId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return ApiResponse.fromJson(
        response.data,
            (json) => ExerciseHistory.fromJson(json),
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