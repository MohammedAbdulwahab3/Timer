import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/timer_service.dart';

/// Main application state provider.
/// Manages profiles, active profile, stopwatch state, and alarm playback.
class AppProvider with ChangeNotifier {
  List<Profile> _profiles = [];
  int _activeProfileId = 1;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isAlarmPlaying = false;
  bool _isInitialized = false;
  
  // Timer for fallback when foreground service isn't available
  Timer? _fallbackTimer;
  
  /// All profiles
  List<Profile> get profiles => _profiles;
  
  /// Currently active profile
  Profile get activeProfile {
    return _profiles.firstWhere(
      (p) => p.id == _activeProfileId,
      orElse: () => _profiles.first,
    );
  }
  
  /// Elapsed stopwatch time in seconds
  int get elapsedSeconds => _elapsedSeconds;
  
  /// Whether the stopwatch is running
  bool get isRunning => _isRunning;
  
  /// Whether an alarm is currently playing
  bool get isAlarmPlaying => _isAlarmPlaying;
  
  /// Whether initialization is complete
  bool get isInitialized => _isInitialized;
  
  /// Get a profile by ID
  Profile getProfileById(int id) {
    return _profiles.firstWhere(
      (p) => p.id == id,
      orElse: () => _profiles.first,
    );
  }
  
  /// Initialize the provider - load saved data
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize services
    await StorageService.init();
    await TimerService.instance.init();
    
    // Load saved profiles
    _profiles = StorageService.instance.loadProfiles();
    _activeProfileId = StorageService.instance.loadActiveProfileId();
    
    // Set up timer service callbacks
    TimerService.instance.onTick = _onTimerTick;
    TimerService.instance.onTrigger = _onTriggerTime;
    
    // Start foreground service
    await TimerService.instance.startService();
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Handler for timer tick events
  void _onTimerTick(int elapsed) {
    _elapsedSeconds = elapsed;
    notifyListeners();
    
    // Check if we've reached trigger time
    if (_isRunning && !_isAlarmPlaying && _elapsedSeconds == activeProfile.triggerTimeInSeconds) {
      _triggerAlarm();
    }
  }
  
  /// Handler for trigger time reached (from service)
  void _onTriggerTime() {
    if (!_isAlarmPlaying) {
      _triggerAlarm();
    }
  }
  
  /// Trigger the alarm
  void _triggerAlarm() async {
    _isAlarmPlaying = true;
    _isRunning = false;
    TimerService.instance.pauseTimer();
    
    // Play alarm sound
    await AudioService.instance.playAlarm(activeProfile);
    
    notifyListeners();
  }
  
  /// Set the active profile
  Future<void> setActiveProfile(int profileId) async {
    _activeProfileId = profileId;
    await StorageService.instance.saveActiveProfileId(profileId);
    
    // Update trigger time in timer service if not running
    if (!_isRunning) {
      TimerService.instance.setTriggerTime(activeProfile.triggerTimeInSeconds);
    }
    
    notifyListeners();
  }
  
  /// Update a profile's settings
  Future<void> updateProfile(Profile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _profiles[index] = profile;
      await StorageService.instance.saveProfiles(_profiles);
      
      // Update trigger time if this is the active profile
      if (profile.id == _activeProfileId && !_isRunning) {
        TimerService.instance.setTriggerTime(profile.triggerTimeInSeconds);
      }
      
      notifyListeners();
    }
  }
  
  /// Toggle start/pause
  void toggleStartPause() {
    if (_isAlarmPlaying) return;
    
    if (_isRunning) {
      // Pause
      _isRunning = false;
      TimerService.instance.pauseTimer();
      _fallbackTimer?.cancel();
    } else {
      // Start
      _isRunning = true;
      TimerService.instance.startTimer(activeProfile.triggerTimeInSeconds);
      
      // Start fallback timer for local display updates
      _startFallbackTimer();
    }
    
    notifyListeners();
  }
  
  /// Start a fallback timer for UI updates when foreground service messages are delayed
  void _startFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning && !_isAlarmPlaying) {
        _elapsedSeconds++;
        
        // Check trigger time
        if (_elapsedSeconds == activeProfile.triggerTimeInSeconds) {
          _triggerAlarm();
          timer.cancel();
        }
        
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }
  
  /// Reset the stopwatch
  void reset() {
    if (_isAlarmPlaying) return;
    
    _isRunning = false;
    _elapsedSeconds = 0;
    _fallbackTimer?.cancel();
    TimerService.instance.resetTimer();
    
    notifyListeners();
  }
  
  /// Stop the alarm
  void stopAlarm() {
    _isAlarmPlaying = false;
    AudioService.instance.stop();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _fallbackTimer?.cancel();
    AudioService.instance.dispose();
    TimerService.instance.stopService();
    super.dispose();
  }
}
