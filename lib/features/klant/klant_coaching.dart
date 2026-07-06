import 'package:flutter/material.dart';

import '../../widgets/tab_placeholder.dart';

/// Placeholder — volledige port van KlantCoaching.tsx volgt in fase 5.
class KlantCoaching extends StatelessWidget {
  const KlantCoaching({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'Coaching', isCoach: false);
  }
}
