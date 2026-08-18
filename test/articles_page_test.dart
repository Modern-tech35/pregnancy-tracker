import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:pregn_4/articles_page.dart';

void main() {
  testWidgets('Articles load from local asset (no infinite spinner)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('en'),
        child: const MaterialApp(home: ArticlesPage()),
      ),
    );

    // Allow the async asset load to complete.
    await tester.pumpAndSettle();

    // The spinner must be gone and articles rendered (the first card is
    // visible; later ones are off-screen in the test viewport).
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Benefits of Drinking Water During Pregnancy'),
        findsOneWidget);
  });
}
