import 'package:flutter/material.dart';

/// Large overlay button that appears when the alarm is ringing.
/// Allows user to immediately silence the alarm.
class AlarmOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onStop;
  final String profileName;
  
  const AlarmOverlay({
    super.key,
    required this.isVisible,
    required this.onStop,
    required this.profileName,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Container(
      color: Colors.red.withAlpha(230),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                onEnd: () {},
                child: const Icon(
                  Icons.alarm,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Profile name
              Text(
                profileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'ALARM TRIGGERED',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Large STOP button
              GestureDetector(
                onTap: onStop,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'STOP',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Tap to silence',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
