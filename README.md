<<<<<<< HEAD
# Love Guru Flutter App - प्रेम गुरु मोबाइल ऐप

एक सुंदर Flutter मोबाइल ऐप जो प्रेम और रिश्तों के बारे में सलाह देता है। इसमें वॉइस रिकॉर्डिंग, इंडियन एक्सेंट TTS, और ऑफलाइन AI रिस्पॉन्स की सुविधा है।

## 🚀 Features

- **वॉइस रिकॉर्डिंग**: होल्ड-टू-रिकॉर्ड बटन
- **इंडियन एक्सेंट TTS**: हिंदी में प्राकृतिक आवाज़
- **ऑफलाइन AI**: इंटरनेट के बिना भी काम करता है
- **सुंदर UI**: आधुनिक और आकर्षक डिज़ाइन
- **हिंदी सपोर्ट**: पूर्ण हिंदी भाषा समर्थन

## 📱 Installation

### Prerequisites
1. Flutter SDK (3.0.0 या उससे ऊपर)
2. Android Studio या VS Code
3. Android device या emulator

### Steps

1. **Flutter SDK Install करें**:
   ```bash
   # Flutter SDK डाउनलोड करें: https://flutter.dev/docs/get-started/install
   # PATH में Flutter को add करें
   ```

2. **Dependencies Install करें**:
   ```bash
   cd flutter_love_guru_app
   flutter pub get
   ```

3. **Android Permissions**:
   - Microphone permission automatically handled
   - Internet permission for future updates

4. **Run the App**:
   ```bash
   # Android device/emulator connect करें
   flutter devices
   
   # App run करें
   flutter run
   ```

## 🎯 How to Use

1. **App खोलें** और welcome message देखें
2. **Voice Button दबाकर रखें** और अपना सवाल बोलें
3. **Text Input** में भी टाइप कर सकते हैं
4. **AI Response** हिंदी में मिलेगा और बोला भी जाएगा

## 🔧 Project Structure

```
flutter_love_guru_app/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── screens/
│   │   └── chat_screen.dart      # Main chat interface
│   ├── widgets/
│   │   ├── message_bubble.dart   # Chat message bubbles
│   │   └── voice_button.dart     # Voice recording button
│   ├── providers/
│   │   ├── chat_provider.dart    # Chat state management
│   │   └── voice_provider.dart   # Voice functionality
│   └── services/
│       └── ai_response_service.dart # Offline AI responses
├── android/                      # Android platform files
├── assets/                       # App resources
└── pubspec.yaml                  # Dependencies
```

## 📦 Dependencies

- `provider`: State management
- `speech_to_text`: Voice recognition
- `flutter_tts`: Text-to-speech
- `permission_handler`: Permissions
- `shared_preferences`: Local storage
- `intl`: Date/time formatting

## 🎨 Features Detail

### Voice Recording
- **Hold-to-record**: बटन दबाकर रखें
- **Visual feedback**: Recording के दौरान animation
- **Auto-stop**: बटन छोड़ने पर stop

### AI Responses
- **Love advice**: प्रेम की सलाह
- **Relationship tips**: रिश्तों की जानकारी
- **Marriage guidance**: शादी की सलाह
- **Compatibility**: जोड़ी की compatibility
- **Breakup support**: ब्रेकअप की सहायता

### Text-to-Speech
- **Indian accent**: भारतीय उच्चारण
- **Hindi support**: हिंदी भाषा
- **Natural voice**: प्राकृतिक आवाज़

## 🔧 Troubleshooting

### Common Issues:

1. **Flutter command not found**:
   ```bash
   # Flutter SDK को PATH में add करें
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

2. **Permission denied**:
   - Android settings में microphone permission enable करें

3. **Build errors**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 📱 Testing

### Manual Testing:
1. Voice recording functionality
2. Text input and send
3. AI response generation
4. Text-to-speech playback
5. UI responsiveness

### Device Testing:
- Android 6.0+ recommended
- Microphone required for voice features
- Speaker/headphones for TTS

## 🚀 Future Enhancements

- [ ] More AI response categories
- [ ] Voice customization options
- [ ] Chat history persistence
- [ ] Multiple language support
- [ ] Advanced NLP features

## 📄 License

This project is created for educational purposes.

## 🤝 Contributing

Feel free to contribute to this project by:
1. Reporting bugs
2. Suggesting features
3. Submitting pull requests

---

**Made with ❤️ for Love Guru - प्रेम गुरु**
=======
# loveguru
This is mobile app in which you find solution of your love problems...
>>>>>>> 155482bad0fdbf47b78c0c9855384f883393564d
