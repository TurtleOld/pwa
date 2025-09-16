import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const String _serverUrlKey = 'server_url';
  static const String _defaultServerUrl = 'http://0.0.0.0:8000';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Получить URL сервера из безопасного хранилища
  Future<String> getServerUrl() async {
    try {
      final serverUrl = await _storage.read(key: _serverUrlKey);
      print('🔧 Stored server URL: $serverUrl');
      return serverUrl ?? _defaultServerUrl;
    } catch (e) {
      print('🔧 Error reading server URL: $e, using default');
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
    final baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
    final apiUrl = '${baseUrl}api/';
    print('🌐 Server URL: $serverUrl');
    print('🌐 API Base URL: $apiUrl');
    return apiUrl;
  }

  /// Валидация URL сервера
  bool isValidServerUrl(String url) {
    if (url.isEmpty) return false;

    final trimmedUrl = url.trim();
    if (!trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://')) {
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
