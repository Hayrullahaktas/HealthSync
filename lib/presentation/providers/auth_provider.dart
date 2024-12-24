import 'package:flutter/material.dart';
import '../../data/repositories/api_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';
import '../../core/services/oauth_service.dart';
import '../../core/services/jwt_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiRepository _apiRepository;
  final StorageRepository _storageRepository;
  final OAuthService _oAuthService;
  final JwtService _jwtService;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userId;

  AuthProvider({
    required ApiRepository apiRepository,
    required StorageRepository storageRepository,
    required OAuthService oAuthService,
    required JwtService jwtService,
  })  : _apiRepository = apiRepository,
        _storageRepository = storageRepository,
        _oAuthService = oAuthService,
        _jwtService = jwtService {
    _checkAuthStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  Future<void> _checkAuthStatus() async {
    final credentials = await _storageRepository.getUserCredentials();
    final token = credentials['token'];

    if (token != null && !_jwtService.isTokenExpired(token)) {
      _isAuthenticated = true;
      _userId = _jwtService.getUserIdFromToken(token);
    } else {
      _isAuthenticated = false;
      _userId = null;
    }
    notifyListeners();
  }

  // Mevcut login metodu
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginResponse = await _apiRepository.login(
        LoginRequest(email: email, password: password),
      );

      final token = loginResponse.token;
      _userId = _jwtService.getUserIdFromToken(token);
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userId = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google ile giriş
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleAuth = await _oAuthService.signInWithGoogle();
      if (googleAuth == null) {
        _error = 'Google sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loginResponse = await _apiRepository.loginWithGoogle(googleAuth.idToken!);

      final token = loginResponse.token;
      _userId = _jwtService.getUserIdFromToken(token);
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userId = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Facebook ile giriş
  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final facebookAuth = await _oAuthService.signInWithFacebook();
      if (facebookAuth == null || facebookAuth['token'] == null) {
        _error = 'Facebook sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loginResponse = await _apiRepository.loginWithFacebook(facebookAuth['token']);

      final token = loginResponse.token;
      _userId = _jwtService.getUserIdFromToken(token);
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userId = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mevcut register metodu
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

      final token = registerResponse.token;
      _userId = _jwtService.getUserIdFromToken(token);
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userId = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mevcut logout metodu güncellendi
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _oAuthService.signOutGoogle();
      await _oAuthService.signOutFacebook();
      await _storageRepository.clearCredentials();
      _isAuthenticated = false;
      _userId = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Token yenileme işlemi
  Future<bool> refreshToken() async {
    try {
      final credentials = await _storageRepository.getUserCredentials();
      final refreshToken = credentials['refresh_token'];

      if (refreshToken == null) {
        _isAuthenticated = false;
        _userId = null;
        notifyListeners();
        return false;
      }

      final response = await _apiRepository.refreshToken(refreshToken);

      final newToken = response.token;
      _userId = _jwtService.getUserIdFromToken(newToken);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _userId = null;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}