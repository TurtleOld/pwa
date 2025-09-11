import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<User?> login(String username, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (username.isNotEmpty && password.isNotEmpty) {
        final user = User(
          id: 1,
          username: username,
          email: '$username@example.com',
          firstName: 'User',
          lastName: 'Name',
          token: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        await _saveUserData(user);
        
        return user;
      } else {
        throw Exception('Неверные учетные данные');
      }
    } catch (e) {
      throw Exception('Ошибка авторизации: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      throw Exception('Ошибка выхода: $e');
    }
  }

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

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserData(User user) async {
    try {
      await _storage.write(key: _tokenKey, value: user.token ?? '');
      await _storage.write(key: _userKey, value: json.encode(user.toJson()));
    } catch (e) {
      throw Exception('Ошибка сохранения данных: $e');
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  bool isValidUsername(String username) {
    return username.length >= 3 && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}
