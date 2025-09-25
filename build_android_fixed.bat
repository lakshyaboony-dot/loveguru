@echo off
echo 🚀 Building Love Guru Android APK (Fixed Version)...
echo =====================================================

REM Set correct JAVA_HOME for this session
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo ✅ JAVA_HOME set to: %JAVA_HOME%

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
echo 📱 Starting Android build with AndroidX support...

REM Clean previous builds
flutter clean

REM Get dependencies
flutter pub get

REM Build APK with debug mode or run app based on parameter
if "%1"=="run" (
    echo 🏃 Running Flutter app on connected device...
    flutter run
) else (
    flutter build apk --debug
)

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
    echo.
    echo 🎯 App Features:
    echo - Voice recording and Hindi TTS
    echo - Offline AI love guru responses
    echo - Modern Material Design UI
    
) else (
    echo ❌ Build failed! Check the error messages above.
    echo.
    echo 🔧 Common fixes:
    echo 1. Make sure Developer Mode is enabled in Windows
    echo 2. Check if Android SDK is properly installed
    echo 3. Verify JAVA_HOME path is correct
)

pause