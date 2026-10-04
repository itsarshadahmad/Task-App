import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool useDynamicColors;
  final bool enableNotifications;
  final bool enableHaptics;
  final bool enableCloudSync;
  final bool autoSync;
  final bool enableEncryption;
  final bool enableVoiceInput;
  final String language;
  final String timezone;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.useDynamicColors = true,
    this.enableNotifications = true,
    this.enableHaptics = true,
    this.enableCloudSync = true,
    this.autoSync = true,
    this.enableEncryption = true,
    this.enableVoiceInput = true,
    this.language = 'en',
    this.timezone = 'UTC',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? useDynamicColors,
    bool? enableNotifications,
    bool? enableHaptics,
    bool? enableCloudSync,
    bool? autoSync,
    bool? enableEncryption,
    bool? enableVoiceInput,
    String? language,
    String? timezone,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableCloudSync: enableCloudSync ?? this.enableCloudSync,
      autoSync: autoSync ?? this.autoSync,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'useDynamicColors': useDynamicColors,
    'enableNotifications': enableNotifications,
    'enableHaptics': enableHaptics,
    'enableCloudSync': enableCloudSync,
    'autoSync': autoSync,
    'enableEncryption': enableEncryption,
    'enableVoiceInput': enableVoiceInput,
    'language': language,
    'timezone': timezone,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
    themeMode: ThemeMode.values[json['themeMode'] as int? ?? 2],
    useDynamicColors: json['useDynamicColors'] as bool? ?? true,
    enableNotifications: json['enableNotifications'] as bool? ?? true,
    enableHaptics: json['enableHaptics'] as bool? ?? true,
    enableCloudSync: json['enableCloudSync'] as bool? ?? true,
    autoSync: json['autoSync'] as bool? ?? true,
    enableEncryption: json['enableEncryption'] as bool? ?? true,
    enableVoiceInput: json['enableVoiceInput'] as bool? ?? true,
    language: json['language'] as String? ?? 'en',
    timezone: json['timezone'] as String? ?? 'UTC',
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  SettingsNotifier({required this.prefs}) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final json = prefs.getString(AppConstants.storageThemeKey);
    if (json != null) {
      state = SettingsState.fromJson({
        ...state.toJson(),
        ...prefs.getString(AppConstants.storageThemeKey) as Map<String, dynamic>? ?? {},
      });
    }
    
    // Load individual settings
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex != null) {
      state = state.copyWith(themeMode: ThemeMode.values[themeIndex]);
    }
  }

  Future<void> saveSettings() async {
    await prefs.setString(AppConstants.storageThemeKey, state.toJson().toString());
    await prefs.setInt('theme_mode', state.themeMode.index);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    saveSettings();
  }

  void setUseDynamicColors(bool value) {
    state = state.copyWith(useDynamicColors: value);
    saveSettings();
  }

  void setEnableNotifications(bool value) {
    state = state.copyWith(enableNotifications: value);
    saveSettings();
  }

  void setEnableHaptics(bool value) {
    state = state.copyWith(enableHaptics: value);
    saveSettings();
  }

  void setEnableCloudSync(bool value) {
    state = state.copyWith(enableCloudSync: value);
    saveSettings();
  }

  void setAutoSync(bool value) {
    state = state.copyWith(autoSync: value);
    saveSettings();
  }

  void setEnableEncryption(bool value) {
    state = state.copyWith(enableEncryption: value);
    saveSettings();
  }

  void setEnableVoiceInput(bool value) {
    state = state.copyWith(enableVoiceInput: value);
    saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsNotifier(prefs: prefs);
});
