import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../utils/cache_manager.dart';
import '../utils/error_handler.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  
  const SettingsScreen({super.key, required this.settingsService});

  @override
  State<SettingsScreen> widget => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  AudioQuality _audioQuality = AudioQuality.high;
  bool _equalizerEnabled = true;
  bool _notificationsEnabled = true;
  int _cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCacheInfo();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _themeMode = widget.settingsService.themeMode;
      _audioQuality = widget.settingsService.audioQuality;
      _equalizerEnabled = widget.settingsService.equalizerEnabled;
      _notificationsEnabled = widget.settingsService.notificationsEnabled;
    });
  }

  Future<void> _loadCacheInfo() async {
    try {
      final size = await LibreTuneCacheManager.getCacheSize();
      setState(() {
        _cacheSize = size;
      });
    } catch (e) {
      // Ignore cache size errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          const ListTile(
            title: Text('Appearance'),
            textColor: Colors.grey,
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeName(_themeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updateThemeMode(value);
                }
              },
            ),
          ),
          
          // Audio section
          const ListTile(
            title: Text('Audio'),
            textColor: Colors.grey,
          ),
          ListTile(
            title: const Text('Audio Quality'),
            subtitle: Text(_audioQuality.displayName),
            trailing: DropdownButton<AudioQuality>(
              value: _audioQuality,
              items: AudioQuality.values.map((quality) {
                return DropdownMenuItem(
                  value: quality,
                  child: Text(quality.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateAudioQuality(value);
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Equalizer'),
            subtitle: const Text('Enhance audio with equalizer'),
            value: _equalizerEnabled,
            onChanged: _updateEqualizerEnabled,
          ),
          
          // Notifications section
          const ListTile(
            title: Text('Notifications'),
            textColor: Colors.grey,
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get updates about downloads and playback'),
            value: _notificationsEnabled,
            onChanged: _updateNotificationsEnabled,
          ),
          
          // Storage section
          const ListTile(
            title: Text('Storage'),
            textColor: Colors.grey,
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: Text('Cached  ${_formatBytes(_cacheSize)}'),
            trailing: OutlinedButton(
              onPressed: _clearCache,
              child: const Text('Clear'),
            ),
          ),
          
          // About section
          const ListTile(
            title: Text('About'),
            textColor: Colors.grey,
          ),
          const ListTile(
            title: Text('LibreTune'),
            subtitle: Text('Version 0.1.0'),
          ),
          const ListTile(
            title: Text('Open Source'),
            subtitle: Text('Licensed under MIT License'),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    try {
      await widget.settingsService.setThemeMode(mode);
      setState(() {
        _themeMode = mode;
      });
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Theme updated', isError: false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Failed to update theme: ${ErrorHandler.formatError(e)}');
      }
    }
  }

  Future<void> _updateAudioQuality(AudioQuality quality) async {
    try {
      await widget.settingsService.setAudioQuality(quality);
      setState(() {
        _audioQuality = quality;
      });
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Audio quality updated', isError: false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Failed to update audio quality: ${ErrorHandler.formatError(e)}');
      }
    }
  }

  Future<void> _updateEqualizerEnabled(bool enabled) async {
    try {
      await widget.settingsService.setEqualizerEnabled(enabled);
      setState(() {
        _equalizerEnabled = enabled;
      });
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Equalizer ${enabled ? 'enabled' : 'disabled'}', isError: false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Failed to update equalizer: ${ErrorHandler.formatError(e)}');
      }
    }
  }

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    try {
      await widget.settingsService.setNotificationsEnabled(enabled);
      setState(() {
        _notificationsEnabled = enabled;
      });
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Notifications ${enabled ? 'enabled' : 'disabled'}', isError: false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Failed to update notifications: ${ErrorHandler.formatError(e)}');
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      await LibreTuneCacheManager.clearCache();
      setState(() {
        _cacheSize = 0;
      });
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Cache cleared', isError: false);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Failed to clear cache: ${ErrorHandler.formatError(e)}');
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
}