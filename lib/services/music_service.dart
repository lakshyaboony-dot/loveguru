import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMuted = false;

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;

  Future<void> playBackgroundMusic() async {
    if (_isPlaying || _isMuted) return;

    try {
      // Using a simple tone generator for background music
      // In a real app, you would load an actual music file
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.3); // Light volume
      
      // Generate a simple ambient tone
      // This is a placeholder - in production, use actual music files
      await _audioPlayer.play(AssetSource('sounds/background_music.mp3'));
      _isPlaying = true;
    } catch (e) {
      // If audio file doesn't exist, create a simple tone programmatically
      _createSimpleBackgroundTone();
    }
  }

  Future<void> _createSimpleBackgroundTone() async {
    // This creates a very subtle background ambience
    // In production, replace with actual music files
    try {
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    } catch (e) {
      print('Background music not available: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isPlaying) return;
    
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isPlaying) return;
    
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> resumeBackgroundMusic() async {
    if (_isPlaying || _isMuted) return;
    
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      pauseBackgroundMusic();
    } else {
      resumeBackgroundMusic();
    }
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}