import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class LibreTuneCacheManager {
  static const key = 'libretuneCache';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  // Preload thumbnails
  static Future<void> preloadThumbnails(List<String> urls) async {
    for (final url in urls) {
      if (url.isNotEmpty) {
        try {
          await instance.downloadFile(url);
        } catch (e) {
          // Ignore preload errors
        }
      }
    }
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
  
  // Get cache size
  static Future<int> getCacheSize() async {
    final dir = await instance.getTemporaryDirectory();
    return _getDirectorySize(dir);
  }
  
  static Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      await for (final file in directory.list(recursive: true)) {
        if (file is File) {
          size += await file.length();
        }
      }
    } catch (e) {
      // Ignore errors
    }
    return size;
  }
}