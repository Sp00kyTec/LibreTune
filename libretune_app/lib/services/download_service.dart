import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../models/download_task.dart';

class DownloadService {
  static const String appName = 'LibreTune';
  final Map<String, DownloadTask> _activeDownloads = {};
  
  // Request storage permissions
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }
  
  // Get appropriate download directory based on platform
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to use public Downloads directory
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final appDir = Directory('${downloadsDir.path}/$appName');
          if (!await appDir.exists()) {
            await appDir.create(recursive: true);
          }
          return appDir;
        }
      } catch (e) {
        print('Could not access Downloads directory: $e');
      }
    }
    
    // Fallback to app-specific directory
    return await getApplicationDocumentsDirectory();
  }
  
  // Generate clean, safe filename
  String generateSafeFilename(MediaItem item) {
    String filename = item.title;
    
    // Remove invalid characters
    filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '');
    
    // Limit length
    if (filename.length > 150) {
      filename = filename.substring(0, 150);
    }
    
    // Add extension based on content type
    final extension = item.type == MediaType.audio ? '.mp3' : '.mp4';
    
    return '$filename$extension';
  }
  
  // Download content with progress tracking
  Future<DownloadTask> downloadContent(
    MediaItem item, {
    Function(double)? onProgress,
    Function(String)? onComplete,
    Function(String)? onError,
  }) async {
    final taskId = '${item.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create download task
    final task = DownloadTask(
      id: taskId,
      mediaItem: item,
      status: DownloadStatus.queued,
      progress: 0.0,
    );
    
    _activeDownloads[taskId] = task;
    
    try {
      // Request permissions
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }
      
      // Get download directory
      final downloadDir = await getDownloadDirectory();
      final filename = generateSafeFilename(item);
      final tempPath = path.join(downloadDir.path, 'temp_$filename');
      final finalPath = path.join(downloadDir.path, filename);
      
      // Update task status
      task.status = DownloadStatus.downloading;
      _activeDownloads[taskId] = task;
      
      // Get stream URL
      final streamUrl = item.streamUrl; // Assume this is already set
      if (streamUrl == null) {
        throw Exception('No stream URL available');
      }
      
      // Download with progress tracking
      await _downloadWithProgress(
        streamUrl,
        tempPath,
        (progress) {
          task.progress = progress;
          _activeDownloads[taskId] = task;
          onProgress?.call(progress);
        },
      );
      
      // Move temp file to final location
      await File(tempPath).rename(finalPath);
      
      // Make file accessible to other apps (Android MediaStore integration)
      await _makeFilePublic(finalPath, item);
      
      // Update media item with file path
      final updatedItem = item.copyWith(
        filePath: finalPath,
        isDownloaded: true,
        isLocal: true,
      );
      
      // Update task
      task.status = DownloadStatus.completed;
      task.filePath = finalPath;
      task.mediaItem = updatedItem;
      _activeDownloads[taskId] = task;
      
      onComplete?.call(finalPath);
      
      return task;
      
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      _activeDownloads[taskId] = task;
      
      onError?.call(e.toString());
      rethrow;
    }
  }
  
  // Download with progress tracking
  Future<void> _downloadWithProgress(
    String url,
    String savePath,
    Function(double) onProgress,
  ) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();
    
    final totalBytes = response.contentLength ?? 0;
    var downloadedBytes = 0;
    
    final file = File(savePath);
    final sink = file.openWrite();
    
    await response.stream.listen(
      (List<int> data) {
        sink.add(data);
        downloadedBytes += data.length;
        
        if (totalBytes > 0) {
          final progress = downloadedBytes / totalBytes;
          onProgress(progress);
        }
      },
      onDone: () async {
        await sink.close();
      },
      onError: (error) {
        sink.close();
        throw error;
      },
      cancelOnError: true,
    ).asFuture<void>();
  }
  
  // Make file accessible to other apps (Android MediaStore integration)
  Future<void> _makeFilePublic(String filePath, MediaItem item) async {
    if (Platform.isAndroid) {
      try {
        // For Android 10+, we need to use MediaStore API
        // This would be implemented with platform channels
        // For now, saving to public directory should make it accessible
        print('File saved to: $filePath');
        print('File should be accessible to other apps');
      } catch (e) {
        print('Could not make file public: $e');
      }
    }
  }
  
  // Get active download tasks
  List<DownloadTask> getActiveDownloads() {
    return _activeDownloads.values.toList();
  }
  
  // Cancel download
  Future<void> cancelDownload(String taskId) async {
    final task = _activeDownloads[taskId];
    if (task != null) {
      task.status = DownloadStatus.cancelled;
      // In a real implementation, you'd also cancel the actual download
    }
  }
  
  // Check if item is already downloaded
  Future<bool> isDownloaded(MediaItem item) async {
    final downloadDir = await getDownloadDirectory();
    final filename = generateSafeFilename(item);
    final filePath = path.join(downloadDir.path, filename);
    return await File(filePath).exists();
  }
}