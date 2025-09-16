import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pwa/screens/settings_screen.dart';

void main() {
  group('SettingsScreen Tests', () {
    testWidgets('SettingsScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Проверяем наличие основных элементов
      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Настройки сервера'), findsOneWidget);
      expect(find.text('Укажите URL сервера для подключения к API'), findsOneWidget);
      expect(find.text('URL сервера'), findsOneWidget);
      expect(find.text('Сохранить настройки'), findsOneWidget);
      expect(find.text('Назад к авторизации'), findsOneWidget);
    });

    testWidgets('SettingsScreen has settings icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Проверяем наличие иконки настроек
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('SettingsScreen has form validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Пытаемся сохранить пустую форму
      await tester.tap(find.text('Сохранить настройки'));
      await tester.pump();

      // Проверяем, что появилось сообщение об ошибке
      expect(find.text('Введите URL сервера'), findsOneWidget);
    });

    testWidgets('SettingsScreen validates URL format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Вводим некорректный URL
      await tester.enterText(find.byType(TextFormField), 'invalid-url');
      await tester.tap(find.text('Сохранить настройки'));
      await tester.pump();

      // Проверяем, что появилось сообщение об ошибке валидации
      expect(find.text('URL должен начинаться с http:// или https:// и быть корректным'), findsOneWidget);
    });

    testWidgets('SettingsScreen accepts valid URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      // Вводим корректный URL
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.text('Сохранить настройки'));
      await tester.pump();

      // Проверяем, что нет сообщений об ошибке валидации
      expect(find.text('URL должен начинаться с http:// или https:// и быть корректным'), findsNothing);
    });
  });
}
