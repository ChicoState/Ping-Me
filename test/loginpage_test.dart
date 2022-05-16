import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pingme/main.dart' as app;

void main() {
  group('App Test', () {
    // flutter driver that executes one command after the other
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Login page test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const app.MyApp());

      await tester.pumpAndSettle();

      // can also be search for by key
      final emailFormField = find.byType(TextField).first;
      final passwordFormField = find.byType(TextField).last;
      final loginButton = find.byType(TextButton).first;

      await tester.enterText(emailFormField, "braulio@gmail.com");
      await tester.enterText(passwordFormField, "braulio123");

      await tester.pump();

      // Verify the test
      await tester.tap(loginButton);
    });
  });
}
