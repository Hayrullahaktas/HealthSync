import 'package:flutter/material.dart';
import '../../data/repositories/api_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';

class AuthProvider extends ChangeNotifier {
  final ApiRepository _apiRepository;
  final StorageRepository _storageRepository;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider({
    required ApiRepository apiRepository,
    required StorageRepository storageRepository,
  })  : _apiRepository = apiRepository,
        _storageRepository = storageRepository {
    _checkAuthStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkAuthStatus() async {
    final credentials = await _storageRepository.getUserCredentials();
    _isAuthenticated = credentials['token'] != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginResponse = await _apiRepository.login(
        LoginRequest(email: email, password: password),
      );

      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required double height,
    required double weight,
    required int age,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registerResponse = await _apiRepository.register(
        RegisterRequest(
          email: email,
          password: password,
          name: name,
          height: height,
          weight: weight,
          age: age,
        ),
      );

      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // API çağrısı ekleme
      await _storageRepository.clearCredentials();  // Bu metodu StorageRepository'ye eklememiz gerekecek
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}