import 'package:flutter/material.dart';
import 'constants.dart';

class AppColors {
  static const Color bg = Color(0xFF0A0F24);
  static const Color surface = Color(0xFF121A33);
  static const Color surfaceHigh = Color(0xFF1B2547);
  static const Color primary = Color(0xFF00D1FF);
  static const Color live = Color(0xFFFF3B5C);
  static const Color upcoming = Color(0xFFFFB020);
  static const Color completed = Color(0xFF2ECC71);
  static const Color muted = Color(0xFF8D9AC2);

  static Color statusColor(String s) {
    switch (s) {
      case MatchStatus.live:
        return live;
      case MatchStatus.completed:
        return completed;
      default:
        return upcoming;
    }
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(primary: AppColors.primary, surface: AppColors.surface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.2),
    ),
  );
}
