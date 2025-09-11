import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:pwa/main.dart';

void main() {
  testWidgets('App loads and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App shows loading indicator initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagerApp());

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App has correct theme configuration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagerApp());

    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, equals('Task Manager PWA'));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });
}
