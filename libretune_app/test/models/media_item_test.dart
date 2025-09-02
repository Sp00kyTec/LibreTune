import 'package:flutter_test/flutter_test.dart';
import 'package:libretune/models/media_item.dart';

void main() {
  group('MediaItem', () {
    test('should create MediaItem with required fields', () {
      final mediaItem = MediaItem(
        id: 'test_id',
        title: 'Test Title',
        type: MediaType.audio,
        source: SourceType.youtube,
      );

      expect(mediaItem.id, 'test_id');
      expect(mediaItem.title, 'Test Title');
      expect(mediaItem.type, MediaType.audio);
      expect(mediaItem.source, SourceType.youtube);
      expect(mediaItem.isDownloaded, false);
      expect(mediaItem.isLocal, false);
    });

    test('should copy with modified fields', () {
      final original = MediaItem(
        id: 'test_id',
        title: 'Original Title',
        type: MediaType.audio,
        source: SourceType.youtube,
      );

      final copied = original.copyWith(
        title: 'Modified Title',
        isDownloaded: true,
      );

      expect(copied.id, original.id);
      expect(copied.title, 'Modified Title');
      expect(copied.isDownloaded, true);
      expect(copied.type, original.type);
    });

    test('should convert to and from JSON', () {
      final original = MediaItem(
        id: 'test_id',
        title: 'Test Title',
        artist: 'Test Artist',
        duration: const Duration(minutes: 3, seconds: 30),
        type: MediaType.audio,
        source: SourceType.youtube,
        viewCount: 1000,
        uploadDate: DateTime(2023, 1, 1),
      );

      final json = original.toJson();
      final fromJson = MediaItem.fromJson(json);

      expect(fromJson.id, original.id);
      expect(fromJson.title, original.title);
      expect(fromJson.artist, original.artist);
      expect(fromJson.duration, original.duration);
      expect(fromJson.type, original.type);
      expect(fromJson.source, original.source);
      expect(fromJson.viewCount, original.viewCount);
    });

    test('should handle equality correctly', () {
      final item1 = MediaItem(
        id: 'same_id',
        title: 'Title 1',
        type: MediaType.audio,
        source: SourceType.youtube,
      );

      final item2 = MediaItem(
        id: 'same_id',
        title: 'Title 2',
        type: MediaType.video,
        source: SourceType.soundcloud,
      );

      final item3 = MediaItem(
        id: 'different_id',
        title: 'Title 1',
        type: MediaType.audio,
        source: SourceType.youtube,
      );

      expect(item1, item2); // Same ID should be equal
      expect(item1, isNot(item3)); // Different ID should not be equal
    });
  });
}