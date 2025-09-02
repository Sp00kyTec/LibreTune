import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/content_aggregator.dart';
import '../services/download_service.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final ContentAggregator contentAggregator;
  final DownloadService downloadService;
  final AudioService audioService;
  
  const HomeScreen({
    super.key,
    required this.contentAggregator,
    required this.downloadService,
    required this.audioService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  ContentSource? _selectedSource;
  List<MediaItem> _trendingContent = [];

  @override
  void initState() {
    super.initState();
    _loadTrendingContent();
  }

  Future<void> _loadTrendingContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trending = await widget.contentAggregator.getTrendingAll(limit: 20);
      setState(() {
        _trendingContent = trending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load trending content: $e')),
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      List<MediaItem> results;
      
      if (_selectedSource != null) {
        // Search specific source
        results = await widget.contentAggregator.searchSource(
          _selectedSource!, 
          query,
          limit: 30,
        );
      } else {
        // Search all sources
        results = await widget.contentAggregator.searchAll(query, limit: 30);
      }
      
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

  Future<void> _downloadItem(MediaItem item) async {
    try {
      // Get stream URL first
      final streamUrl = await widget.contentAggregator.getStreamUrl(item);
      if (streamUrl == null) {
        throw Exception('Could not get stream URL');
      }
      
      // Update item with stream URL
      final updatedItem = item.copyWith(streamUrl: streamUrl);
      
      final task = await widget.downloadService.downloadContent(
        updatedItem,
        onProgress: (progress) {
          print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
        onComplete: (filePath) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloaded: ${item.title}')),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download failed: $error')),
            );
          }
        },
      );
      
      print('Download started: ${task.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
        );
      }
    }
  }

  void _playItem(MediaItem item) async {
    try {
      // Get stream URL first
      final streamUrl = await widget.contentAggregator.getStreamUrl(item);
      if (streamUrl == null) {
        throw Exception('Could not get stream URL');
      }
      
      // Update item with stream URL
      final updatedItem = item.copyWith(streamUrl: streamUrl);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            mediaItem: updatedItem,
            audioService: widget.audioService,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback error: $e')),
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
              Navigator.pushNamed(context, '/downloads');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Source selector and search
          _buildSearchSection(),
          
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

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Source selector dropdown
          Row(
            children: [
              const Text('Source:'),
              const SizedBox(width: 8),
              DropdownButton<ContentSource?>(
                value: _selectedSource,
                hint: const Text('All Sources'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Sources'),
                  ),
                  ...widget.contentAggregator.sources.map((source) {
                    return DropdownMenuItem(
                      value: source,
                      child: Row(
                        children: [
                          Text(source.icon),
                          const SizedBox(width: 8),
                          Text(source.name),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Search field
          TextField(
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    } else if (_trendingContent.isNotEmpty && !_isLoading) {
      return _buildTrendingContent();
    } else if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return _buildWelcomeScreen();
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildMediaItemCard(item);
      },
    );
  }

  Widget _buildTrendingContent() {
    return ListView.builder(
      itemCount: _trendingContent.length,
      itemBuilder: (context, index) {
        final item = _trendingContent[index];
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
            onPressed: _loadTrendingContent,
            icon: const Icon(Icons.explore),
            label: const Text('Explore Trending'),
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
                      child: _buildMediaTypeIcon(item.type),
                    );
                  },
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: _buildMediaTypeIcon(item.type),
                ),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.artist ?? 'Unknown'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text(
                  _getSourceIcon(item.source),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDuration(item.duration)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                _downloadItem(item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                _playItem(item);
              },
            ),
          ],
        ),
        onTap: () {
          _playItem(item);
        },
      ),
    );
  }

  Widget _buildMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return const Icon(Icons.audiotrack, size: 24);
      case MediaType.video:
        return const Icon(Icons.video_library, size: 24);
      case MediaType.podcast:
        return const Icon(Icons.podcasts, size: 24);
      case MediaType.musicVideo:
        return const Icon(Icons.music_video, size: 24);
    }
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
}