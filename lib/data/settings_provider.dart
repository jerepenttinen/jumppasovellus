import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider = Provider<Settings>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return Settings(sharedPreferences: sharedPrefs);
});

class Settings {
  Settings({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  ThemeMode getThemeMode() {
    final mode = sharedPreferences.getInt('themeMode');
    if (mode == null) {
      return ThemeMode.system;
    }

    if (mode >= ThemeMode.values.length || mode < 0) {
      setThemeMode(themeMode: ThemeMode.system);
      return ThemeMode.system;
    }

    return ThemeMode.values[mode];
  }

  void setThemeMode({required ThemeMode themeMode}) {
    sharedPreferences.setInt('themeMode', themeMode.index);
  }

  Locale getLocale() {
    final l = sharedPreferences.getInt('locale');
    if (l == null) {
      return Locale(Platform.localeName);
    }

    if (l >= SupportedLocale.values.length || l < 0) {
      setLocale(SupportedLocale.system);
      return Locale(Platform.localeName);
    }

    if (l == SupportedLocale.finnish.index) {
      return const Locale('fi');
    }
    return Locale(Platform.localeName);
  }

  void setLocale(SupportedLocale l) {
    sharedPreferences.setInt('locale', l.index);
  }

  int getDefaultRepCount() {
    final repCount = sharedPreferences.getInt('defaultRepCount');
    if (repCount == null) {
      return 10;
    }

    if (repCount > 30 || repCount < 0) {
      setDefaultRepCount(10);
      return 10;
    }

    return repCount;
  }

  void setDefaultRepCount(int repCount) {
    sharedPreferences.setInt('defaultRepCount', repCount);
  }
}

enum SupportedLocale { system, finnish }

Locale get getSystemLocale => Locale(Platform.localeName);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref: ref),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier({required this.ref}) : super(ThemeMode.system) {
    state = ref.read(settingsProvider).getThemeMode();
  }

  final Ref ref;

  void setThemeMode(ThemeMode themeMode) {
    ref.read(settingsProvider).setThemeMode(themeMode: themeMode);
    state = ref.read(settingsProvider).getThemeMode();
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref: ref),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier({required this.ref}) : super(getSystemLocale) {
    state = ref.read(settingsProvider).getLocale();
  }

  final Ref ref;

  void setLocale(SupportedLocale locale) {
    ref.read(settingsProvider).setLocale(locale);
    state = ref.read(settingsProvider).getLocale();
  }
}

final defaultRepCountProvider =
    StateNotifierProvider<DefaultRepCountNotifier, int>(
  (ref) => DefaultRepCountNotifier(ref: ref),
);

class DefaultRepCountNotifier extends StateNotifier<int> {
  DefaultRepCountNotifier({required this.ref}) : super(10) {
    state = ref.read(settingsProvider).getDefaultRepCount();
  }

  final Ref ref;

  void setDefaultRepCount(int repCount) {
    ref.read(settingsProvider).setDefaultRepCount(repCount);
    state = ref.read(settingsProvider).getDefaultRepCount();
  }
}