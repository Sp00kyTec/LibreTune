import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LibreTuneApp());
}

class LibreTuneApp extends StatelessWidget {
  const LibreTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}