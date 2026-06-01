import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/theme_palette.dart';

class ThemeProvider extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';

  bool _isDark = true;

  bool get isDark => _isDark;
  ThemePalette get palette => _isDark ? ThemePalette.dark : ThemePalette.light;

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeMode);
    _isDark = stored != 'light';
    AppColors.palette = palette;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    AppColors.palette = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, _isDark ? 'dark' : 'light');
  }

  Future<void> setDark(bool dark) async {
    if (_isDark == dark) return;
    _isDark = dark;
    AppColors.palette = palette;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, _isDark ? 'dark' : 'light');
  }
}
