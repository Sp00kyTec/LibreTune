import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/download_service.dart';
import '../widgets/media_card.dart';

class DownloadsScreen extends StatefulWidget {
  final DownloadService downloadService;
  
  const DownloadsScreen({super.key, required this.downloadService});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<MediaItem> _downloadedItems = [];
  bool _isLoading = true;
  String _sortOption = 'date';
  bool _ascending = false;

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
      final activeDownloads = widget.downloadService.getActiveDownloads();
      final completedDownloads = activeDownloads
          .where((task) => task.status == DownloadStatus.completed)
          .map((task) => task.mediaItem)
          .toList();

      setState(() {
        _downloadedItems = _sortItems(completedDownloads);
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

  List<MediaItem> _sortItems(List<MediaItem> items) {
    final sortedItems = List<MediaItem>.from(items);
    
    switch (_sortOption) {
      case 'title':
        sortedItems.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'artist':
        sortedItems.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
        break;
      case 'date':
        sortedItems.sort((a, b) => (b.uploadDate ?? DateTime.now())
            .compareTo(a.uploadDate ?? DateTime.now()));
        break;
      case 'size':
        // Would sort by file size in real implementation
        break;
    }
    
    if (_ascending) {
      sortedItems.reversed;
    }
    
    return sortedItems;
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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'sort') {
                  _showSortDialog();
                } else if (value == 'clear') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'sort',
                  child: ListTile(
                    leading: Icon(Icons.sort),
                    title: Text('Sort'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep),
                    title: Text('Clear All'),
                  ),
                ),
              ],
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

    return RefreshIndicator(
      onRefresh: _loadDownloadedItems,
      child: ListView.builder(
        itemCount: _downloadedItems.length,
        itemBuilder: (context, index) {
          final item = _downloadedItems[index];
          return MediaCard(
            item: item,
            onTap: () => _playDownloadedItem(item),
            onPlay: () => _playDownloadedItem(item),
            onDownload: () => _deleteDownload(item),
          );
        },
      ),
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('title', 'Title'),
            _buildSortOption('artist', 'Artist'),
            _buildSortOption('date', 'Date Added'),
            _buildSortOption('size', 'File Size'),
            const Divider(),
            ListTile(
              title: const Text('Ascending'),
              trailing: Switch(
                value: _ascending,
                onChanged: (value) {
                  setState(() {
                    _ascending = value;
                    _downloadedItems = _sortItems(_downloadedItems);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _sortOption,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortOption = value;
            _downloadedItems = _sortItems(_downloadedItems);
          });
          Navigator.of(context).pop();
        }
      },
      title: Text(label),
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
}