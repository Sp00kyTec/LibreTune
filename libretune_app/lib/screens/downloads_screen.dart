import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/download_service.dart';

class DownloadsScreen extends StatefulWidget {
  final DownloadService downloadService;
  
  const DownloadsScreen({super.key, required this.downloadService});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<MediaItem> _downloadedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedItems();
  }

  Future<void> _loadDownloadedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, this would scan the download directory
      // For now, we'll simulate with active downloads
      final activeDownloads = widget.downloadService.getActiveDownloads();
      final completedDownloads = activeDownloads
          .where((task) => task.status == DownloadStatus.completed)
          .map((task) => task.mediaItem)
          .toList();

      setState(() {
        _downloadedItems = completedDownloads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load downloads: $e')),
        );
      }
    }
  }

  Future<void> _deleteDownload(MediaItem item) async {
    if (item.filePath == null) return;

    try {
      final file = File(item.filePath!);
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _downloadedItems.remove(item);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (_downloadedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearAllDialog();
              },
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_downloadedItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _downloadedItems.length,
      itemBuilder: (context, index) {
        final item = _downloadedItems[index];
        return _buildDownloadItem(item);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No downloads yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Downloaded content will appear here',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home to download content
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.download),
            label: const Text('Start Downloading'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(MediaItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.thumbnailUrl != null
              ? Image.network(
                  item.thumbnailUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[800],
                      child: Icon(
                        item.type == MediaType.audio 
                            ? Icons.audiotrack 
                            : Icons.video_library,
                      ),
                    );
                  },
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: Icon(
                    item.type == MediaType.audio 
                        ? Icons.audiotrack 
                        : Icons.video_library,
                  ),
                ),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${item.artist ?? 'Unknown'} • '
          '${_formatMediaType(item.type)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDelete(item);
            } else if (value == 'open') {
              _openInExternalPlayer(item);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: ListTile(
                leading: Icon(Icons.open_in_new),
                title: Text('Open with...'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
        onTap: () {
          // Play the downloaded item
          _playDownloadedItem(item);
        },
      ),
    );
  }

  void _confirmDelete(MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDownload(item);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text(
          'This will delete all downloaded content. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllDownloads();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllDownloads() async {
    try {
      for (final item in _downloadedItems) {
        if (item.filePath != null) {
          final file = File(item.filePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      setState(() {
        _downloadedItems.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All downloads cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear downloads: $e')),
        );
      }
    }
  }

  void _playDownloadedItem(MediaItem item) {
    // TODO: Implement playback for downloaded items
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playback not implemented yet')),
      );
    }
  }

  void _openInExternalPlayer(MediaItem item) {
    // TODO: Implement opening in external player
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening in external player...')),
      );
    }
  }

  String _formatMediaType(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return 'Audio';
      case MediaType.video:
        return 'Video';
      case MediaType.podcast:
        return 'Podcast';
      case MediaType.musicVideo:
        return 'Music Video';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}