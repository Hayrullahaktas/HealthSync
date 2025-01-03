// lib/presentation/providers/api_provider.dart
import 'package:flutter/material.dart';
import '../../data/repositories/api_repository.dart';
import '../../data/models/user_model.dart';  // UserModel'i import ediyoruz

class ApiProvider extends ChangeNotifier {
  final ApiRepository _apiRepository;
  bool _isLoading = false;
  String? _error;

  ApiProvider({required ApiRepository apiRepository})
      : _apiRepository = apiRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateUserProfile(UserModel profile) async {  // UserModel olarak değiştirdik
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiRepository.updateUserProfile(profile);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}