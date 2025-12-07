import 'package:flutter/material.dart';

/// Control buttons for the stopwatch: Start/Pause and Reset
class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final bool isAlarmActive;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  
  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.isAlarmActive,
    required this.onStartPause,
    required this.onReset,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button
        SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: isAlarmActive ? null : onReset,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurface,
              padding: EdgeInsets.zero,
              elevation: 2,
            ),
            child: const Icon(Icons.refresh, size: 32),
          ),
        ),
        
        const SizedBox(width: 32),
        
        // Start/Pause Button (larger)
        SizedBox(
          width: 100,
          height: 100,
          child: ElevatedButton(
            onPressed: isAlarmActive ? null : onStartPause,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: isRunning 
                  ? Colors.orange 
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              elevation: 4,
            ),
            child: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              size: 48,
            ),
          ),
        ),
        
        // Spacer for symmetry
        const SizedBox(width: 112),
      ],
    );
  }
}
