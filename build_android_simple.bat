@echo off
echo 🚀 Building Love Guru Android APK...
echo =====================================

REM Check if Flutter SDK exists
if not exist "C:\Users\HP-N15\flutter\flutter\bin\flutter.bat" (
    echo ❌ Flutter SDK not found at expected location
    echo Please install Flutter SDK or update the path in local.properties
    pause
    exit /b 1
)

REM Set Flutter path
set PATH=C:\Users\HP-N15\flutter\flutter\bin;%PATH%

echo ✅ Flutter SDK found
echo 📱 Starting Android build...

REM Clean previous builds
flutter clean

REM Get dependencies
flutter pub get

REM Build APK
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo ✅ APK built successfully!
    echo 📱 APK Location: build\app\outputs\flutter-apk\app-debug.apk
    
    REM Copy APK to root directory for easy access
    copy "build\app\outputs\flutter-apk\app-debug.apk" "love_guru_app.apk"
    
    echo 📋 Installation Instructions:
    echo 1. Transfer love_guru_app.apk to your Android device
    echo 2. Enable "Unknown Sources" in Settings ^> Security
    echo 3. Tap the APK file to install
    echo 4. Grant microphone permission when prompted
    
) else (
    echo ❌ Build failed! Check the error messages above.
)

pause