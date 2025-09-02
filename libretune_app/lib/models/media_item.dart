enum MediaType {
  audio,
  video,
  podcast,
  musicVideo
}

enum SourceType {
  youtube,
  soundcloud,
  bandcamp,
  local
}

class MediaItem {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String? description;
  final String? thumbnailUrl;
  final String? streamUrl;
  final String? filePath;
  final Duration? duration;
  final DateTime? uploadDate;
  final int? viewCount;
  final List<String>? tags;
  final MediaType type;
  final SourceType source;
  final Map<String, dynamic>? metadata;
  final bool isDownloaded;
  final bool isLocal;

  MediaItem({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.description,
    this.thumbnailUrl,
    this.streamUrl,
    this.filePath,
    this.duration,
    this.uploadDate,
    this.viewCount,
    this.tags,
    required this.type,
    required this.source,
    this.metadata,
    this.isDownloaded = false,
    this.isLocal = false,
  });

  MediaItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? description,
    String? thumbnailUrl,
    String? streamUrl,
    String? filePath,
    Duration? duration,
    DateTime? uploadDate,
    int? viewCount,
    List<String>? tags,
    MediaType? type,
    SourceType? source,
    Map<String, dynamic>? metadata,
    bool? isDownloaded,
    bool? isLocal,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      uploadDate: uploadDate ?? this.uploadDate,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}