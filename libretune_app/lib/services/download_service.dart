import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/media_item.dart';

class DownloadService {
  static const String appName = 'LibreTune';
  
  // Get public download directory
  Future<Directory> getPublicDownloadDir() async {
    try {
      if (Platform.isAndroid) {
        // For Android 10+, use public Downloads directory
        final dir = Directory('/storage/emulated/0/Download/$appName');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      } else {
        // For other platforms, use documents directory
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      // Fallback to app documents directory
      return await getApplicationDocumentsDirectory();
    }
  }
  
    // Generate filename for downloaded content
  String generateFilename(MediaItem item) {
    final cleanTitle = item.title.replaceAll(RegExp(r'[^\w\s\.\-\(\)]'), '');
    final extension = item.type == MediaType.audio ? '.mp3' : '.mp4';
    return '$cleanTitle$extension';
  }
  
  // Download content to public storage
  Future<String?> downloadContent(MediaItem item) async {
    try {
      final downloadDir = await getPublicDownloadDir();
      final filename = generateFilename(item);
      final filePath = path.join(downloadDir.path, filename);
      
      // Get stream URL
      final streamUrl = item.streamUrl ?? await _getStreamUrl(item);
      if (streamUrl == null) return null;
      
      // Download file
      final request = await HttpClient().getUrl(Uri.parse(streamUrl));
      final response = await request.close();
      
      // Save to public storage
      final file = File(filePath);
      await response.pipe(file.openWrite());
      
      // Make file accessible to other apps (Android)
      await _makeFilePublic(filePath);
      
      return filePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
  
  // Make file accessible to other apps
  Future<void> _makeFilePublic(String filePath) async {
    if (Platform.isAndroid) {
      try {
        // Notify system of new media file
        // This would use Android's MediaStore API
      } catch (e) {
        print('Failed to make file public: $e');
      }
    }
  }
  
  // Helper method to get stream URL
  Future<String?> _getStreamUrl(MediaItem item) async {
    // Implementation depends on source
    return null;
  }
}