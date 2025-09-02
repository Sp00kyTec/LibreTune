@echo off
echo 🚀 Setting up LibreTune development environment...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo ✅ Flutter is installed

REM Get Flutter version
flutter --version

REM Get dependencies
echo 📥 Getting dependencies...
flutter pub get

REM Run Flutter doctor
echo 🩺 Running Flutter doctor...
flutter doctor

REM Create necessary directories
echo 📁 Creating project structure...
mkdir lib\models 2>nul
mkdir lib\services 2>nul
mkdir lib\screens 2>nul
mkdir lib\widgets 2>nul
mkdir lib\themes 2>nul
mkdir lib\utils 2>nul

echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Open the project in your IDE
echo 2. Run 'flutter run' to start the app
echo 3. Begin implementing features!