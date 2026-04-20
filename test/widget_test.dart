import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pregn_4/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
  
    await tester.pumpWidget(MyApp());

    // نتحقق فقط أن التطبيق بُني بنجاح
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
