import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const String _serverUrlKey = 'server_url';
  static const String _defaultServerUrl = 'http://localhost:8000/api';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Получить URL сервера из безопасного хранилища
  Future<String> getServerUrl() async {
    try {
      final serverUrl = await _storage.read(key: _serverUrlKey);
      return serverUrl ?? _defaultServerUrl;
    } catch (e) {
      return _defaultServerUrl;
    }
  }

  /// Сохранить URL сервера в безопасное хранилище
  Future<void> setServerUrl(String url) async {
    try {
      await _storage.write(key: _serverUrlKey, value: url.trim());
    } catch (e) {
      throw Exception('Ошибка сохранения URL сервера: $e');
    }
  }

  /// Проверить, настроен ли URL сервера
  Future<bool> isServerUrlConfigured() async {
    try {
      final serverUrl = await _storage.read(key: _serverUrlKey);
      return serverUrl != null && serverUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Получить базовый URL для API запросов
  Future<String> getApiBaseUrl() async {
    final serverUrl = await getServerUrl();
    return serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
  }

  /// Валидация URL сервера
  bool isValidServerUrl(String url) {
    if (url.isEmpty) return false;
    
    final trimmedUrl = url.trim();
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      return false;
    }
    
    try {
      Uri.parse(trimmedUrl);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Очистить все настройки
  Future<void> clearSettings() async {
    try {
      await _storage.delete(key: _serverUrlKey);
    } catch (e) {
      throw Exception('Ошибка очистки настроек: $e');
    }
  }
}
