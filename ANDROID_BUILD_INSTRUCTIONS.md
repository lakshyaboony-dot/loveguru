# 📱 Love Guru Android App - Build & Installation Guide

## 🔧 Prerequisites Setup

### Step 1: Enable Developer Mode (Required)
1. Windows Settings में जाएं (Windows key + I)
2. "For developers" या "Developer Mode" search करें
3. Developer Mode को **ON** करें
4. Computer को restart करें

### Step 2: Build APK

#### Option A: Automatic Build (Recommended)
```bash
# Run the build script
.\build_android_simple.bat
```

#### Option B: Manual Build
```bash
# Set Flutter path
set PATH=C:\Users\HP-N15\flutter\flutter\bin;%PATH%

# Clean and get dependencies
flutter clean
flutter pub get

# Build APK
flutter build apk --debug
```

## 📱 Android Installation Guide

### Step 1: Transfer APK to Phone
1. APK file location: `love_guru_app.apk` (root folder में)
2. APK को अपने Android phone में transfer करें:
   - USB cable से
   - WhatsApp/Telegram से send करें
   - Google Drive/Dropbox से download करें

### Step 2: Enable Unknown Sources
1. Android Settings → Security → Unknown Sources को enable करें
2. या Settings → Apps → Special Access → Install Unknown Apps

### Step 3: Install App
1. Phone में APK file को tap करें
2. "Install" button दबाएं
3. Installation complete होने का wait करें

### Step 4: Grant Permissions
App खोलने पर ये permissions grant करें:
- ✅ **Microphone** - Voice recording के लिए
- ✅ **Storage** - Audio files save करने के लिए
- ✅ **Internet** - AI responses के लिए (optional)

## 🎯 App Features

### 💬 Chat Interface
- Modern Material Design UI
- Hindi/English support
- Real-time messaging

### 🎤 Voice Recording
- High-quality audio recording
- Automatic speech recognition
- Voice-to-text conversion

### 🔊 Text-to-Speech
- Hindi TTS support
- Natural voice synthesis
- Adjustable speech rate

### 🤖 AI Love Guru
- Offline AI responses
- Relationship advice
- Cultural context awareness

## 🔧 Troubleshooting

### Build Issues
```bash
# If build fails, try:
flutter doctor
flutter clean
flutter pub get
flutter build apk --debug --verbose
```

### Installation Issues
1. **"App not installed"**: Enable Unknown Sources
2. **"Parse error"**: Re-download APK file
3. **"Insufficient storage"**: Free up phone memory
4. **Permissions denied**: Manually grant in Settings

### App Crashes
1. Grant all required permissions
2. Restart the app
3. Check Android version (minimum API 21)

## 📋 System Requirements

### Development Machine
- Windows 10/11
- Flutter SDK installed
- Android SDK
- Developer Mode enabled

### Android Device
- Android 5.0+ (API level 21+)
- 100MB free storage
- Microphone access
- Internet connection (optional)

## 🚀 Quick Start Commands

```bash
# Complete build process
flutter clean && flutter pub get && flutter build apk --debug

# Copy APK to desktop
copy "build\app\outputs\flutter-apk\app-debug.apk" "%USERPROFILE%\Desktop\love_guru_app.apk"

# Check Flutter setup
flutter doctor -v
```

## 📞 Support

अगर कोई problem आए तो:
1. Error message का screenshot लें
2. Flutter doctor output check करें
3. APK file को re-download करें

**Happy Coding! 💕**