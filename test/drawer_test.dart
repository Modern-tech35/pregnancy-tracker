import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

import 'package:pregn_4/main.dart';

Future<void> _setupHive(WidgetTester tester) async {
  await tester.runAsync(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    await Hive.openBox('settings');
    await Hive.openBox('profile');
    await Hive.openBox('reminders');
  });
}

void main() {
  testWidgets('One hamburger button opens one drawer', (tester) async {
    await _setupHive(tester);
    themeNotifier = ValueNotifier(ThemeMode.light);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Only ONE hamburger (the AppBar's built-in one).
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Opening it shows exactly one Drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);

    // The drawer is scrollable, so the language rows may start below the fold.
    await tester.scrollUntilVisible(
      find.text('English'),
      100,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('Switching language updates the UI immediately',
      (tester) async {
    await _setupHive(tester);
    themeNotifier = ValueNotifier(ThemeMode.light);

    // Translation assets are loaded through real file I/O, which needs the
    // real event loop; without runAsync the second test in this file never
    // finishes loading and renders no text at all.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          startLocale: const Locale('ar'),
          child: const MyApp(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // Profile appears in the AppBar title and the nav bar label.
    expect(find.text('الملف الشخصي'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Profile now in English (AppBar title + nav label), drawer closed.
    expect(find.text('Profile'), findsNWidgets(2));
    expect(find.byType(Drawer), findsNothing);
  });
}
