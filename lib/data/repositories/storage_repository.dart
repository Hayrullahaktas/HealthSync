
import '../datasources/local/storage/secure_storage.dart';
import '../datasources/local/storage/shared_prefs.dart';
import '../../core/utils/storage_utils.dart';


class StorageRepository {
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;
  final StorageUtils _storageUtils;

  StorageRepository({
    required SecureStorageService secureStorage,
    required SharedPrefsService sharedPrefs,
    required StorageUtils storageUtils,
  })  : _secureStorage = secureStorage,
        _sharedPrefs = sharedPrefs,
        _storageUtils = storageUtils;

  Future<void> saveDailyGoal(int steps) async {
    await _sharedPrefs.saveDailyGoal(steps);
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _sharedPrefs.saveThemeMode(isDarkMode);
  }



  Future<UserProfile> getUserProfile() async {
    return UserProfile(
      name: _sharedPrefs.getUserName() ?? '',
      height: _sharedPrefs.getUserHeight() ?? 0.0,
      weight: _sharedPrefs.getUserWeight() ?? 0.0,
      age: _sharedPrefs.getUserAge() ?? 0,
      isDarkMode: _sharedPrefs.isDarkMode(),
      dailyGoal: _sharedPrefs.getDailyGoal(),
    );
  }

  // Secure Storage methods
  Future<void> saveUserCredentials({
    required String userId,
    required String email,
    required String token,
  }) async {
    await _secureStorage.saveUserCredentials(
      userId: userId,
      email: email,
      token: token,
    );
  }

  Future<Map<String, String?>> getUserCredentials() async {
    return await _secureStorage.getUserCredentials();
  }

  // Shared Preferences methods
  Future<void> saveUserProfile({
    required String name,
    required double height,
    required double weight,
    required int age,
  }) async {
    await _sharedPrefs.saveUserProfile(
      name: name,
      height: height,
      weight: weight,
      age: age,
    );
  }

  // File Storage methods
  Future<void> saveExerciseLog(String log) async {
    await _storageUtils.saveExerciseLog(log);
  }

  Future<void> saveNutritionLog(String log) async {
    await _storageUtils.saveNutritionLog(log);
  }
}



class UserProfile {
  final String name;
  final double height;
  final double weight;
  final int age;
  final bool isDarkMode;
  final int dailyGoal;

  UserProfile({
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.isDarkMode,
    required this.dailyGoal,
  });
}