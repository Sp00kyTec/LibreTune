import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import 'content_source.dart';

class SoundCloudSource implements ContentSource {
  @override
  String get name => 'SoundCloud';
  
  @override
  String get icon => '🔊';
  
  @override
  SourceType get sourceType => SourceType.soundcloud;

  @override
  Future<List<MediaItem>> search(String query, {int limit = 20}) async {
    try {
      // SoundCloud public API or alternative scraping
      final response = await http.get(
        Uri.parse('https://api.soundcloud.com/tracks?q=${Uri.encodeQueryComponent(query)}&limit=$limit&client_id=YOUR_CLIENT_ID'),
      );
      
      return _parseSearchResults(response.body);
    } catch (e) {
      throw SourceException('Failed to search SoundCloud: $e');
    }
  }

  @override
  Future<MediaItem?> getDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.soundcloud.com/tracks/$id?client_id=YOUR_CLIENT_ID'),
      );
      
      return _parseTrackDetails(response.body);
    } catch (e) {
      throw SourceException('Failed to get SoundCloud track details: $e');
    }
  }

  @override
  Future<String?> getStreamUrl(MediaItem item) async {
    try {
      // SoundCloud stream URL (requires proper authentication in real implementation)
      return 'https://api.soundcloud.com/tracks/${item.id}/stream?client_id=YOUR_CLIENT_ID';
    } catch (e) {
      throw SourceException('Failed to get stream URL: $e');
    }
  }

  @override
  Future<List<MediaItem>> getTrending({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.soundcloud.com/charts/top?kind=trending&genre=soundcloud:genres:all-music&limit=$limit&client_id=YOUR_CLIENT_ID'),
      );
      
      return _parseChartResults(response.body);
    } catch (e) {
      throw SourceException('Failed to get trending tracks: $e');
    }
  }

  @override
  Future<List<MediaItem>> getCategory(String category, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.soundcloud.com/tracks?tags=${Uri.encodeQueryComponent(category)}&limit=$limit&client_id=YOUR_CLIENT_ID'),
      );
      
      return _parseSearchResults(response.body);
    } catch (e) {
      throw SourceException('Failed to get category content: $e');
    }
  }

  List<MediaItem> _parseSearchResults(String json) {
    try {
      final data = jsonDecode(json) as List;
      return data.map((item) => _mapToMediaItem(item)).take(20).toList();
    } catch (e) {
      return [];
    }
  }

  List<MediaItem> _parseChartResults(String json) {
    try {
      final data = jsonDecode(json);
      final collection = data['collection'] as List;
      return collection.map((item) => _mapToMediaItem(item['track'])).take(20).toList();
    } catch (e) {
      return [];
    }
  }

  MediaItem _mapToMediaItem(dynamic item) {
    return MediaItem(
      id: item['id'].toString(),
      title: item['title'] as String,
      artist: item['user']?['username'] as String? ?? 'Unknown Artist',
      description: item['description'] as String?,
      thumbnailUrl: item['artwork_url'] as String?,
      duration: Duration(milliseconds: (item['duration'] as int? ?? 0)),
      type: MediaType.audio,
      source: SourceType.soundcloud,
      viewCount: item['playback_count'] as int?,
      uploadDate: item['created_at'] != null 
          ? DateTime.parse(item['created_at'] as String) 
          : null,
      tags: (item['tag_list'] as String?)?.split(' '),
    );
  }

  MediaItem? _parseTrackDetails(String json) {
    try {
      final item = jsonDecode(json);
      return _mapToMediaItem(item);
    } catch (e) {
      return null;
    }
  }
}