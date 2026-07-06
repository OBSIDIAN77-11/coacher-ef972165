import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Port van archive/src/components/coacher/Shell.tsx —
/// zwart vlak, verticale flex met padding 24px horizontaal / 32px verticaal.
/// De ambient glow is in het donkere thema verborgen (styles.css), en in het
/// lichte thema zichtbaar via de invert-filter; hier tekenen we hem altijd
/// zwak zoals de bron dat via de filterlaag doet.
class Shell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
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
    );
  }
}
