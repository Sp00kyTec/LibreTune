import 'media_item.dart';

// Status of download tasks
enum DownloadStatus {
  queued,
  downloading,
  completed,
  failed,
  cancelled,
  paused,
}

// Download task model for tracking progress
class DownloadTask {
  final String id;
  MediaItem mediaItem;
  DownloadStatus status;
  double progress;
  String? filePath;
  String? error;
  final DateTime createdAt;
  
  DownloadTask({
    required this.id,
    required this.mediaItem,
    required this.status,
    required this.progress,
    this.filePath,
    this.error,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}