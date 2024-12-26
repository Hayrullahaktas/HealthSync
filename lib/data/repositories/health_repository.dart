import '../datasources/remote/api/exercise_api.dart';
import '../datasources/remote/api/health_metrics_api.dart';
import '../models/exercise_model.dart';
import '../models/health/health_metrics_model.dart';
import '../models/common/api_response.dart';

class HealthRepository {
  final ExerciseApi _exerciseApi;
  final HealthMetricsApi _healthMetricsApi;

  HealthRepository({
    required ExerciseApi exerciseApi,
    required HealthMetricsApi healthMetricsApi,
  })  : _exerciseApi = exerciseApi,
        _healthMetricsApi = healthMetricsApi;

  // Exercise Methods
  Future<List<ExerciseModel>> getUserExercises(int userId, {int page = 1}) async {
    final response = await _exerciseApi.getUserExercises(userId, page: page);
    return response.data ?? [];
  }

  Future<ExerciseModel> createExercise(ExerciseModel exercise) async {
    final response = await _exerciseApi.createExercise(exercise);
    return response.data!;
  }

  Future<ExerciseModel> updateExercise(ExerciseModel exercise) async {
    final response = await _exerciseApi.updateExercise(exercise);
    return response.data!;
  }

  Future<bool> deleteExercise(int id) async {
    final response = await _exerciseApi.deleteExercise(id);
    return response.data ?? false;
  }

  Future<ExerciseHistory> getExerciseHistory(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final response = await _exerciseApi.getExerciseHistory(
      userId,
      startDate,
      endDate,
    );
    return response.data!;
  }

  // Health Metrics Methods
  Future<HealthMetricsModel> getDailyMetrics(
      int userId,
      DateTime date,
      ) async {
    final response = await _healthMetricsApi.getDailyMetrics(userId, date);
    return response.data!;
  }

  Future<HealthMetricsModel> createHealthMetrics(
      HealthMetricsModel metrics,
      ) async {
    final response = await _healthMetricsApi.createHealthMetrics(metrics);
    return response.data!;
  }

  Future<HealthMetricsModel> updateHealthMetrics(
      HealthMetricsModel metrics,
      ) async {
    final response = await _healthMetricsApi.updateHealthMetrics(metrics);
    return response.data!;
  }

  Future<HealthMetricsSummary> getHealthMetricsSummary(
      int userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    final response = await _healthMetricsApi.getHealthMetricsSummary(
      userId,
      startDate,
      endDate,
    );
    return response.data!;
  }

  Future<HealthMetricsSummary> getWeeklyMetrics(
      int userId,
      DateTime weekStartDate,
      ) async {
    final response = await _healthMetricsApi.getWeeklyMetrics(
      userId,
      weekStartDate,
    );
    return response.data!;
  }
}