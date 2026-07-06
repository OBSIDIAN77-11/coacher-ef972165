import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/invert_filter.dart';
import 'theme/theme_provider.dart';
import 'theme/tokens.dart';

class CoacherApp extends ConsumerWidget {
  const CoacherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Coacher — Personal Training',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      builder: (context, child) {
        // Zelfde framing als .app-shell in styles.css: max 430px breed,
        // gecentreerd op een achtergrond. Op mobiel is het scherm smaller
        // dan 430px, dus daar heeft dit geen effect.
        Widget app = LightThemeFilter(
          enabled: theme == CoacherTheme.light,
          child: ClipRect(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child!,
            ),
          ),
        );
        return ColoredBox(
          color: theme == CoacherTheme.light
              ? const Color(0xFFF3F4F6)
              : AppColors.bg,
          child: Center(child: app),
        );
      },
    );
  }
}
