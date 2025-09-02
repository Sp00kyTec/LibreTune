import '../models/media_item.dart';

// Abstract interface for all content sources
abstract class ContentSource {
  String get name;
  String get icon;
  SourceType get sourceType;
  
  Future<List<MediaItem>> search(String query, {int limit = 20});
  Future<MediaItem?> getDetails(String id);
  Future<String?> getStreamUrl(MediaItem item);
  Future<List<MediaItem>> getTrending({int limit = 20});
  Future<List<MediaItem>> getCategory(String category, {int limit = 20});
}

// Custom exception for source-related errors
class SourceException implements Exception {
  final String message;
  SourceException(this.message);
  
  @override
  String toString() => 'SourceException: $message';
}