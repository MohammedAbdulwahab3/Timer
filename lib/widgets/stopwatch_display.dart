import 'package:flutter/material.dart';

/// Displays the stopwatch time in MM:SS format
/// Large, centered digital display with customizable styling
class StopwatchDisplay extends StatelessWidget {
  final int elapsedSeconds;
  final bool isAlarmActive;
  
  const StopwatchDisplay({
    super.key,
    required this.elapsedSeconds,
    this.isAlarmActive = false,
  });
  
  /// Format seconds to MM:SS string
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        color: isAlarmActive 
            ? Colors.red.withAlpha(30) 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAlarmActive 
              ? Colors.red 
              : theme.colorScheme.outline.withAlpha(50),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlarmActive 
                ? Colors.red.withAlpha(40) 
                : Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        _formatTime(elapsedSeconds),
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.w300,
          fontFamily: 'monospace',
          letterSpacing: 4,
          color: isAlarmActive 
              ? Colors.red 
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
