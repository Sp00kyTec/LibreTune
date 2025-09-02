import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/player_screen.dart';
import 'services/content_aggregator.dart';
import 'services/download_service.dart';
import 'services/audio_service.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const LibreTuneApp());
}

class LibreTuneApp extends StatelessWidget {
  const LibreTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final contentAggregator = ContentAggregator();
    final downloadService = DownloadService();
    final audioService = AudioService();
    
    return MaterialApp(
      title: 'LibreTune',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: HomeScreen(
        contentAggregator: contentAggregator,
        downloadService: downloadService,
        audioService: audioService,
      ),
      routes: {
        '/downloads': (context) => DownloadsScreen(
              downloadService: downloadService,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}