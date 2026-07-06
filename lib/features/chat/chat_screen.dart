import 'package:flutter/material.dart';

import '../../data/models/role.dart';
import '../../widgets/tab_placeholder.dart';

/// Placeholder — volledige port van ChatScreen.tsx volgt in fase 5.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.mode});

  final Role mode;

  @override
  Widget build(BuildContext context) {
    return TabPlaceholder(title: 'Berichten', isCoach: mode == Role.coach);
  }
}
