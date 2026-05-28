import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType {
  light,
  dark,
  system,
}

// Make ThemeState extend Equatable for better performance
class ThemeState {
  final ThemeModeType mode;
  
  const ThemeState({required this.mode});
  
  ThemeState copyWith({ThemeModeType? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
  
  static const initial = ThemeState(mode: ThemeModeType.system);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && other.mode == mode;
  }
  
  @override
  int get hashCode => mode.hashCode;
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themePrefKey = 'theme_mode';
  
  ThemeNotifier() : super(ThemeState.initial) {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themePrefKey);
    
    if (savedMode != null) {
      final mode = ThemeModeType.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeModeType.system,
      );
      state = ThemeState(mode: mode);
    }
  }
  
  Future<void> setThemeMode(ThemeModeType mode) async {
    if (state.mode == mode) return; // Don't update if same
    
    state = state.copyWith(mode: mode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.toString());
  }
  
  ThemeMode getCurrentThemeMode() {
    switch (state.mode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Provider that returns the actual ThemeMode for the app
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeProvider);
  switch (themeState.mode) {
    case ThemeModeType.light:
      return ThemeMode.light;
    case ThemeModeType.dark:
      return ThemeMode.dark;
    case ThemeModeType.system:
      return ThemeMode.system;
  }
});