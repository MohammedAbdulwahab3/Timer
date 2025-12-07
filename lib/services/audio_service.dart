import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/profile.dart';

/// Service for managing audio playback.
/// Handles playing alarm sounds with loop support and cycle-based duration.
class AudioService {
  static AudioService? _instance;
  final AudioPlayer _player = AudioPlayer();
  
  Timer? _stopTimer;
  bool _isPlaying = false;
  bool _playUntilStopped = false;
  
  AudioService._() {
    // Configure audio player for looping
    _player.setReleaseMode(ReleaseMode.loop);
  }
  
  /// Get singleton instance
  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }
  
  /// Whether audio is currently playing
  bool get isPlaying => _isPlaying;
  
  /// Play the alarm for the given profile
  /// Returns immediately, audio plays in background
  Future<void> playAlarm(Profile profile) async {
    // Stop any currently playing audio
    await stop();
    
    _playUntilStopped = profile.playUntilStopped;
    _isPlaying = true;
    
    try {
      // Play the sound from assets
      await _player.play(AssetSource(profile.soundAssetPath.replaceFirst('assets/', '')));
      
      // If not play until stopped, set a timer to stop after duration
      if (!_playUntilStopped) {
        final durationSeconds = profile.durationInSeconds;
        _stopTimer = Timer(Duration(seconds: durationSeconds), () {
          stop();
        });
      }
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }
  
  /// Stop the currently playing alarm
  Future<void> stop() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    _isPlaying = false;
    _playUntilStopped = false;
    
    try {
      await _player.stop();
    } catch (e) {
      // Ignore errors when stopping
    }
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
    _instance = null;
  }
  
  /// Preload sounds for faster playback (optional optimization)
  Future<void> preloadSounds() async {
    // AudioPlayers handles caching automatically
  }
}
