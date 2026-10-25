
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'user_theme_brightness';
  ThemeCubit() : super(const ThemeState(brightness: Brightness.light)) {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        final Brightness loadedBrightness =
            savedTheme == 'dark' ? Brightness.dark : Brightness.light;
        
        emit(ThemeState(brightness: loadedBrightness));
      }
    } catch(e) {
      debugPrint('Error $e');
    }
  }

  Future<void> setThemeBrightness(Brightness brightness) async {
    emit(ThemeState(brightness: brightness)); 

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeKey,
        brightness == Brightness.dark ? 'dark' : 'light',
      );
    } catch (e) {
      debugPrint('Ошибка сохранения темы: $e');
    }
  }
}