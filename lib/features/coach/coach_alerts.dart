import 'package:flutter/material.dart';

import '../../widgets/tab_placeholder.dart';

/// Placeholder — volledige port van CoachAlerts.tsx volgt in fase 5.
class CoachAlerts extends StatelessWidget {
  const CoachAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'Meldingen', isCoach: true);
  }
}
