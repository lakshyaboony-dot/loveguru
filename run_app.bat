@echo off
echo Setting up environment for Flutter Love Guru App...

REM Clear any existing JAVA_HOME references
set JAVA_HOME=
set FLUTTER_GRADLE_JAVA_HOME=
set GRADLE_OPTS=

REM Set correct JAVA_HOME
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "FLUTTER_GRADLE_JAVA_HOME=%JAVA_HOME%"
set "GRADLE_OPTS=-Dorg.gradle.java.home=%JAVA_HOME%"

echo JAVA_HOME set to: %JAVA_HOME%

REM Verify Java installation
"%JAVA_HOME%\bin\java" -version
if %ERRORLEVEL% neq 0 (
    echo ERROR: Java installation not found at %JAVA_HOME%
    pause
    exit /b 1
)

echo Running Flutter Love Guru App...
flutter run --verbose

pause