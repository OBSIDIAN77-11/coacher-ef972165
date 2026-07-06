import 'package:flutter/material.dart';

import '../../widgets/tab_placeholder.dart';

/// Placeholder — volledige port van KlantVoortgang.tsx volgt in fase 4.
class KlantVoortgang extends StatelessWidget {
  const KlantVoortgang({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(title: 'Voortgang', isCoach: false);
  }
}
