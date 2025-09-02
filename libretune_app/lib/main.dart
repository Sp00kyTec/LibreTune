import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/player_screen.dart';
import 'services/download_service.dart';
import 'services/youtube_service.dart';
import 'services/audio_service.dart';

void main() {
  runApp(const LibreTuneApp());
}

class LibreTuneApp extends StatelessWidget {
  const LibreTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final youtubeService = YouTubeService();
    final downloadService = DownloadService();
    final audioService = AudioService();
    
    return MaterialApp(
      title: 'LibreTune',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: HomeScreen(
        youtubeService: youtubeService,
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