import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/profile.dart';
import 'profile_edit_screen.dart';

/// Settings screen displaying a list of all 8 profiles.
/// Allows selecting the active profile and editing profile settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appProvider.profiles.length,
            itemBuilder: (context, index) {
              final profile = appProvider.profiles[index];
              final isActive = profile.id == appProvider.activeProfile.id;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProfileCard(
                  profile: profile,
                  isActive: isActive,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(profileId: profile.id),
                      ),
                    );
                  },
                  onActivate: () {
                    appProvider.setActiveProfile(profile.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Card displaying a single profile with its settings
class _ProfileCard extends StatelessWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  
  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onActivate,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive 
          ? theme.colorScheme.primaryContainer 
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive 
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Active indicator / Radio button
              GestureDetector(
                onTap: onActivate,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                    color: isActive 
                        ? theme.colorScheme.primary 
                        : Colors.transparent,
                  ),
                  child: isActive 
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Profile info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive 
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          size: 14,
                          color: isActive 
                              ? theme.colorScheme.onPrimaryContainer.withAlpha(179)
                              : theme.colorScheme.onSurface.withAlpha(179),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.triggerTimeDisplay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isActive 
                                ? theme.colorScheme.onPrimaryContainer.withAlpha(179)
                                : theme.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.music_note,
                          size: 14,
                          color: isActive 
                              ? theme.colorScheme.onPrimaryContainer.withAlpha(179)
                              : theme.colorScheme.onSurface.withAlpha(179),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.soundDisplayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isActive 
                                ? theme.colorScheme.onPrimaryContainer.withAlpha(179)
                                : theme.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Edit arrow
              Icon(
                Icons.chevron_right,
                color: isActive 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withAlpha(128),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
