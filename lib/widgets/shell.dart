import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/theme_provider.dart';
import '../app/theme/tokens.dart';

/// Port van archive/src/components/coacher/Shell.tsx —
/// zwart vlak, verticale flex met padding 24px horizontaal / 32px verticaal.
/// De ambient glow (radiale gloed boven, 500x500, 12% blauw) is alleen
/// zichtbaar in het lichte thema — styles.css verbergt hem in dark mode.
class Shell extends ConsumerWidget {
  const Shell({
    super.key,
    required this.child,
    this.glow = true,
    this.scrollable = true,
  });

  final Widget child;
  final bool glow;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(themeProvider) == CoacherTheme.light;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          if (glow && light)
            Positioned(
              top: -120,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0x1F2563EB), Color(0x002563EB)],
                        stops: [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: scrollable
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(child: content),
                      ),
                    ),
                  )
                : content,
          ),
        ],
      ),
    );
  }
}
