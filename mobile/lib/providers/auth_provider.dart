import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check persistent session on app start
  Future<void> checkSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.getProfile();
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiConstants.resolveActiveBaseUrl();
      final res = await _authService.login(email: email, password: password);
      _user = res['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('reach the server') || msg.contains('timed out') || msg.contains('Network')) {
        try {
          await ApiConstants.resolveActiveBaseUrl(forceRefresh: true);
          final res = await _authService.login(email: email, password: password);
          _user = res['user'];
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (retryErr) {
          _errorMessage = retryErr.toString();
        }
      } else {
        _errorMessage = msg;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiConstants.resolveActiveBaseUrl();
      final res = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _user = res['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('reach the server') || msg.contains('timed out') || msg.contains('Network')) {
        try {
          await ApiConstants.resolveActiveBaseUrl(forceRefresh: true);
          final res = await _authService.register(
            name: name,
            email: email,
            password: password,
          );
          _user = res['user'];
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (retryErr) {
          _errorMessage = retryErr.toString();
        }
      } else {
        _errorMessage = msg;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

