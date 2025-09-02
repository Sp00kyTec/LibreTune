import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretune/main.dart';

void main() {
  group('App Integration', () {
    testWidgets('should display home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const LibreTuneApp());

      // Verify app starts without errors
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('LibreTune'), findsWidgets);
    });

    testWidgets('should navigate to downloads screen', (WidgetTester tester) async {
      await tester.pumpWidget(const LibreTuneApp());

      // Tap downloads icon in bottom navigation
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      // Verify downloads screen is displayed
      expect(find.text('Downloads'), findsOneWidget);
    });
  });
}