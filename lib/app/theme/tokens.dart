import 'package:flutter/widgets.dart';

/// Design tokens, 1:1 overgenomen uit archive/src/styles.css.
abstract final class AppColors {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0F1525);
  static const card = Color(0xFF000000);

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFF60A5FA);

  static const textP = Color(0xFFFFFFFF);
  static const textS = Color(0xFF8B98B0);
  static const textM = Color(0xFF4A5A75);

  static const border = Color(0xFF1E2A44);
  static const borderHover = Color(0xFF2A3B5C);

  static const red = Color(0xFFFF4D6A);
  static const orange = Color(0xFFFF8C42);
  static const yellow = Color(0xFFFFD166);
  static const cyan = Color(0xFF5EEAD4);
  static const purple = Color(0xFF8B5CF6);

  /// rgba(37,99,235,0.1)
  static const primarySoft = Color(0x1A2563EB);

  /// rgba(96,165,250,0.08)
  static const accentSoft = Color(0x1460A5FA);
}

abstract final class AppGradients {
  /// linear-gradient(135deg, #2563EB, #60A5FA)
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accent],
  );

  static const soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primarySoft, AppColors.accentSoft],
  );
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 28.0;
}

abstract final class AppShadows {
  /// 0 4px 20px rgba(37,99,235,0.18)
  static const glow = BoxShadow(
    color: Color(0x2E2563EB),
    offset: Offset(0, 4),
    blurRadius: 20,
  );

  /// 0 4px 20px rgba(37,99,235,0.30) — primary buttons
  static const glowStrong = BoxShadow(
    color: Color(0x4D2563EB),
    offset: Offset(0, 4),
    blurRadius: 20,
  );

  /// 0 0 40px rgba(37,99,235,0.4) — logo
  static const logoGlow = BoxShadow(
    color: Color(0x662563EB),
    blurRadius: 40,
  );
}

abstract final class AppCurves {
  /// cubic-bezier(0.22, 1, 0.36, 1) — gebruikt voor fadeUp/slideUp
  static const easeOutExpoLike = Cubic(0.22, 1, 0.36, 1);
}
