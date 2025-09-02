# LibreTune

An open-source, privacy-focused streaming client that aggregates content from multiple free sources with true offline ownership.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)

## Features

✅ **Multi-source Content Aggregation** - YouTube, SoundCloud, Bandcamp
✅ **True Offline Ownership** - Files saved to public storage, accessible by other apps
✅ **Professional Audio Enhancement** - Equalizer, bass boost, virtualizer
✅ **Futuristic UI/UX** - Beautiful animations and modern design
✅ **No Ads** - Completely free and open-source
✅ **Privacy Focused** - No data collection or tracking
✅ **Cross-Platform** - Android (iOS coming soon)

## Screenshots

![Home Screen](assets/screenshots/home.png)
![Player Screen](assets/screenshots/player.png)
![Downloads Screen](assets/screenshots/downloads.png)

## Installation

### From Releases
1. Download the latest APK from [Releases](https://github.com/Sp00kyTec/LibreTune/releases)
2. Enable "Install from unknown sources" in your device settings
3. Install the APK file

### From Source
```bash
git clone https://github.com/Sp00kyTec/LibreTune.git
cd LibreTune/libretune_app
flutter pub get
flutter run

Usage 

    Browse Content - Explore trending content on the home screen
    Search - Find specific music, videos, or podcasts
    Play - Stream content with professional audio enhancement
    Download - Save content for offline access
    Customize - Adjust audio settings and app preferences
     

Documentation 

    User Guide 
    Developer Guide 
    API Reference 
     

Development 
Prerequisites 

    Flutter SDK 3.0 or higher
    Android Studio or VS Code
    Android SDK (for Android development)
     

Setup
flutter pub get
flutter run

Testing
flutter test
flutter test --coverage

Build Release
# Android
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release

Contributing 

We welcome contributions! Please see our Contributing Guidelines . 

    Fork the repository
    Create a feature branch
    Make your changes
    Add tests if applicable
    Submit a pull request
     

License 

This project is licensed under the MIT License - see the LICENSE  file for details. 
Support 

For issues, feature requests, or questions: 

    Open an issue 
    Check our documentation 
    Contact the maintainers
     

Acknowledgments 

    Thanks to all contributors
    Inspired by the need for better, free streaming alternatives
    Built with Flutter and ❤️
     

### 7. Changelog

**CHANGELOG.md**
```markdown
# Changelog

All notable changes to LibreTune will be documented in this file.

## [1.0.0] - [Release Date]

### Added
- **Core Functionality**
  - Multi-source content aggregation (YouTube, SoundCloud, Bandcamp)
  - True offline ownership with public storage access
  - Professional audio enhancement system with equalizer
  - Beautiful, futuristic UI/UX with animations
  - Complete download management system
  - Settings system with theme and audio controls

- **Features**
  - Search across multiple content sources
  - Trending content discovery
  - Audio visualization with real-time waveforms
  - Equalizer presets (Classical, Rock, Pop, Jazz, etc.)
  - Bass boost and virtualizer controls
  - Sorting and filtering for downloads
  - Light/Dark theme support
  - Cache management and performance optimizations

- **Technical**
  - Complete testing framework with unit and integration tests
  - Comprehensive documentation (user, developer, API)
  - Privacy-focused design with no data collection
  - Cross-app compatibility for downloaded files
  - Proper error handling and user feedback

### Changed
- Improved performance with caching and lazy loading
- Enhanced error handling throughout the application
- Better user experience with animations and transitions

### Fixed
- Various bug fixes and stability improvements
- Memory management optimizations
- Network error handling

## [0.1.0] - Initial Development

### Added
- Basic project structure
- Core data models
- Content source abstraction
- Download service foundation
- Basic UI components

8. Final Testing Checklist 

TESTING_CHECKLIST.md 
# LibreTune Testing Checklist

## Pre-Release Testing

### Core Functionality
- [ ] Content search across all sources
- [ ] Content playback with audio enhancement
- [ ] File downloads to public storage
- [ ] Downloaded file accessibility by other apps
- [ ] Equalizer functionality and presets
- [ ] Bass boost and virtualizer controls
- [ ] Audio visualization animations

### UI/UX
- [ ] Home screen loading and refresh
- [ ] Search functionality and source selection
- [ ] Player screen controls and animations
- [ ] Downloads screen sorting and management
- [ ] Settings screen configuration
- [ ] Theme switching (light/dark)
- [ ] Responsive design on different screen sizes

### Performance
- [ ] App startup time
- [ ] Memory usage during playback
- [ ] Network efficiency
- [ ] Cache management
- [ ] Battery optimization

### Security & Privacy
- [ ] No data collection
- [ ] Proper permission handling
- [ ] Secure storage of settings
- [ ] Network security (HTTPS)

### Device Compatibility
- [ ] Android 8.0+ devices
- [ ] Different screen sizes and densities
- [ ] Various network conditions
- [ ] Low storage scenarios

### Error Handling
- [ ] Network error scenarios
- [ ] File system errors
- [ ] Playback errors
- [ ] Download failures
- [ ] User feedback for all errors

## Release Testing

### Build Verification
- [ ] APK builds successfully
- [ ] App Bundle builds successfully
- [ ] All tests pass
- [ ] Code analysis clean
- [ ] Documentation up to date

### Installation
- [ ] Clean installation on fresh device
- [ ] Upgrade from previous version
- [ ] Permission requests work correctly
- [ ] App icon and splash screen display properly

### Post-Installation
- [ ] First launch experience
- [ ] Settings persistence
- [ ] Download directory creation
- [ ] Basic functionality verification

## Post-Release Monitoring

### User Feedback
- [ ] App store reviews monitoring
- [ ] GitHub issues tracking
- [ ] Crash report analysis
- [ ] Feature request collection

### Performance Monitoring
- [ ] Usage analytics (if implemented)
- [ ] Performance metrics
- [ ] Battery usage reports
- [ ] Memory consumption tracking