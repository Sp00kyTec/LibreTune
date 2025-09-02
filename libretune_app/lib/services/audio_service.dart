import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final Equalizer _equalizer = Equalizer();
  bool _isInitialized = false;

  // Get the audio player instance
  AudioPlayer get player => _player;

  // Initialize audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize equalizer
      await _equalizer.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize audio service: $e');
    }
  }

  // Play audio from URL or file path
  Future<void> playAudio(String source, {bool isLocal = false}) async {
    try {
      if (isLocal) {
        await _player.setFilePath(source);
      } else {
        await _player.setUrl(source);
      }
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  // Stop playback
  Future<void> stop() async {
    await _player.stop();
  }

  // Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _player.play();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  // Get current playback position
  Stream<Duration> get positionStream => _player.positionStream;

  // Get total duration
  Duration? get duration => _player.duration;

  // Get playback state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // Equalizer methods
  Future<void> setEqualizerEnabled(bool enabled) async {
    await _equalizer.setEnabled(enabled);
  }

  Future<void> setEqualizerPreset(String presetName) async {
    await _equalizer.loadPreset(presetName);
  }

  Future<void> setBandLevel(int bandIndex, double level) async {
    await _equalizer.setBandLevel(bandIndex, level);
  }

  Future<List<EqualizerBand>> getBands() async {
    return await _equalizer.getBands();
  }

  Future<List<String>> getPresets() async {
    return await _equalizer.getPresets();
  }

  // Audio enhancement features
  Future<void> setBassBoost(int level) async {
    await _equalizer.setBassBoost(level);
  }

  Future<void> setVirtualizer(int level) async {
    await _equalizer.setVirtualizer(level);
  }

  Future<void> setReverbPreset(ReverbPreset preset) async {
    await _equalizer.setReverbPreset(preset);
  }

  // Cleanup
  void dispose() {
    _player.dispose();
    _equalizer.dispose();
  }
}

// Equalizer band model
class EqualizerBand {
  final int index;
  final double frequency;
  final double level;
  final double minLevel;
  final double maxLevel;

  EqualizerBand({
    required this.index,
    required this.frequency,
    required this.level,
    required this.minLevel,
    required this.maxLevel,
  });
}

// Equalizer class (simplified implementation)
class Equalizer {
  bool _enabled = false;
  final List<EqualizerBand> _bands = [];
  final List<String> _presets = [
    'Flat',
    'Classical',
    'Club',
    'Dance',
    'Full Bass',
    'Full Treble',
    'Headphones',
    'Large Hall',
    'Live',
    'Party',
    'Pop',
    'Reggae',
    'Rock',
    'Ska',
    'Soft',
    'Soft Rock',
    'Techno',
  ];

  Future<void> initialize() async {
    // Initialize with default bands (typical 10-band equalizer)
    _bands.addAll([
      EqualizerBand(
        index: 0,
        frequency: 31.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 1,
        frequency: 62.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 2,
        frequency: 125.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 3,
        frequency: 250.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 4,
        frequency: 500.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 5,
        frequency: 1000.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 6,
        frequency: 2000.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 7,
        frequency: 4000.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 8,
        frequency: 8000.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
      EqualizerBand(
        index: 9,
        frequency: 16000.0,
        level: 0.0,
        minLevel: -15.0,
        maxLevel: 15.0,
      ),
    ]);
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    // In a real implementation, this would enable/disable the audio effect
    print('Equalizer ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> loadPreset(String presetName) async {
    if (!_presets.contains(presetName)) {
      throw Exception('Preset not found: $presetName');
    }

    // Apply preset settings to bands
    // This is a simplified implementation
    switch (presetName) {
      case 'Classical':
        _applyPresetLevels([-3, -1, 0, 0, 0, 0, 2, 3, 3, 3]);
        break;
      case 'Rock':
        _applyPresetLevels([4, 2, 0, -2, -3, -2, 0, 2, 4, 4]);
        break;
      case 'Pop':
        _applyPresetLevels([-1, 0, 1, 2, 3, 2, 1, 0, -1, -1]);
        break;
      case 'Jazz':
        _applyPresetLevels([2, 1, 0, -1, -2, -1, 0, 1, 2, 1]);
        break;
      default: // Flat
        _applyPresetLevels([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    }
  }

  void _applyPresetLevels(List<double> levels) {
    for (int i = 0; i < levels.length && i < _bands.length; i++) {
      _bands[i] = EqualizerBand(
        index: _bands[i].index,
        frequency: _bands[i].frequency,
        level: levels[i],
        minLevel: _bands[i].minLevel,
        maxLevel: _bands[i].maxLevel,
      );
    }
  }

  Future<void> setBandLevel(int bandIndex, double level) async {
    if (bandIndex >= 0 && bandIndex < _bands.length) {
      final band = _bands[bandIndex];
      final clampedLevel = level.clamp(band.minLevel, band.maxLevel);
      
      _bands[bandIndex] = EqualizerBand(
        index: band.index,
        frequency: band.frequency,
        level: clampedLevel,
        minLevel: band.minLevel,
        maxLevel: band.maxLevel,
      );
    }
  }

  Future<List<EqualizerBand>> getBands() async {
    return List.unmodifiable(_bands);
  }

  Future<List<String>> getPresets() async {
    return List.unmodifiable(_presets);
  }

  Future<void> setBassBoost(int level) async {
    // Level 0-1000 typically
    print('Bass boost set to: $level');
  }

  Future<void> setVirtualizer(int level) async {
    // Level 0-1000 typically
    print('Virtualizer set to: $level');
  }

  Future<void> setReverbPreset(ReverbPreset preset) async {
    print('Reverb preset set to: ${preset.name}');
  }

  void dispose() {
    _enabled = false;
    _bands.clear();
  }
}

// Reverb presets
enum ReverbPreset {
  none,
  smallRoom,
  mediumRoom,
  largeRoom,
  mediumHall,
  largeHall,
  plate,
}

extension ReverbPresetName on ReverbPreset {
  String get name {
    switch (this) {
      case ReverbPreset.none:
        return 'None';
      case ReverbPreset.smallRoom:
        return 'Small Room';
      case ReverbPreset.mediumRoom:
        return 'Medium Room';
      case ReverbPreset.largeRoom:
        return 'Large Room';
      case ReverbPreset.mediumHall:
        return 'Medium Hall';
      case ReverbPreset.largeHall:
        return 'Large Hall';
      case ReverbPreset.plate:
        return 'Plate';
    }
  }
}

// Player state
enum PlayerState {
  stopped,
  playing,
  paused,
  buffering,
}