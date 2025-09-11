import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Заглушка для авторизации (пока нет API)
  Future<User?> login(String username, String password) async {
    try {
      // Имитация задержки сети
      await Future.delayed(const Duration(seconds: 1));
      
      // Заглушка: проверяем простые учетные данные
      if (username.isNotEmpty && password.isNotEmpty) {
        // Создаем фиктивного пользователя
        final user = User(
          id: 1,
          username: username,
          email: '$username@example.com',
          firstName: 'User',
          lastName: 'Name',
          token: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        // Сохраняем данные пользователя
        await _saveUserData(user);
        
        return user;
      } else {
        throw Exception('Неверные учетные данные');
      }
    } catch (e) {
      throw Exception('Ошибка авторизации: $e');
    }
  }

  // Заглушка для выхода
  Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      throw Exception('Ошибка выхода: $e');
    }
  }

  // Проверка авторизации
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData != null) {
        final userJson = json.decode(userData);
        return User.fromJson(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Проверка токена
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Сохранение данных пользователя
  Future<void> _saveUserData(User user) async {
    try {
      await _storage.write(key: _tokenKey, value: user.token ?? '');
      await _storage.write(key: _userKey, value: json.encode(user.toJson()));
    } catch (e) {
      throw Exception('Ошибка сохранения данных: $e');
    }
  }

  // Валидация email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Валидация пароля
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Валидация имени пользователя
  bool isValidUsername(String username) {
    return username.length >= 3 && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}
