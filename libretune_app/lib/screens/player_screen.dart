import 'dart:math';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/audio_service.dart';

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

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showEqualizer = false;
  List<EqualizerBand> _equalizerBands = [];
  List<String> _presets = [];
  String _selectedPreset = 'Flat';
  bool _equalizerEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
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
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await widget.audioService.pause();
    } else {
      await widget.audioService.resume();
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
      // Update band levels to match preset
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
      appBar: AppBar(
        title: Text(widget.mediaItem.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
              // Album art
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

  Widget _buildAlbumArt() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
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
          Slider(
            value: _duration.inMilliseconds > 0
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              _seekTo(value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
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
            icon: const Icon(Icons.skip_previous, size: 40),
            onPressed: () {
              // Previous track
            },
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
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
                child: Slider(
                  value: band.level,
                  min: band.minLevel,
                  max: band.maxLevel,
                  onChanged: (value) {
                    _setBandLevel(index, value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
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
            Slider(
              value: 0,
              min: 0,
              max: 1000,
              onChanged: (value) {
                // Set bass boost
              },
            ),
          ],
        ),
        Column(
          children: [
            const Text('Virtualizer'),
            Slider(
              value: 0,
              min: 0,
              max: 1000,
              onChanged: (value) {
                // Set virtualizer
              },
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