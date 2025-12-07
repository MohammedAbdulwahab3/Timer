/// Profile model representing a single timing routine configuration.
/// Each profile contains:
/// - name: Custom name for the profile (e.g., "Cardio A")
/// - triggerMinutes/triggerSeconds: When the alarm should trigger
/// - soundIndex: Which of the 8 sounds to play (1-8)
/// - durationCycles: How many 30-second cycles the alarm plays
/// - playUntilStopped: If true, alarm loops indefinitely
class Profile {
  final int id;
  String name;
  int triggerMinutes;
  int triggerSeconds;
  int soundIndex;
  int durationCycles;
  bool playUntilStopped;

  Profile({
    required this.id,
    required this.name,
    this.triggerMinutes = 4,
    this.triggerSeconds = 20,
    this.soundIndex = 1,
    this.durationCycles = 1,
    this.playUntilStopped = false,
  });

  /// Get trigger time in total seconds for comparison with stopwatch
  int get triggerTimeInSeconds => (triggerMinutes * 60) + triggerSeconds;

  /// Get duration in seconds (each cycle = 30 seconds)
  int get durationInSeconds => durationCycles * 30;

  /// Get display string for trigger time (MM:SS format)
  String get triggerTimeDisplay {
    return '${triggerMinutes.toString().padLeft(2, '0')}:${triggerSeconds.toString().padLeft(2, '0')}';
  }

  /// Available sound options with display names
  static const List<String> soundNames = [
    'Deep Beep',
    'Buzzer',
    'Bell',
    'Chime',
    'Alert',
    'Tone',
    'Signal',
    'Alarm',
  ];

  /// Get the asset path for this profile's sound
  String get soundAssetPath {
    final soundFiles = [
      'assets/sounds/sound_1_deep_beep.wav',
      'assets/sounds/sound_2_buzzer.wav',
      'assets/sounds/sound_3_bell.wav',
      'assets/sounds/sound_4_chime.wav',
      'assets/sounds/sound_5_alert.wav',
      'assets/sounds/sound_6_tone.wav',
      'assets/sounds/sound_7_signal.wav',
      'assets/sounds/sound_8_alarm.wav',
    ];
    return soundFiles[soundIndex - 1];
  }

  /// Get the display name for this profile's sound
  String get soundDisplayName => soundNames[soundIndex - 1];

  /// Create a default profile with a given ID
  factory Profile.defaultProfile(int id) {
    return Profile(
      id: id,
      name: 'Profile $id',
      triggerMinutes: 4,
      triggerSeconds: 20,
      soundIndex: 1,
      durationCycles: 1,
      playUntilStopped: false,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggerMinutes': triggerMinutes,
      'triggerSeconds': triggerSeconds,
      'soundIndex': soundIndex,
      'durationCycles': durationCycles,
      'playUntilStopped': playUntilStopped,
    };
  }

  /// Create from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      triggerMinutes: json['triggerMinutes'] as int,
      triggerSeconds: json['triggerSeconds'] as int,
      soundIndex: json['soundIndex'] as int,
      durationCycles: json['durationCycles'] as int,
      playUntilStopped: json['playUntilStopped'] as bool,
    );
  }

  /// Create a copy with optional new values
  Profile copyWith({
    String? name,
    int? triggerMinutes,
    int? triggerSeconds,
    int? soundIndex,
    int? durationCycles,
    bool? playUntilStopped,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      triggerMinutes: triggerMinutes ?? this.triggerMinutes,
      triggerSeconds: triggerSeconds ?? this.triggerSeconds,
      soundIndex: soundIndex ?? this.soundIndex,
      durationCycles: durationCycles ?? this.durationCycles,
      playUntilStopped: playUntilStopped ?? this.playUntilStopped,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, trigger: $triggerTimeDisplay, sound: $soundDisplayName)';
  }
}
