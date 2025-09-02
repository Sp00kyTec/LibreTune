# LibreTune

An open-source, privacy-focused streaming client that aggregates content from multiple free sources with true offline ownership.

## Features
- ✅ Multi-source content aggregation (YouTube, SoundCloud, Bandcamp)
- ✅ True offline ownership with public storage access
- ✅ Professional audio enhancement with equalizer
- ✅ Futuristic UI/UX with beautiful animations
- ✅ No ads - completely free and open-source
- ✅ Privacy-focused design

## Development Setup

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio or VS Code
- Android SDK (for Android development)
- Xcode (for iOS development - optional)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Sp00kyTec/LibreTune.git
   cd LibreTune/libretune_app

2. **Install Flutter dependencies:** 
    ```bash
    flutter pub get

3. **Verify setup:**
    ```bash
    flutter doctor

### Running the App 
**Android:**
    ```bash
    flutter run
**iOS (Mac only):**
    ```bash
    flutter run

### Project Structure
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
├── services/                 # Business logic
├── screens/                  # UI screens
├── widgets/                  # Reusable components
├── themes/                   # Theme definitions
└── utils/                    # Utility functions

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### License
MIT License


### 2. Development Environment Configuration

**libretune_app/.vscode/settings.json**
```json
{
    "dart.flutterSdkPath": "/path/to/flutter",
    "dart.pubAdditionalArgs": ["--no-package-symlinks"],
    "editor.formatOnSave": true,
    "dart.lineLength": 100,
    "files.exclude": {
        "**/*.dart_tool": true,
        "**/*.pub": true,
        "**/build": true
    }
}

**libretune_app/.vscode/launch.json**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart"
        }
    ]
}
