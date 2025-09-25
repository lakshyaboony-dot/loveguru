#!/usr/bin/env python3
"""
Android APK Builder for Flutter Love Guru App
This script helps build the Android APK without requiring Flutter SDK installation
"""

import os
import sys
import subprocess
import shutil
import json
from pathlib import Path

class AndroidAPKBuilder:
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.android_dir = self.project_root / "android"
        self.build_dir = self.project_root / "build"
        
    def check_requirements(self):
        """Check if required tools are available"""
        print("🔍 Checking requirements...")
        
        # Check for Java
        try:
            result = subprocess.run(['java', '-version'], capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ Java found")
            else:
                print("❌ Java not found. Please install Java JDK 8 or higher")
                return False
        except FileNotFoundError:
            print("❌ Java not found. Please install Java JDK 8 or higher")
            return False
            
        # Check for Android SDK
        android_home = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
        if not android_home:
            print("❌ Android SDK not found. Please set ANDROID_HOME environment variable")
            print("   Download Android SDK from: https://developer.android.com/studio")
            return False
        else:
            print(f"✅ Android SDK found at: {android_home}")
            
        return True
    
    def setup_gradle_wrapper(self):
        """Setup Gradle wrapper if not present"""
        print("🔧 Setting up Gradle wrapper...")
        
        gradle_wrapper = self.android_dir / "gradlew"
        if not gradle_wrapper.exists():
            print("Creating Gradle wrapper...")
            # Create basic gradle wrapper
            os.chdir(self.android_dir)
            try:
                subprocess.run(['gradle', 'wrapper'], check=True)
                print("✅ Gradle wrapper created")
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("❌ Failed to create Gradle wrapper. Please install Gradle manually")
                return False
        else:
            print("✅ Gradle wrapper already exists")
            
        return True
    
    def create_flutter_stub(self):
        """Create minimal Flutter stub files for building"""
        print("📱 Creating Flutter stub files...")
        
        # Create lib directory with main.dart if not exists
        lib_dir = self.project_root / "lib"
        lib_dir.mkdir(exist_ok=True)
        
        # Create assets directory
        assets_dir = self.project_root / "assets"
        assets_dir.mkdir(exist_ok=True)
        
        # Create build directory structure
        build_flutter_assets = self.build_dir / "flutter_assets"
        build_flutter_assets.mkdir(parents=True, exist_ok=True)
        
        print("✅ Flutter stub files created")
        return True
    
    def build_apk(self):
        """Build the Android APK"""
        print("🏗️ Building Android APK...")
        
        os.chdir(self.android_dir)
        
        # Make gradlew executable on Unix systems
        if os.name != 'nt':
            os.chmod('gradlew', 0o755)
        
        # Build APK
        gradle_cmd = ['./gradlew.bat' if os.name == 'nt' else './gradlew', 'assembleDebug']
        
        try:
            print("Running: " + " ".join(gradle_cmd))
            result = subprocess.run(gradle_cmd, check=True, capture_output=True, text=True)
            print("✅ APK built successfully!")
            
            # Find the generated APK
            apk_path = self.android_dir / "app" / "build" / "outputs" / "apk" / "debug" / "app-debug.apk"
            if apk_path.exists():
                # Copy APK to project root for easy access
                output_apk = self.project_root / "love_guru_app.apk"
                shutil.copy2(apk_path, output_apk)
                print(f"📱 APK copied to: {output_apk}")
                return str(output_apk)
            else:
                print("❌ APK file not found after build")
                return None
                
        except subprocess.CalledProcessError as e:
            print(f"❌ Build failed: {e}")
            print("Build output:", e.stdout)
            print("Build errors:", e.stderr)
            return None
    
    def create_installation_guide(self, apk_path):
        """Create installation guide for the APK"""
        guide_content = f"""
# Love Guru Android App - Installation Guide

## APK File Location
📱 **APK File**: `{apk_path}`

## Installation Steps

### Method 1: Direct Installation
1. Transfer the APK file to your Android device
2. Enable "Unknown Sources" in Settings > Security
3. Tap the APK file to install
4. Grant necessary permissions when prompted

### Method 2: ADB Installation (Developer Mode)
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device to computer
4. Run: `adb install {apk_path}`

## Required Permissions
The app requires the following permissions:
- 🎤 **Microphone**: For voice recording
- 🌐 **Internet**: For online features (optional)
- 💾 **Storage**: For saving audio files

## Features
- ❤️ Love advice and relationship guidance
- 🎙️ Voice recording and playback
- 🗣️ Hindi text-to-speech
- 📱 Offline functionality
- 🎨 Beautiful Material Design UI

## Troubleshooting
- If installation fails, ensure "Unknown Sources" is enabled
- For older Android versions, check "Install from Unknown Sources"
- Make sure you have enough storage space (minimum 50MB)

## Support
For issues or questions, contact the development team.

---
Built with ❤️ using Flutter
"""
        
        guide_path = self.project_root / "ANDROID_INSTALLATION_GUIDE.md"
        with open(guide_path, 'w', encoding='utf-8') as f:
            f.write(guide_content)
        
        print(f"📖 Installation guide created: {guide_path}")
    
    def run(self):
        """Main build process"""
        print("🚀 Starting Android APK build process...")
        print("=" * 50)
        
        if not self.check_requirements():
            print("\n❌ Requirements check failed. Please install missing dependencies.")
            return False
        
        if not self.setup_gradle_wrapper():
            print("\n❌ Gradle setup failed.")
            return False
        
        if not self.create_flutter_stub():
            print("\n❌ Flutter stub creation failed.")
            return False
        
        apk_path = self.build_apk()
        if not apk_path:
            print("\n❌ APK build failed.")
            return False
        
        self.create_installation_guide(apk_path)
        
        print("\n" + "=" * 50)
        print("🎉 Android APK build completed successfully!")
        print(f"📱 APK Location: {apk_path}")
        print("📖 Check ANDROID_INSTALLATION_GUIDE.md for installation instructions")
        
        return True

if __name__ == "__main__":
    builder = AndroidAPKBuilder()
    success = builder.run()
    sys.exit(0 if success else 1)