import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/content_aggregator.dart';
import '../services/download_service.dart';
import '../services/audio_service.dart';
import '../widgets/media_card.dart';
import '../widgets/bottom_nav_bar.dart';
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
  int _currentIndex = 0;

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
      body: _buildBody(),
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Handle navigation
          if (index == 2) {
            Navigator.pushNamed(context, '/downloads');
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('LibreTune'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LibreTune',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Trending section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending Now',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _loadTrendingContent,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
        
        // Trending content
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _trendingContent[index];
                return MediaCard(
                  item: item,
                  onTap: () => _playItem(item),
                  onPlay: () => _playItem(item),
                  onDownload: () => _downloadItem(item),
                );
              },
              childCount: _trendingContent.length,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchContent() {
    return CustomScrollView(
      slivers: [
        // Search app bar
        SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search music, videos, podcasts...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
            onSubmitted: _performSearch,
          ),
        ),
        
        // Source selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                  dropdownColor: Theme.of(context).cardTheme.color,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
        
        // Search results
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_searchResults.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _searchResults[index];
                return MediaCard(
                  item: item,
                  onTap: () => _playItem(item),
                  onPlay: () => _playItem(item),
                  onDownload: () => _downloadItem(item),
                );
              },
              childCount: _searchResults.length,
            ),
          )
        else
          const SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Search for music, videos, or podcasts',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}