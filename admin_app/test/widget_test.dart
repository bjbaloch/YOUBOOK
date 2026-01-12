// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:admin_app/main.dart';
import 'package:admin_app/core/core.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Create a mock auth provider
    final authProvider = AdminAuthProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(authProvider: authProvider));
    await tester.pumpAndSettle();

    // Verify that we see the login screen elements
    expect(find.text('YOUBOOK Admin'), findsOneWidget);
    expect(find.text('Sign in to access the admin panel'), findsOneWidget);
  });
}
