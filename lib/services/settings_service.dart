import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html;
import 'package:pwa/services/di.dart';
import 'package:pwa/services/app_logger.dart';

class SettingsService {
  static const String _serverUrlKey = 'server_url';
  static const String _defaultServerUrl = 'http://localhost:8000';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AppLogger _logger = di<AppLogger>();

  Future<String> getServerUrl() async {
    try {
      final serverUrl = await _storage.read(key: _serverUrlKey);
      _logger.debug('stored server url', payload: {'serverUrl': serverUrl});
      return serverUrl ?? _getAutoServerUrl();
    } catch (e) {
      _logger.error(
        'error reading server url, using default',
        exception: e as Object?,
      );
      return _getAutoServerUrl();
    }
  }

  Future<void> setServerUrl(String url) async {
    try {
      await _storage.write(key: _serverUrlKey, value: url.trim());
    } catch (e) {
      throw Exception('Ошибка сохранения URL сервера');
    }
  }

  Future<bool> isServerUrlConfigured() async {
    try {
      final serverUrl = await _storage.read(key: _serverUrlKey);
      return serverUrl != null && serverUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> getApiBaseUrl() async {
    final serverUrl = await getServerUrl();
    final baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
    final apiUrl = '${baseUrl}api/';
    _logger.info(
      'api base resolved',
      payload: {'serverUrl': serverUrl, 'apiUrl': apiUrl},
    );
    return apiUrl;
  }

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

  Future<void> clearSettings() async {
    try {
      await _storage.delete(key: _serverUrlKey);
    } catch (e) {
      throw Exception('Ошибка очистки настроек');
    }
  }

  /// Автоматически определить URL сервера на основе текущего домена
  String _getAutoServerUrl() {
    try {
      final currentUrl = html.window.location;
      final protocol = currentUrl.protocol; // http: или https:
      final hostname = currentUrl.hostname; // localhost, example.com, etc.
      final port = currentUrl.port;
      _logger.debug(
        'current location',
        payload: {'protocol': protocol, 'hostname': hostname, 'port': port},
      );

      // Для локальной разработки
      if (hostname == 'localhost' || hostname == '127.0.0.1') {
        // Используем тот же хост, что и текущая страница
        return 'http://$hostname:8000';
      }

      // Для продакшена - используем тот же домен
      if (port == '80' || port == '443' || port == '') {
        // Стандартные порты - используем тот же домен без порта
        return '$protocol//$hostname';
      } else {
        // Нестандартный порт - предполагаем что API на том же хосте, порт 8000
        return '$protocol//$hostname:8000';
      }
    } catch (e) {
      _logger.error('auto detect server url failed', exception: e as Object?);
      return _defaultServerUrl;
    }
  }
}
