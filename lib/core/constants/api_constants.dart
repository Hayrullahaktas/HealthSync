class ApiConstants {
  // Base URL
  //static const String baseUrl = 'https://api.healthsync.com/v1';
  static const String baseUrl = 'http://10.0.2.2:3000';
  // static const String baseUrl = 'https://health-sync-api.vercel.app';
  // User & Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // Exercise Endpoints
  static const String exercises = '/exercises';
  static const String exerciseById = '/exercises/{id}';
  static const String exercisesByUser = '/exercises/user';
  static const String exerciseCategories = '/exercises/categories';
  static const String exerciseHistory = '/exercises/history';

  // Health Metrics Endpoints
  static const String healthMetrics = '/health/metrics';
  static const String dailyMetrics = '/health/metrics/daily';
  static const String weeklyMetrics = '/health/metrics/weekly';
  static const String monthlyMetrics = '/health/metrics/monthly';
  static const String updateMetrics = '/health/metrics/update';

  // Nutrition Endpoints
  static const String nutrition = '/nutrition';
  static const String nutritionHistory = '/nutrition/history';
  static const String nutritionCategories = '/nutrition/categories';
  static const String nutritionByDate = '/nutrition/date/{date}';

  // Pagination Parameters
  static const String pageParam = 'page';
  static const String limitParam = 'limit';
  static const String sortParam = 'sort';
  static const String orderParam = 'order';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';
  static const String validationError = 'Validation error occurred';
  static const String unknownError = 'An unknown error occurred';

  // Success Messages
  static const String createSuccess = 'Successfully created';
  static const String updateSuccess = 'Successfully updated';
  static const String deleteSuccess = 'Successfully deleted';

}
