import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

import 'package:pregn_4/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    // Replicate the setup that main() performs before runApp.
    themeNotifier = ValueNotifier(ThemeMode.light);

    // Real file I/O must run outside the test's FakeAsync zone.
    await tester.runAsync(() async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      await Hive.openBox('settings');
      await Hive.openBox('profile');
      await Hive.openBox('reminders');
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // نتحقق فقط أن التطبيق بُني بنجاح
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
