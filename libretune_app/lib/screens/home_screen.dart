import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/youtube_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final YouTubeService _youtubeService = YouTubeService();
  final TextEditingController _searchController = TextEditingController();
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final results = await _youtubeService.searchContent(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibreTune'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Navigate to downloads
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search music, videos, podcasts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: _performSearch,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchResults.isEmpty && !_isLoading) {
      return _buildWelcomeScreen();
    }
    
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildMediaItemCard(item);
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'LibreTune',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Free, open-source streaming',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.text = 'music';
              _performSearch('music');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Music'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItemCard(MediaItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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
                      child: const Icon(Icons.music_note),
                    );
                  },
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note),
                ),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${item.artist ?? 'Unknown'} • '
          '${_formatDuration(item.duration)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Download item
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Play item
              },
            ),
          ],
        ),
        onTap: () {
          // Show item details
        },
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}