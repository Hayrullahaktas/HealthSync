import 'package:flutter/foundation.dart';
import '../../data/repositories/storage_repository.dart';

class StorageProvider extends ChangeNotifier {
  final StorageRepository _storageRepository;

  // User Profile Data
  String? _userName;
  double? _userHeight;
  double? _userWeight;
  int? _userAge;
  bool _isDarkMode = false;
  int _dailyGoal = 10000;

  // Getters
  String? get userName => _userName;
  double? get userHeight => _userHeight;
  double? get userWeight => _userWeight;
  int? get userAge => _userAge;
  bool get isDarkMode => _isDarkMode;
  int get dailyGoal => _dailyGoal;

  StorageProvider({
    required StorageRepository storageRepository,
  }) : _storageRepository = storageRepository {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final credentials = await _storageRepository.getUserCredentials();
      if (credentials['userId'] != null) {
        // Kullanıcı giriş yapmış, profil bilgilerini yükle
        await loadUserProfile();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final prefs = await _storageRepository.getUserProfile();
      _userName = prefs.name;
      _userHeight = prefs.height;
      _userWeight = prefs.weight;
      _userAge = prefs.age;
      _isDarkMode = prefs.isDarkMode;
      _dailyGoal = prefs.dailyGoal;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> saveUserProfile({
    required String name,
    required double height,
    required double weight,
    required int age,
  }) async {
    try {
      await _storageRepository.saveUserProfile(
        name: name,
        height: height,
        weight: weight,
        age: age,
      );

      _userName = name;
      _userHeight = height;
      _userWeight = weight;
      _userAge = age;

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<void> updateDailyGoal(int steps) async {
    try {
      await _storageRepository.saveDailyGoal(steps);
      _dailyGoal = steps;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating daily goal: $e');
      rethrow;
    }
  }

  Future<void> toggleThemeMode() async {
    try {
      _isDarkMode = !_isDarkMode;
      await _storageRepository.saveThemeMode(_isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling theme mode: $e');
      rethrow;
    }
  }

  Future<void> saveUserCredentials({
    required String userId,
    required String email,
    required String token,
  }) async {
    try {
      await _storageRepository.saveUserCredentials(
        userId: userId,
        email: email,
        token: token,
      );
    } catch (e) {
      debugPrint('Error saving user credentials: $e');
      rethrow;
    }
  }

  Future<void> saveExerciseLog(String log) async {
    try {
      await _storageRepository.saveExerciseLog(log);
    } catch (e) {
      debugPrint('Error saving exercise log: $e');
      rethrow;
    }
  }

  Future<void> saveNutritionLog(String log) async {
    try {
      await _storageRepository.saveNutritionLog(log);
    } catch (e) {
      debugPrint('Error saving nutrition log: $e');
      rethrow;
    }
  }
}