import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/ai_response_service.dart';

class VoiceProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  bool _speechEnabled = false;
  bool _ttsEnabled = true;

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get recognizedText => _recognizedText;
  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;

  VoiceProvider() {
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied');
        return;
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      
      print('Speech recognition initialized: $_speechEnabled');
      notifyListeners();
    } catch (e) {
      print('Error initializing speech: $e');
      _speechEnabled = false;
      notifyListeners();
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('hi-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        _isSpeaking = false;
        notifyListeners();
      });

      print('TTS initialized successfully');
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      print('Speech recognition not enabled');
      return;
    }

    if (_isListening) {
      print('Already listening');
      return;
    }

    try {
      _recognizedText = '';
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          print('Recognized: $_recognizedText');
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'hi-IN',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  String _detectLanguage(String text) {
    final hindiPattern = RegExp(r'[\u0900-\u097F]');
    final englishPattern = RegExp(r'[a-zA-Z]');
    
    int hindiChars = hindiPattern.allMatches(text).length;
    int englishChars = englishPattern.allMatches(text).length;
    
    if (hindiChars > englishChars) {
      return 'hi-IN';
    } else {
      return 'en-US';
    }
  }

  Future<void> _setLanguageForTts(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      
      if (language == 'hi-IN') {
        await _flutterTts.setSpeechRate(0.4);
      } else {
        await _flutterTts.setSpeechRate(0.5);
      }
    } catch (e) {
      print('Error setting TTS language: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_ttsEnabled || text.isEmpty) return;

    try {
      await _flutterTts.stop();
      
      String detectedLanguage = _detectLanguage(text);
      print('Detected language: $detectedLanguage for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      
      await _setLanguageForTts(detectedLanguage);
      
      _isSpeaking = true;
      notifyListeners();
      
      await _flutterTts.speak(text);
      
    } catch (e) {
      print('Error in TTS: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// 🔥 FIXED: Ab yaha `_recognizedText` use ho raha hai
  Future<void> processVoiceInput() async {
    if (_recognizedText.isNotEmpty) {
      try {
        final result = await AIResponseService.generateResponse(_recognizedText);
        await speak(result);
        
        _recognizedText = '';
        notifyListeners();
      } catch (e) {
        print('Error processing voice input: $e');
      }
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    
    _isListening = false;
    notifyListeners();
    await _speechToText.stop();
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void toggleTts() {
    _ttsEnabled = !_ttsEnabled;
    notifyListeners();
  }

  Future<String> getVoiceResponse(String input) async {
    try {
      return AIResponseService.generateResponse(input);
    } catch (e) {
      print('Error getting AI response: $e');
      return 'माफ करें, मुझे आपका सवाल समझने में दिक्कत हो रही है। कृपया दोबारा कोशिश करें।';
    }
  }

  Future<void> speakMultilingual(String text) async {
    await speak(text);
  }
}
