import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _audioQualityKey = 'audio_quality';
  static const String _downloadLocationKey = 'download_location';
  static const String _equalizerEnabledKey = 'equalizer_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  
  late SharedPreferences _prefs;
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }
  
  // Theme settings
  ThemeMode get themeMode {
    final mode = _prefs.getString(_themeModeKey) ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode.toString().split('.').last;
    await _prefs.setString(_themeModeKey, modeString);
  }
  
  // Audio quality settings
  AudioQuality get audioQuality {
    final quality = _prefs.getString(_audioQualityKey) ?? 'high';
    return AudioQuality.values.firstWhere(
      (e) => e.name == quality,
      orElse: () => AudioQuality.high,
    );
  }
  
  Future<void> setAudioQuality(AudioQuality quality) async {
    await _prefs.setString(_audioQualityKey, quality.name);
  }
  
  // Download location
  String get downloadLocation {
    return _prefs.getString(_downloadLocationKey) ?? '/storage/emulated/0/Download/LibreTune';
  }
  
  Future<void> setDownloadLocation(String path) async {
    await _prefs.setString(_downloadLocationKey, path);
  }
  
  // Equalizer settings
  bool get equalizerEnabled {
    return _prefs.getBool(_equalizerEnabledKey) ?? true;
  }
  
  Future<void> setEqualizerEnabled(bool enabled) async {
    await _prefs.setBool(_equalizerEnabledKey, enabled);
  }
  
  // Notifications
  bool get notificationsEnabled {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }
}

enum AudioQuality {
  low('Low', 128),
  medium('Medium', 192),
  high('High', 256),
  veryHigh('Very High', 320);
  
  final String displayName;
  final int bitrate;
  
  const AudioQuality(this.displayName, this.bitrate);
  
  @override
  String toString() => displayName;
}