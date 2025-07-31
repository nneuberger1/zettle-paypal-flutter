// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zettle_paypal_flutter_example/main.dart';

void main() {
  testWidgets('Verify app loads with correct title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed in the AppBar
    expect(find.text('Zettle PayPal Flutter Demo'), findsOneWidget);
  });
  
  testWidgets('Verify app shows loading or content', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // The app should show either a loading indicator or the main content
    expect(
      find.byWidgetPredicate((widget) => 
        widget is CircularProgressIndicator || 
        widget is SingleChildScrollView
      ), 
      findsAtLeastNWidgets(1)
    );
  });
}
