import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/media_item.dart';

class MediaCard extends StatefulWidget {
  final MediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final bool isSelected;

  const MediaCard({
    super.key,
    required this.item,
    this.onTap,
    this.onPlay,
    this.onDownload,
    this.isSelected = false,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: widget.isSelected
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: widget.isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Thumbnail with caching
                      _buildThumbnail(),
                      
                      // Content
                      Expanded(
                        child: _buildContent(),
                      ),
                      
                      // Actions
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(16),
        ),
        image: widget.item.thumbnailUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(widget.item.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey[800],
      ),
      child: widget.item.thumbnailUrl == null
          ? Center(
              child: _buildMediaTypeIcon(),
            )
          : null,
    );
  }

  Widget _buildMediaTypeIcon() {
    IconData icon;
    switch (widget.item.type) {
      case MediaType.audio:
        icon = Icons.audiotrack;
        break;
      case MediaType.video:
        icon = Icons.video_library;
        break;
      case MediaType.podcast:
        icon = Icons.podcasts;
        break;
      case MediaType.musicVideo:
        icon = Icons.music_video;
        break;
    }
    
    return Icon(
      icon,
      color: Theme.of(context).colorScheme.primary,
      size: 32,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.item.artist ?? 'Unknown Artist',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _getSourceIcon(widget.item.source),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(widget.item.duration),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              if (widget.item.viewCount != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${_formatViewCount(widget.item.viewCount!)} views',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: widget.onDownload,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: widget.onPlay,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  String _getSourceIcon(SourceType source) {
    switch (source) {
      case SourceType.youtube:
        return '📺';
      case SourceType.soundcloud:
        return '🔊';
      case SourceType.bandcamp:
        return '🎟️';
      case SourceType.local:
        return '📱';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}