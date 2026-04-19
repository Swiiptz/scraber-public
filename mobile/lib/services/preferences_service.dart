import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Niveaux autorisés (ordre de sévérité décroissante).
const List<String> kLevels = <String>['CRITIQUE', 'ELEVEE', 'MOYENNE', 'FAIBLE'];

/// Préférences persistées (Hive box `settings`).
class AppPreferences {
  const AppPreferences({
    required this.threshold,
    required this.themeMode,
    required this.quietHours,
  });

  final String threshold;
  final ThemeMode themeMode;
  final bool quietHours;

  AppPreferences copyWith({
    String? threshold,
    ThemeMode? themeMode,
    bool? quietHours,
  }) {
    return AppPreferences(
      threshold: threshold ?? this.threshold,
      themeMode: themeMode ?? this.themeMode,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, AppPreferences>((ref) {
  return PreferencesController(Hive.box('settings'));
});

class PreferencesController extends StateNotifier<AppPreferences> {
  PreferencesController(this._box) : super(_load(_box));

  final Box _box;

  static AppPreferences _load(Box box) {
    return AppPreferences(
      threshold: (box.get('threshold') as String?) ?? 'ELEVEE',
      themeMode: _parseTheme(box.get('themeMode') as String?),
      quietHours: (box.get('quietHours') as bool?) ?? true,
    );
  }

  static ThemeMode _parseTheme(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _serializeTheme(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  Future<void> setThreshold(String level) async {
    await _box.put('threshold', level);
    state = state.copyWith(threshold: level);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put('themeMode', _serializeTheme(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setQuietHours(bool enabled) async {
    await _box.put('quietHours', enabled);
    state = state.copyWith(quietHours: enabled);
  }
}

/// Topic FCM a abonner en fonction du seuil choisi.
/// Le scraper publie deja sur tous les topics couverts par le niveau d'un item.
List<String> topicsForThreshold(String threshold) {
  final idx = kLevels.indexOf(_normalizeLevel(threshold));
  final level = idx < 0 ? 'CRITIQUE' : kLevels[idx];
  return ['level-${level.toLowerCase()}'];
}

String _normalizeLevel(String level) {
  return switch (level.toUpperCase()) {
    'ÉLEVÉE' => 'ELEVEE',
    _ => level.toUpperCase(),
  };
}
