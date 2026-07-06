import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Zelfde persistente sleutel als de React-app (localStorage "coacher-theme").
const _themeKey = 'coacher-theme';

enum CoacherTheme { dark, light }

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main()'),
);

class ThemeNotifier extends Notifier<CoacherTheme> {
  @override
  CoacherTheme build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_themeKey);
    return stored == 'light' ? CoacherTheme.light : CoacherTheme.dark;
  }

  void set(CoacherTheme theme) {
    state = theme;
    ref
        .read(sharedPreferencesProvider)
        .setString(_themeKey, theme == CoacherTheme.light ? 'light' : 'dark');
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, CoacherTheme>(ThemeNotifier.new);
