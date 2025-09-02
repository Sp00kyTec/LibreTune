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

  // JSON serialization
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      streamUrl: json['streamUrl'] as String?,
      filePath: json['filePath'] as String?,
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int) 
          : null,
      uploadDate: json['uploadDate'] != null 
          ? DateTime.parse(json['uploadDate'] as String) 
          : null,
      viewCount: json['viewCount'] as int?,
      tags: (json['tags'] as List?)?.cast<String>(),
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${json['type']}',
        orElse: () => MediaType.audio,
      ),
      source: SourceType.values.firstWhere(
        (e) => e.toString() == 'SourceType.${json['source']}',
        orElse: () => SourceType.youtube,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'uploadDate': uploadDate?.toIso8601String(),
      'viewCount': viewCount,
      'tags': tags,
      'type': type.toString().split('.').last,
      'source': source.toString().split('.').last,
      'metadata': metadata,
      'isDownloaded': isDownloaded,
      'isLocal': isLocal,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}