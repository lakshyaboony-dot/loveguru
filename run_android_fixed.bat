@echo off
echo Setting up environment for Flutter Android build...

REM Clear any existing JAVA_HOME references
set JAVA_HOME=
set FLUTTER_GRADLE_JAVA_HOME=
set GRADLE_OPTS=

REM Set JAVA_HOME with proper quoting
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "FLUTTER_GRADLE_JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo JAVA_HOME is set to: %JAVA_HOME%
echo FLUTTER_GRADLE_JAVA_HOME is set to: %FLUTTER_GRADLE_JAVA_HOME%

REM Verify Java installation
"%JAVA_HOME%\bin\java" -version

echo Running Flutter on Android device...
flutter run -d RZCTB17W8TE