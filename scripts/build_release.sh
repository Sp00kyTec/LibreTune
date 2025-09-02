#!/bin/bash

echo "🚀 Building LibreTune Release..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Aborting build."
    exit 1
fi

# Build APK
echo "📱 Building APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "📁 APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ APK build failed!"
    exit 1
fi

# Build App Bundle (for Play Store)
echo "📦 Building App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ App Bundle built successfully!"
    echo "📁 Bundle location: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ App Bundle build failed!"
    exit 1
fi

echo "🎉 Release build complete!"