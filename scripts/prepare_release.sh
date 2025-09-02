#!/bin/bash

echo "🚀 Preparing LibreTune Release..."

# Get version from pubspec.yaml
VERSION=$(grep "version:" libretune_app/pubspec.yaml | cut -d' ' -f2)
echo "📦 Version: $VERSION"

# Create release directory
RELEASE_DIR="releases/v$VERSION"
mkdir -p "$RELEASE_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
cd libretune_app
flutter clean
flutter pub get

# Run all tests
echo "🧪 Running all tests..."
flutter test --coverage

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Aborting release."
    exit 1
fi

# Build APK
echo "📱 Building APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    cp build/app/outputs/flutter-apk/app-release.apk "../$RELEASE_DIR/libretune-$VERSION.apk"
else
    echo "❌ APK build failed!"
    exit 1
fi

# Build App Bundle
echo "📦 Building App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ App Bundle built successfully!"
    cp build/app/outputs/bundle/release/app-release.aab "../$RELEASE_DIR/libretune-$VERSION.aab"
else
    echo "❌ App Bundle build failed!"
    exit 1
fi

# Generate documentation
echo "📚 Generating documentation..."
cd ..
mkdir -p "$RELEASE_DIR/docs"

# Copy documentation files
cp -r libretune_app/docs/* "$RELEASE_DIR/docs/"
cp libretune_app/README.md "$RELEASE_DIR/"
cp libretune_app/LICENSE "$RELEASE_DIR/"
cp PRIVACY_POLICY.md "$RELEASE_DIR/"
cp CHANGELOG.md "$RELEASE_DIR/"

# Create release notes
cat > "$RELEASE_DIR/RELEASE_NOTES.md" << EOF
# LibreTune v$VERSION Release

## What's New
This is the initial release of LibreTune!

### Features
- Multi-source content aggregation (YouTube, SoundCloud, Bandcamp)
- True offline ownership with public storage access
- Professional audio enhancement with equalizer
- Beautiful, futuristic UI/UX
- Complete download management system
- Settings system with theme and audio controls

### Technical Highlights
- Built with Flutter for cross-platform compatibility
- Open-source and privacy-focused design
- Comprehensive testing framework
- Performance optimized with caching

## Installation
1. Download the APK file
2. Enable "Install from unknown sources" in your device settings
3. Install the APK file
4. Grant necessary permissions when prompted

## System Requirements
- Android 8.0 (API level 26) or higher
- Minimum 100MB free storage space
- Internet connection for streaming

## File Information
- APK Size: $(du -h "$RELEASE_DIR/libretune-$VERSION.apk" | cut -f1)
- App Bundle Size: $(du -h "$RELEASE_DIR/libretune-$VERSION.aab" | cut -f1)

## Support
For issues, feature requests, or questions:
- Visit our GitHub repository
- Open an issue for bug reports
- Check our documentation

## License
This release is licensed under the MIT License.
See LICENSE file for details.
EOF

# Create checksums
echo "🔍 Creating checksums..."
cd "$RELEASE_DIR"
sha256sum "libretune-$VERSION.apk" > "libretune-$VERSION.apk.sha256"
sha256sum "libretune-$VERSION.aab" > "libretune-$VERSION.aab.sha256"

echo "🎉 Release preparation complete!"
echo "📁 Release files are in: $RELEASE_DIR"
echo ""
echo "Files created:"
echo "  - libretune-$VERSION.apk (Android app)"
echo "  - libretune-$VERSION.aab (App Bundle for Play Store)"
echo "  - libretune-$VERSION.apk.sha256 (APK checksum)"
echo "  - libretune-$VERSION.aab.sha256 (Bundle checksum)"
echo "  - RELEASE_NOTES.md"
echo "  - README.md"
echo "  - LICENSE"
echo "  - Privacy Policy"
echo "  - Changelog"
echo "  - Documentation"