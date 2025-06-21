import 'package:flutter/material.dart';
import '../api/api_service.dart';

// Перечисление всех возможных состояний аутентификации
enum AuthState {
  uninitialized, // Начальное состояние
  authenticating, // Идет процесс входа
  authenticated,  // Вход успешен
  unauthenticated // Вход не удался или пользователь вышел
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthState _state = AuthState.uninitialized;
  String? _userRole;

  // Геттеры для доступа к состоянию из UI
  AuthState get state => _state;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';

  /// Новый метод для входа по одноразовому токену
  Future<void> loginWithOneTimeToken(String token) async {
    _state = AuthState.authenticating;
    notifyListeners();
    
    try {
      // Вызываем новый метод в ApiService для проверки токена
      final response = await _apiService.validateOneTimeToken(token);
      
      _userRole = response['user_role'];
      _state = AuthState.authenticated;
      notifyListeners();
    } catch (e) {
      print("Authentication failed with one-time token: $e");
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  /// Метод для выхода из системы
  Future<void> logout() async {
    await _apiService.logout();
    _userRole = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}