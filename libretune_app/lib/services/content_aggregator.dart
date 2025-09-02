import 'dart:async';
import '../models/media_item.dart';
import 'content_source.dart';
import 'youtube_source.dart';
import 'soundcloud_source.dart';
import 'bandcamp_source.dart';

class ContentAggregator {
  final List<ContentSource> _sources = [];
  bool _initialized = false;

  ContentAggregator() {
    _initializeSources();
  }

  void _initializeSources() {
    if (_initialized) return;
    
    // Add all available sources
    _sources.add(YouTubeSource());
    _sources.add(SoundCloudSource());
    _sources.add(BandcampSource());
    
    _initialized = true;
  }

  // Get all available sources
  List<ContentSource> get sources => List.unmodifiable(_sources);

  // Search across all sources
  Future<List<MediaItem>> searchAll(String query, {int limit = 50}) async {
    final allResults = <MediaItem>[];
    final futures = <Future<List<MediaItem>>>[];
    
    // Create search futures for all sources
    for (final source in _sources) {
      futures.add(source.search(query, limit: (limit / _sources.length).ceil()));
    }
    
    try {
      // Execute all searches concurrently
      final results = await Future.wait(futures, eagerError: false);
      
      // Combine results
      for (final result in results) {
        allResults.addAll(result);
      }
      
      // Sort by relevance (in real implementation, this would be more sophisticated)
      allResults.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
      
      return allResults.take(limit).toList();
    } catch (e) {
      print('Search error: $e');
      return allResults.take(limit).toList();
    }
  }

  // Search specific source
  Future<List<MediaItem>> searchSource(
    ContentSource source, 
    String query, 
    {int limit = 20}
  ) async {
    return await source.search(query, limit: limit);
  }

  // Get trending content from all sources
  Future<List<MediaItem>> getTrendingAll({int limit = 50}) async {
    final allResults = <MediaItem>[];
    final futures = <Future<List<MediaItem>>>[];
    
    // Create trending futures for all sources
    for (final source in _sources) {
      futures.add(source.getTrending(limit: (limit / _sources.length).ceil()));
    }
    
    try {
      // Execute all trending requests concurrently
      final results = await Future.wait(futures, eagerError: false);
      
      // Combine results
      for (final result in results) {
        allResults.addAll(result);
      }
      
      // Sort by view count or date
      allResults.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
      
      return allResults.take(limit).toList();
    } catch (e) {
      print('Trending error: $e');
      return allResults.take(limit).toList();
    }
  }

  // Get content by category from all sources
  Future<List<MediaItem>> getCategoryAll(
    String category, 
    {int limit = 50}
  ) async {
    final allResults = <MediaItem>[];
    final futures = <Future<List<MediaItem>>>[];
    
    // Create category futures for all sources
    for (final source in _sources) {
      futures.add(source.getCategory(category, limit: (limit / _sources.length).ceil()));
    }
    
    try {
      // Execute all category requests concurrently
      final results = await Future.wait(futures, eagerError: false);
      
      // Combine results
      for (final result in results) {
        allResults.addAll(result);
      }
      
      return allResults.take(limit).toList();
    } catch (e) {
      print('Category error: $e');
      return allResults.take(limit).toList();
    }
  }

  // Get stream URL for any media item
  Future<String?> getStreamUrl(MediaItem item) async {
    try {
      final source = _sources.firstWhere(
        (s) => s.sourceType == item.source,
        orElse: () => throw SourceException('Source not found for item'),
      );
      
      return await source.getStreamUrl(item);
    } catch (e) {
      print('Stream URL error: $e');
      return null;
    }
  }

  // Get detailed information for an item
  Future<MediaItem?> getDetails(MediaItem item) async {
    try {
      final source = _sources.firstWhere(
        (s) => s.sourceType == item.source,
        orElse: () => throw SourceException('Source not found for item'),
      );
      
      return await source.getDetails(item.id);
    } catch (e) {
      print('Details error: $e');
      return null;
    }
  }

  // Get source by type
  ContentSource? getSourceByType(SourceType type) {
    try {
      return _sources.firstWhere((s) => s.sourceType == type);
    } catch (e) {
      return null;
    }
  }
}