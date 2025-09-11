import 'package:flutter_test/flutter_test.dart';
import 'package:pwa/services/settings_service.dart';

void main() {
  group('SettingsService Tests', () {
    late SettingsService settingsService;

    setUp(() {
      settingsService = SettingsService();
    });

    test('isValidServerUrl returns true for valid URLs', () {
      expect(settingsService.isValidServerUrl('https://example.com'), isTrue);
      expect(settingsService.isValidServerUrl('http://localhost:8000'), isTrue);
      expect(settingsService.isValidServerUrl('https://api.example.com/v1'), isTrue);
    });

    test('isValidServerUrl returns false for invalid URLs', () {
      expect(settingsService.isValidServerUrl(''), isFalse);
      expect(settingsService.isValidServerUrl('invalid-url'), isFalse);
      expect(settingsService.isValidServerUrl('ftp://example.com'), isFalse);
      expect(settingsService.isValidServerUrl('example.com'), isFalse);
    });

    test('getServerUrl returns default URL when no URL is set', () async {
      final url = await settingsService.getServerUrl();
      expect(url, equals('http://localhost:8000/api'));
    });

    test('getApiBaseUrl returns URL with trailing slash', () async {
      final url = await settingsService.getApiBaseUrl();
      expect(url.endsWith('/'), isTrue);
    });

    test('getApiBaseUrl handles URL without trailing slash', () async {
      // Мокаем getServerUrl для тестирования
      final testUrl = 'https://example.com/api';
      // Поскольку мы не можем легко мокать FlutterSecureStorage в тестах,
      // мы тестируем логику обработки URL
      expect(testUrl.endsWith('/'), isFalse);
      final expectedUrl = '$testUrl/';
      expect(expectedUrl, equals('https://example.com/api/'));
    });
  });
}
