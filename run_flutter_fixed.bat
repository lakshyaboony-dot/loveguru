@echo off
echo 🚀 Running Flutter Love Guru App with Fixed Java Configuration...
echo ================================================================

REM Set correct JAVA_HOME and PATH for this session
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "PATH=%JAVA_HOME%\bin;C:\Users\HP-N15\flutter\flutter\bin;%PATH%"

REM Clear any conflicting environment variables
set "FLUTTER_GRADLE_JAVA_HOME=%JAVA_HOME%"
set "GRADLE_OPTS=-Dorg.gradle.java.home=%JAVA_HOME%"

echo ✅ JAVA_HOME set to: %JAVA_HOME%
echo ✅ Flutter SDK path: C:\Users\HP-N15\flutter\flutter\bin
echo ✅ Gradle Java home: %JAVA_HOME%

REM Verify Java installation
echo 🔍 Verifying Java installation...
"%JAVA_HOME%\bin\java" -version
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Java verification failed
    pause
    exit /b 1
)

REM Clean and run
echo 🧹 Cleaning project...
flutter clean

echo 📱 Getting dependencies...
flutter pub get

echo 🏃 Running Flutter app on connected Android device...
flutter run --verbose

pause