import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stopwatch_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/alarm_overlay.dart';
import 'settings_screen.dart';

/// Main screen of the app displaying the stopwatch and controls.
/// Shows the active profile name, stopwatch display, and control buttons.
/// Displays alarm overlay when alarm is triggered.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final activeProfile = appProvider.activeProfile;
        
        return Scaffold(
          body: Stack(
            children: [
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Header with profile name and settings
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Profile',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withAlpha(179),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeProfile.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Settings button
                          IconButton(
                            icon: const Icon(Icons.settings),
                            iconSize: 28,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Trigger time indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 20,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alarm at ${activeProfile.triggerTimeDisplay}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Stopwatch display centered
                    Expanded(
                      child: Center(
                        child: StopwatchDisplay(
                          elapsedSeconds: appProvider.elapsedSeconds,
                          isAlarmActive: appProvider.isAlarmPlaying,
                        ),
                      ),
                    ),
                    
                    // Control buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: ControlButtons(
                        isRunning: appProvider.isRunning,
                        isAlarmActive: appProvider.isAlarmPlaying,
                        onStartPause: appProvider.toggleStartPause,
                        onReset: appProvider.reset,
                      ),
                    ),
                    
                    // Sound and duration info
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoChip(
                            icon: Icons.music_note,
                            label: activeProfile.soundDisplayName,
                          ),
                          _InfoChip(
                            icon: Icons.timer,
                            label: activeProfile.playUntilStopped
                                ? 'Until stopped'
                                : '${activeProfile.durationInSeconds}s',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Alarm overlay (shown when alarm is playing)
              AlarmOverlay(
                isVisible: appProvider.isAlarmPlaying,
                onStop: appProvider.stopAlarm,
                profileName: activeProfile.name,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Small info chip displaying sound or duration info
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  
  const _InfoChip({
    required this.icon,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withAlpha(179),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }
}
