import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/profile.dart';

/// Screen for editing a single profile's settings.
/// Allows changing: name, trigger time, sound selection, duration cycles,
/// and the "play until stopped" toggle.
class ProfileEditScreen extends StatefulWidget {
  final int profileId;
  
  const ProfileEditScreen({
    super.key,
    required this.profileId,
  });
  
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late int _triggerMinutes;
  late int _triggerSeconds;
  late int _soundIndex;
  late int _durationCycles;
  late bool _playUntilStopped;
  
  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().getProfileById(widget.profileId);
    
    _nameController = TextEditingController(text: profile.name);
    _triggerMinutes = profile.triggerMinutes;
    _triggerSeconds = profile.triggerSeconds;
    _soundIndex = profile.soundIndex;
    _durationCycles = profile.durationCycles;
    _playUntilStopped = profile.playUntilStopped;
    
    _nameController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _saveProfile() {
    final appProvider = context.read<AppProvider>();
    final originalProfile = appProvider.getProfileById(widget.profileId);
    
    final updatedProfile = originalProfile.copyWith(
      name: _nameController.text.trim().isEmpty 
          ? 'Profile ${widget.profileId}' 
          : _nameController.text.trim(),
      triggerMinutes: _triggerMinutes,
      triggerSeconds: _triggerSeconds,
      soundIndex: _soundIndex,
      durationCycles: _durationCycles,
      playUntilStopped: _playUntilStopped,
    );
    
    appProvider.updateProfile(updatedProfile);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Name
            _SectionTitle(title: 'Profile Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter profile name',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Trigger Time
            _SectionTitle(title: 'Trigger Time'),
            const SizedBox(height: 8),
            _TimePicker(
              minutes: _triggerMinutes,
              seconds: _triggerSeconds,
              onChanged: (minutes, seconds) {
                setState(() {
                  _triggerMinutes = minutes;
                  _triggerSeconds = seconds;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sound Selection
            _SectionTitle(title: 'Alarm Sound'),
            const SizedBox(height: 8),
            _SoundPicker(
              selectedIndex: _soundIndex,
              onChanged: (index) {
                setState(() {
                  _soundIndex = index;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Duration Settings
            _SectionTitle(title: 'Alarm Duration'),
            const SizedBox(height: 8),
            _DurationPicker(
              cycles: _durationCycles,
              playUntilStopped: _playUntilStopped,
              onCyclesChanged: (cycles) {
                setState(() {
                  _durationCycles = cycles;
                });
              },
              onPlayUntilStoppedChanged: (value) {
                setState(() {
                  _playUntilStopped = value;
                });
              },
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  final String title;
  
  const _SectionTitle({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Time picker for minutes and seconds
class _TimePicker extends StatelessWidget {
  final int minutes;
  final int seconds;
  final void Function(int minutes, int seconds) onChanged;
  
  const _TimePicker({
    required this.minutes,
    required this.seconds,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minutes
          _NumberSpinner(
            value: minutes,
            min: 0,
            max: 99,
            label: 'Min',
            onChanged: (value) => onChanged(value, seconds),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              ':',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Seconds
          _NumberSpinner(
            value: seconds,
            min: 0,
            max: 59,
            label: 'Sec',
            onChanged: (value) => onChanged(minutes, value),
          ),
        ],
      ),
    );
  }
}

/// Number spinner with increment/decrement buttons
class _NumberSpinner extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;
  
  const _NumberSpinner({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Increment
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.keyboard_arrow_up, size: 32),
          color: theme.colorScheme.primary,
        ),
        
        // Value display
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        
        // Decrement
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          color: theme.colorScheme.primary,
        ),
        
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Sound selection dropdown
class _SoundPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  
  const _SoundPicker({
    required this.selectedIndex,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: selectedIndex,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: List.generate(8, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(Profile.soundNames[index]),
              ],
            ),
          );
        }),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

/// Duration picker with cycle input and "play until stopped" toggle
class _DurationPicker extends StatelessWidget {
  final int cycles;
  final bool playUntilStopped;
  final ValueChanged<int> onCyclesChanged;
  final ValueChanged<bool> onPlayUntilStoppedChanged;
  
  const _DurationPicker({
    required this.cycles,
    required this.playUntilStopped,
    required this.onCyclesChanged,
    required this.onPlayUntilStoppedChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationSeconds = cycles * 30;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Play until stopped toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Play Until Stopped'),
              Switch(
                value: playUntilStopped,
                onChanged: onPlayUntilStoppedChanged,
              ),
            ],
          ),
          
          // Divider
          if (!playUntilStopped) ...[
            const Divider(height: 24),
            
            // Cycle input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cycles (30 seconds each)'),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${durationSeconds}s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                // Cycle spinner
                Row(
                  children: [
                    IconButton(
                      onPressed: cycles > 1 
                          ? () => onCyclesChanged(cycles - 1) 
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: theme.colorScheme.primary,
                    ),
                    Container(
                      width: 48,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cycles.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: cycles < 99 
                          ? () => onCyclesChanged(cycles + 1) 
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
