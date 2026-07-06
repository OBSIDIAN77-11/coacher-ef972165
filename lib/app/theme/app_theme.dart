import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSurface: AppColors.textP,
    ),
    dividerColor: AppColors.border,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textP,
    displayColor: AppColors.textP,
  );

  return base.copyWith(
    textTheme: textTheme,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      // De sheets stylen zichzelf (radius 28, border, pull-handle).
    ),
  );
}
