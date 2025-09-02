import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretune/widgets/media_card.dart';
import 'package:libretune/models/media_item.dart';

void main() {
  group('MediaCard', () {
    late MediaItem testItem;

    setUp(() {
      testItem = MediaItem(
        id: 'test_id',
        title: 'Test Song',
        artist: 'Test Artist',
        type: MediaType.audio,
        source: SourceType.youtube,
        duration: const Duration(minutes: 3, seconds: 30),
      );
    });

    testWidgets('should display media item information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaCard(
              item: testItem,
            ),
          ),
        ),
      );

      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
      expect(find.text('3:30'), findsOneWidget);
    });

    testWidgets('should call callbacks when tapped', (WidgetTester tester) async {
      bool playCalled = false;
      bool downloadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaCard(
              item: testItem,
              onPlay: () => playCalled = true,
              onDownload: () => downloadCalled = true,
            ),
          ),
        ),
      );

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(playCalled, true);

      // Tap download button
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();
      expect(downloadCalled, true);
    });
  });
}