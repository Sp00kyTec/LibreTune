#!/bin/bash

echo "🚀 Setting up LibreTune development environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"

# Get Flutter version
flutter --version

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Run Flutter doctor
echo "🩺 Running Flutter doctor..."
flutter doctor

# Create necessary directories
echo "📁 Creating project structure..."
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/themes
mkdir -p lib/utils

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open the project in your IDE"
echo "2. Run 'flutter run' to start the app"
echo "3. Begin implementing features!"