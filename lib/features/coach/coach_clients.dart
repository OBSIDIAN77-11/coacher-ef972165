import 'package:flutter/material.dart';

import '../../widgets/tab_placeholder.dart';

/// Placeholder — volledige port van CoachClients.tsx volgt in fase 4.
class CoachClients extends StatelessWidget {
  const CoachClients({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'Cliënten', isCoach: true);
  }
}
