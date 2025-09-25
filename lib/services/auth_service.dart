import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'settings_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _expiryKey = 'auth_expiry';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SettingsService _settingsService = SettingsService();
  late final Dio _dio;

  AuthService() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<User?> login(String username, String password) async {
    try {
      final apiBaseUrl = await _settingsService.getApiBaseUrl();
      final loginUrl = '${apiBaseUrl}auth/login/';

      final response = await _dio.post(
        loginUrl,
        data: {'username': username.trim(), 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Извлекаем токен и expiry из ответа Knox
        final token = responseData['token'] as String?;
        final expiry = responseData['expiry'] as String?;

        if (token == null) {
          throw Exception('Токен не получен от сервера');
        }

        // Создаем пользователя с базовой информацией из ответа логина
        final userData = responseData['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = User.fromJson(userData).copyWith(token: token);
          await _saveUserData(user, expiry);
          return user;
        } else {
          // Если нет данных пользователя в ответе, создаем минимального пользователя
          final trimmedUsername = username.trim();
          final user = User(
            id: 0, // Временный ID
            username: trimmedUsername,
            email: trimmedUsername.contains('@') ? trimmedUsername : '',
            token: token,
          );
          await _saveUserData(user, expiry);
          return user;
        }
      } else {
        final errorData = response.data;
        final errorMessage = _parseErrorMessage(errorData);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Превышено время ожидания подключения к серверу');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Превышено время ожидания ответа от сервера');
        } else if (e.type == DioExceptionType.sendTimeout) {
          throw Exception('Превышено время отправки запроса на сервер');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception(
            'Ошибка подключения к серверу. Проверьте адрес сервера и интернет-соединение',
          );
        } else if (e.response != null) {
          final statusCode = e.response!.statusCode;
          if (statusCode == 401) {
            throw Exception('Неверные учетные данные');
          } else if (statusCode == 403) {
            throw Exception('Доступ запрещен');
          } else if (statusCode == 404) {
            throw Exception('Сервер не найден. Проверьте адрес сервера');
          } else if (statusCode == 500) {
            throw Exception('Внутренняя ошибка сервера');
          } else {
            throw Exception('Ошибка сервера: $statusCode');
          }
        }
      }

      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception(
        'Ошибка подключения к серверу. Проверьте настройки сервера.',
      );
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: _tokenKey);

      if (token != null && token.isNotEmpty) {
        final apiBaseUrl = await _settingsService.getApiBaseUrl();
        final logoutUrl = '${apiBaseUrl}auth/logout/';

        await _dio.post(
          logoutUrl,
          options: Options(
            headers: {
              'Authorization': 'Token $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
      }

      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _expiryKey);
    } catch (e) {
      // Очищаем локальные данные даже если API запрос не удался
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _expiryKey);
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
      final expiry = await _storage.read(key: _expiryKey);

      if (token == null || token.isEmpty) {
        return false;
      }

      // Проверяем, не истек ли токен
      if (expiry != null && expiry.isNotEmpty) {
        final expiryDate = DateTime.parse(expiry);
        final now = DateTime.now();
        if (now.isAfter(expiryDate)) {
          await _storage.delete(key: _tokenKey);
          await _storage.delete(key: _userKey);
          await _storage.delete(key: _expiryKey);
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserData(User user, [String? expiry]) async {
    try {
      await _storage.write(key: _tokenKey, value: user.token ?? '');
      await _storage.write(key: _userKey, value: json.encode(user.toJson()));
      if (expiry != null) {
        await _storage.write(key: _expiryKey, value: expiry);
      }
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
    return username.length >= 3 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  /// Получить базовый URL для API запросов
  Future<String> getApiBaseUrl() async {
    return await _settingsService.getApiBaseUrl();
  }

  /// Получить информацию о токене
  Future<Map<String, String?>> getTokenInfo() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final expiry = await _storage.read(key: _expiryKey);
      return {'token': token, 'expiry': expiry};
    } catch (e) {
      return {'token': null, 'expiry': null};
    }
  }

  /// Проверить, истек ли токен
  Future<bool> isTokenExpired() async {
    try {
      final expiry = await _storage.read(key: _expiryKey);
      if (expiry == null || expiry.isEmpty) {
        return false; // Если нет информации об expiry, считаем токен валидным
      }

      final expiryDate = DateTime.parse(expiry);
      final now = DateTime.now();
      return now.isAfter(expiryDate);
    } catch (e) {
      return true; // В случае ошибки считаем токен истекшим
    }
  }

  /// Парсинг сообщений об ошибках от API
  String _parseErrorMessage(Map<String, dynamic> errorData) {
    // Обрабатываем различные форматы ошибок от Django REST Framework
    if (errorData.containsKey('non_field_errors')) {
      final errors = errorData['non_field_errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return errors.first.toString();
      }
    }

    if (errorData.containsKey('username')) {
      final errors = errorData['username'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return 'Имя пользователя: ${errors.first}';
      }
    }

    if (errorData.containsKey('password')) {
      final errors = errorData['password'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return 'Пароль: ${errors.first}';
      }
    }

    if (errorData.containsKey('detail')) {
      return errorData['detail'].toString();
    }

    if (errorData.containsKey('error')) {
      return errorData['error'].toString();
    }

    return 'Неверные учетные данные';
  }
}
