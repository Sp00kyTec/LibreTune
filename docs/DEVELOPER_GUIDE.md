# LibreTune Developer Guide

## Project Structure
libretune_app/
├── lib/
│   ├── main.dart              # Entry point
│   ├── models/                # Data models
│   ├── services/              # Business logic
│   ├── screens/               # UI screens
│   ├── widgets/               # Reusable components
│   ├── themes/                # Theme definitions
│   └── utils/                 # Utility functions
├── test/                      # Unit and integration tests
├── assets/                    # Static assets
├── docs/                      # Documentation
└── pubspec.yaml               # Dependencies and metadata

## Architecture

LibreTune follows a clean architecture pattern:

### Models Layer
- Data structures and business objects
- JSON serialization/deserialization
- Data validation and business rules

### Services Layer
- Business logic implementation
- API integrations
- Data processing and transformation

### UI Layer
- Screens and widgets
- State management
- User interactions

### Utilities Layer
- Helper functions
- Common utilities
- Cross-cutting concerns

## Development Setup

### Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code
- Android/iOS development environment

### Installation
```bash
git clone https://github.com/Sp00kyTec/LibreTune.git
cd LibreTune/libretune_app
flutter pub get


### Running Tests
# Run all tests
flutter test

# Run specific test file
flutter test test/models/media_item_test.dart

# Run with coverage
flutter test --coverage

Adding New Features 
1. New Content Source 

    Create a new class implementing ContentSource
    Add the source to ContentAggregator
    Update UI to display the new source
     

2. New Media Type 

    Add to MediaType enum
    Update UI components to handle the new type
    Add appropriate icons and handling
     

3. New Audio Enhancement 

    Extend the Equalizer class
    Add UI controls in the player screen
    Update audio service to apply the enhancement
     

Testing Strategy 
Unit Tests 

    Test individual functions and methods
    Mock external dependencies
    Cover edge cases and error conditions
     

Widget Tests 

    Test UI components in isolation
    Verify widget behavior and interactions
    Test different states and configurations
     

Integration Tests 

    Test complete user flows
    Verify service integrations
    Test end-to-end functionality
     

Code Quality 
Linting 

Follow the rules defined in analysis_options.yaml: 

    Use consistent naming conventions
    Prefer single quotes for strings
    Use const constructors where possible
    Follow Dart style guide
     

Documentation 

    Document public APIs
    Add comments for complex logic
    Keep README and docs updated
     

Contributing 
Pull Request Process 

    Fork the repository
    Create a feature branch
    Make changes and add tests
    Run all tests and ensure they pass
    Update documentation if needed
    Submit pull request
     

Code Review Guidelines 

    Review for functionality and correctness
    Check for performance issues
    Verify test coverage
    Ensure code follows style guidelines
     

###Deployment
Building Release
# Android
flutter build apk --release

# iOS (Mac only)
flutter build ios --release

ersion Management 

    Update version in pubspec.yaml
    Create Git tag for release
    Update changelog
     

Dependencies 
Core Dependencies 

    flutter: UI framework
    http: HTTP client
    just_audio: Audio playback
    path_provider: File system access
    permission_handler: Permission management
     

Development Dependencies 

    flutter_test: Testing framework
    mockito: Mock objects for testing
    flutter_lints: Code linting
     

Performance Considerations 
Caching 

    Use flutter_cache_manager for image caching
    Cache API responses where appropriate
    Implement proper cache invalidation
     

Memory Management 

    Dispose of resources properly
    Use const widgets where possible
    Optimize image loading and display
     

Network Optimization 

    Implement proper error handling
    Use connection pooling
    Minimize API calls through caching
     

Security 
Data Protection 

    No personal data collection
    Secure storage for settings
    Proper permission handling
     

Network Security 

    Use HTTPS for all API calls
    Validate API responses
    Handle network errors gracefully
     

Internationalization 

Currently, LibreTune supports English only. To add new languages: 

    Add localization files
    Update pubspec.yaml
    Implement language switching in settings
     

### 7. API Documentation

**docs/API_REFERENCE.md**
```markdown
# LibreTune API Reference

## Models

### MediaItem
Represents a media item (song, video, podcast)

**Properties:**
- `id` (String): Unique identifier
- `title` (String): Media title
- `artist` (String?): Artist name
- `album` (String?): Album name
- `description` (String?): Description
- `thumbnailUrl` (String?): Thumbnail image URL
- `streamUrl` (String?): Streaming URL
- `filePath` (String?): Local file path
- `duration` (Duration?): Media duration
- `uploadDate` (DateTime?): Upload date
- `viewCount` (int?): View count
- `tags` (List<String>?): Tags
- `type` (MediaType): Media type
- `source` (SourceType): Source platform
- `metadata` (Map<String, dynamic>?): Additional metadata
- `isDownloaded` (bool): Download status
- `isLocal` (bool): Local file status

**Methods:**
- `copyWith()`: Create copy with modified properties
- `toJson()`: Convert to JSON
- `fromJson()`: Create from JSON

### DownloadTask
Represents a download operation

**Properties:**
- `id` (String): Task identifier
- `mediaItem` (MediaItem): Associated media item
- `status` (DownloadStatus): Current status
- `progress` (double): Download progress (0.0-1.0)
- `filePath` (String?): Saved file path
- `error` (String?): Error message
- `createdAt` (DateTime): Creation timestamp

## Services

### ContentAggregator
Manages multiple content sources

**Methods:**
- `searchAll(query, limit)`: Search all sources
- `searchSource(source, query, limit)`: Search specific source
- `getTrendingAll(limit)`: Get trending from all sources
- `getCategoryAll(category, limit)`: Get category content
- `getStreamUrl(item)`: Get stream URL for item
- `getDetails(item)`: Get detailed item information

### DownloadService
Manages file downloads

**Methods:**
- `downloadContent(item, callbacks)`: Start download
- `getActiveDownloads()`: Get active downloads
- `cancelDownload(taskId)`: Cancel download
- `isDownloaded(item)`: Check if item is downloaded
- `getDownloadDirectory()`: Get download directory
- `generateSafeFilename(item)`: Generate safe filename

### AudioService
Manages audio playback and enhancement

**Methods:**
- `initialize()`: Initialize service
- `playAudio(source, isLocal)`: Start playback
- `pause()`: Pause playback
- `resume()`: Resume playback
- `stop()`: Stop playback
- `seek(position)`: Seek to position
- `setVolume(volume)`: Set volume
- `setEqualizerEnabled(enabled)`: Enable/disable equalizer
- `setEqualizerPreset(preset)`: Set equalizer preset
- `setBandLevel(index, level)`: Set band level
- `getBands()`: Get equalizer bands
- `getPresets()`: Get available presets

## Enums

### MediaType
- `audio`: Audio files
- `video`: Video files
- `podcast`: Podcast episodes
- `musicVideo`: Music videos

### SourceType
- `youtube`: YouTube content
- `soundcloud`: SoundCloud content
- `bandcamp`: Bandcamp content
- `local`: Local files

### DownloadStatus
- `queued`: Waiting to start
- `downloading`: Currently downloading
- `completed`: Download finished
- `failed`: Download failed
- `cancelled`: Download cancelled
- `paused`: Download paused

### AudioQuality
- `low`: 128 kbps
- `medium`: 192 kbps
- `high`: 256 kbps
- `veryHigh`: 320 kbps

## Widgets

### MediaCard
Displays media item information

**Properties:**
- `item` (MediaItem): Media item to display
- `onTap` (VoidCallback?): Tap callback
- `onPlay` (VoidCallback?): Play callback
- `onDownload` (VoidCallback?): Download callback
- `isSelected` (bool): Selection state

### AnimatedBottomNavBar
Animated bottom navigation bar

**Properties:**
- `currentIndex` (int): Current selected index
- `onTap` (Function(int)): Tap callback

### Visualizer
Audio visualization widget

**Properties:**
- `isActive` (bool): Animation state
- `color` (Color): Visualization color

## Utilities

### ErrorHandler
Error handling utilities

**Methods:**
- `showSnackBar(context, message, isError)`: Show snackbar
- `showErrorDialog(context, title, message)`: Show error dialog
- `formatError(error)`: Format error message

### LibreTuneCacheManager
Cache management utilities

**Methods:**
- `preloadThumbnails(urls)`: Preload images
- `clearCache()`: Clear cached data
- `getCacheSize()`: Get cache size

### SettingsService
Application settings management

**Methods:**
- `initialize()`: Initialize service
- `setThemeMode(mode)`: Set theme mode
- `setAudioQuality(quality)`: Set audio quality
- `setDownloadLocation(path)`: Set download location
- `setEqualizerEnabled(enabled)`: Set equalizer state
- `setNotificationsEnabled(enabled)`: Set notification state