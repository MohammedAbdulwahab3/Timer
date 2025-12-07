import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Foreground task handler for the stopwatch.
/// This runs in a separate isolate and keeps the timer running
/// even when the app is in background or screen is locked.
@pragma('vm:entry-point')
class StopwatchTaskHandler extends TaskHandler {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _triggerTime = 0;
  
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Task started
  }
  
  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called every second when the task is running
    if (_isRunning) {
      _elapsedSeconds++;
      
      // Send elapsed time to main isolate
      FlutterForegroundTask.sendDataToMain({
        'type': 'tick',
        'elapsed': _elapsedSeconds,
        'triggered': _elapsedSeconds == _triggerTime,
      });
      
      // Update notification
      FlutterForegroundTask.updateService(
        notificationTitle: 'Routine Stopwatch',
        notificationText: _formatTime(_elapsedSeconds),
      );
    }
  }
  
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _timer?.cancel();
  }
  
  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final command = data['command'] as String?;
      
      switch (command) {
        case 'start':
          _isRunning = true;
          _triggerTime = data['triggerTime'] as int? ?? 0;
          break;
        case 'pause':
          _isRunning = false;
          break;
        case 'reset':
          _isRunning = false;
          _elapsedSeconds = 0;
          FlutterForegroundTask.sendDataToMain({'type': 'tick', 'elapsed': 0, 'triggered': false});
          FlutterForegroundTask.updateService(
            notificationTitle: 'Routine Stopwatch',
            notificationText: '00:00',
          );
          break;
        case 'setTrigger':
          _triggerTime = data['triggerTime'] as int? ?? 0;
          break;
        case 'setElapsed':
          _elapsedSeconds = data['elapsed'] as int? ?? 0;
          break;
      }
    }
  }
  
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Service for managing the foreground timer service.
/// Provides methods to start/stop the service and control the timer.
class TimerService {
  static TimerService? _instance;

  
  // Callbacks for timer events
  void Function(int elapsed)? onTick;
  void Function()? onTrigger;
  
  TimerService._();
  
  static TimerService get instance {
    _instance ??= TimerService._();
    return _instance!;
  }
  
  /// Initialize the foreground task
  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'routine_stopwatch_channel',
        channelName: 'Routine Stopwatch',
        channelDescription: 'Timer running in background',
        // Use HIGH importance so notification stays visible
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
        enableVibration: false,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // Every 1 second
        // Enable auto-restart on boot
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    
    // Request to ignore battery optimizations for better background execution
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }
  
  /// Start the foreground service
  Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }
    
    // Set up listener for data from task
    FlutterForegroundTask.addTaskDataCallback(_handleMessage);
    
    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Routine Stopwatch',
      notificationText: '00:00',
      callback: startCallback,
    );
    
    return result is ServiceRequestSuccess;
  }
  
  /// Stop the foreground service
  Future<ServiceRequestResult> stopService() async {
    FlutterForegroundTask.removeTaskDataCallback(_handleMessage);
    return FlutterForegroundTask.stopService();
  }
  
  /// Handle messages from the foreground task
  void _handleMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final type = data['type'] as String?;
      
      if (type == 'tick') {
        final elapsed = data['elapsed'] as int? ?? 0;
        final triggered = data['triggered'] as bool? ?? false;
        
        onTick?.call(elapsed);
        
        if (triggered) {
          onTrigger?.call();
        }
      }
    }
  }
  
  /// Send a command to the foreground task
  void sendCommand(Map<String, dynamic> data) {
    FlutterForegroundTask.sendDataToTask(data);
  }
  
  /// Start the timer
  void startTimer(int triggerTimeSeconds) {
    sendCommand({
      'command': 'start',
      'triggerTime': triggerTimeSeconds,
    });
  }
  
  /// Pause the timer
  void pauseTimer() {
    sendCommand({'command': 'pause'});
  }
  
  /// Reset the timer
  void resetTimer() {
    sendCommand({'command': 'reset'});
  }
  
  /// Update the trigger time
  void setTriggerTime(int seconds) {
    sendCommand({
      'command': 'setTrigger',
      'triggerTime': seconds,
    });
  }
  
  /// Set elapsed time (for resuming)
  void setElapsed(int seconds) {
    sendCommand({
      'command': 'setElapsed',
      'elapsed': seconds,
    });
  }
}

/// Entry point for the foreground task isolate
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}
