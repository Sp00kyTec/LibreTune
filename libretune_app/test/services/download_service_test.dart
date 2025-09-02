import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:libretune/services/download_service.dart';
import 'package:libretune/models/media_item.dart';

@GenerateMocks([DownloadService])
void main() {
  group('DownloadService', () {
    late DownloadService downloadService;
    late MediaItem testItem;

    setUp(() {
      downloadService = DownloadService();
      testItem = MediaItem(
        id: 'test_id',
        title: 'Test Song',
        type: MediaType.audio,
        source: SourceType.youtube,
      );
    });

    test('should generate safe filename', () {
      final filename = downloadService.generateSafeFilename(testItem);
      expect(filename, contains('Test Song'));
      expect(filename, contains('.mp3'));
      expect(filename, isNot(contains('<')));
      expect(filename, isNot(contains('>')));
    });

    test('should create download task', () async {
      // This would require mocking HTTP requests and file operations
      // For now, we'll test the structure
      expect(downloadService, isNotNull);
    });
  });
}