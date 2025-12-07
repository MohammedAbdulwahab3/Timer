import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

/// Service for persisting profile data using SharedPreferences.
/// Handles saving and loading of all 8 profiles and the active profile index.
class StorageService {
  static const String _profilesKey = 'profiles';
  static const String _activeProfileKey = 'active_profile_id';
  
  static StorageService? _instance;
  late SharedPreferences _prefs;
  
  StorageService._();
  
  /// Get singleton instance (must call init first)
  static StorageService get instance {
    if (_instance == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _instance!;
  }
  
  /// Initialize the storage service
  static Future<StorageService> init() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  /// Load all profiles from storage (returns 8 default profiles if none saved)
  List<Profile> loadProfiles() {
    final String? profilesJson = _prefs.getString(_profilesKey);
    
    if (profilesJson == null) {
      // Return 8 default profiles
      return List.generate(8, (index) => Profile.defaultProfile(index + 1));
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(profilesJson) as List<dynamic>;
      return jsonList
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return default profiles on parse error
      return List.generate(8, (index) => Profile.defaultProfile(index + 1));
    }
  }
  
  /// Save all profiles to storage
  Future<bool> saveProfiles(List<Profile> profiles) async {
    final String profilesJson = jsonEncode(
      profiles.map((p) => p.toJson()).toList(),
    );
    return _prefs.setString(_profilesKey, profilesJson);
  }
  
  /// Load the active profile ID (1-based, returns 1 if not set)
  int loadActiveProfileId() {
    return _prefs.getInt(_activeProfileKey) ?? 1;
  }
  
  /// Save the active profile ID
  Future<bool> saveActiveProfileId(int profileId) async {
    return _prefs.setInt(_activeProfileKey, profileId);
  }
  
  /// Save a single profile (updates the profiles list)
  Future<bool> saveProfile(Profile profile) async {
    final profiles = loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      profiles[index] = profile;
      return saveProfiles(profiles);
    }
    return false;
  }
  
  /// Clear all saved data (for testing/reset)
  Future<bool> clearAll() async {
    final result1 = await _prefs.remove(_profilesKey);
    final result2 = await _prefs.remove(_activeProfileKey);
    return result1 && result2;
  }
}
