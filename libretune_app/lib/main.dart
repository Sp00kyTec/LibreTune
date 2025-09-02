import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'services/content_aggregator.dart';
import 'services/download_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  runApp(LibreTuneApp(settingsService: settingsService));
}

class LibreTuneApp extends StatefulWidget {
  final SettingsService settingsService;
  
  const LibreTuneApp({super.key, required this.settingsService});

  @override
  State<LibreTuneApp> widget => _LibreTuneAppState();
}

class _LibreTuneAppState extends State<LibreTuneApp> {
  late ContentAggregator contentAggregator;
  late DownloadService downloadService;
  late AudioService audioService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    contentAggregator = ContentAggregator();
    downloadService = DownloadService();
    audioService = AudioService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibreTune',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: widget.settingsService.themeMode,
      home: HomeScreen(
        contentAggregator: contentAggregator,
        downloadService: downloadService,
        audioService: audioService,
      ),
      routes: {
        '/downloads': (context) => DownloadsScreen(
              downloadService: downloadService,
            ),
        '/settings': (context) => SettingsScreen(
              settingsService: widget.settingsService,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}