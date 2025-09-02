import 'dart:math';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/audio_service.dart';
import '../widgets/visualizer.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;
  final AudioService audioService;
  
  const PlayerScreen({
    super.key,
    required this.mediaItem,
    required this.audioService,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showEqualizer = false;
  List<EqualizerBand> _equalizerBands = [];
  List<String> _presets = [];
  String _selectedPreset = 'Flat';
  bool _equalizerEnabled = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupAnimations();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  Future<void> _initializePlayer() async {
    try {
      // Initialize audio service
      await widget.audioService.initialize();
      
      // Load equalizer presets
      _presets = await widget.audioService.getPresets();
      
      // Get equalizer bands
      _equalizerBands = await widget.audioService.getBands();
      
      // Start playback
      await widget.audioService.playAudio(
        widget.mediaItem.filePath ?? widget.mediaItem.streamUrl ?? '',
        isLocal: widget.mediaItem.isLocal,
      );
      
      setState(() {
        _isPlaying = true;
      });
      
      // Listen to position updates
      widget.audioService.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      
      // Listen to player state
      widget.audioService.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });
      
      // Set duration
      setState(() {
        _duration = widget.audioService.duration ?? Duration.zero;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize player: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.audioService.stop();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioService.pause();
      _rotationController.stop();
    } else {
      await widget.audioService.resume();
      _rotationController.repeat();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).toInt(),
    );
    await widget.audioService.seek(position);
  }

  Future<void> _toggleEqualizer() async {
    final newValue = !_equalizerEnabled;
    await widget.audioService.setEqualizerEnabled(newValue);
    setState(() {
      _equalizerEnabled = newValue;
    });
  }

  Future<void> _applyPreset(String preset) async {
    await widget.audioService.setEqualizerPreset(preset);
    setState(() {
      _selectedPreset = preset;
    });
  }

  Future<void> _setBandLevel(int index, double level) async {
    await widget.audioService.setBandLevel(index, level);
    setState(() {
      _equalizerBands[index] = EqualizerBand(
        index: _equalizerBands[index].index,
        frequency: _equalizerBands[index].frequency,
        level: level,
        minLevel: _equalizerBands[index].minLevel,
        maxLevel: _equalizerBands[index].maxLevel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Visualizer
              const SizedBox(height: 20),
              Visualizer(
                isActive: _isPlaying,
                color: Theme.of(context).colorScheme.primary,
              ),
              
              // Album art with rotation
              _buildAlbumArt(),
              
              // Song info
              _buildSongInfo(),
              
              // Progress bar
              _buildProgressBar(),
              
              // Player controls
              _buildPlayerControls(),
              
              // Equalizer toggle
              _buildEqualizerToggle(),
              
              // Equalizer panel
              if (_showEqualizer) _buildEqualizerPanel(),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _isPlaying ? _rotationAnimation.value : 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.mediaItem.thumbnailUrl != null
                    ? Image.network(
                        widget.mediaItem.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.music_note,
                              size: 100,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          size: 100,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            widget.mediaItem.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.mediaItem.artist ?? 'Unknown Artist',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.mediaItem.album != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.mediaItem.album!,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              thumbColor: Theme.of(context).colorScheme.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 4,
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
              onChanged: (value) {
                _seekTo(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle, size: 30),
            onPressed: () {
              // Shuffle
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 40),
            onPressed: () {
              // Previous track
            },
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _togglePlayPause,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 40),
            onPressed: () {
              // Next track
            },
          ),
          IconButton(
            icon: const Icon(Icons.repeat, size: 30),
            onPressed: () {
              // Repeat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerToggle() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch.adaptive(
            value: _equalizerEnabled,
            onChanged: (value) async {
              await _toggleEqualizer();
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text(
            'Equalizer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showEqualizer = !_showEqualizer;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerPanel() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Presets dropdown
            _buildPresetSelector(),
            
            const SizedBox(height: 16),
            
            // Equalizer bands
            Expanded(
              child: _buildEqualizerBands(),
            ),
            
            const SizedBox(height: 16),
            
            // Additional controls
            _buildAdditionalControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Row(
      children: [
        const Text('Preset: '),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedPreset,
          items: _presets.map((preset) {
            return DropdownMenuItem(
              value: preset,
              child: Text(preset),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _applyPreset(value);
            }
          },
          dropdownColor: Theme.of(context).cardTheme.color,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Reset to flat
            _applyPreset('Flat');
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildEqualizerBands() {
    return Row(
      children: _equalizerBands.asMap().entries.map((entry) {
        final index = entry.key;
        final band = entry.value;
        return Expanded(
          child: Column(
            children: [
              Text(
                '${band.frequency.toInt()}Hz',
                style: const TextStyle(fontSize: 10),
              ),
              RotatedBox(
                quarterTurns: -1,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: band.level,
                    min: band.minLevel,
                    max: band.maxLevel,
                    onChanged: (value) {
                      _setBandLevel(index, value);
                    },
                  ),
                ),
              ),
              Text(
                '${band.level.toInt()}dB',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Bass Boost'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                thumbColor: Theme.of(context).colorScheme.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
              ),
              child: Slider(
                value: 0,
                min: 0,
                max: 1000,
                onChanged: (value) {
                  // Set bass boost
                },
              ),
            ),
          ],
        ),
        Column(
          children: [
            const Text('Virtualizer'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                thumbColor: Theme.of(context).colorScheme.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
              ),
              child: Slider(
                value: 0,
                min: 0,
                max: 1000,
                onChanged: (value) {
                  // Set virtualizer
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}