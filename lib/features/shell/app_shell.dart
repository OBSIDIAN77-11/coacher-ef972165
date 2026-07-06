import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../data/models/role.dart';

/// Placeholder — wordt in fase 3 vervangen door de volledige port van
/// AppShell.tsx (glass topbar, rol-toggle, bottom-nav met 5 tabs per rol).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.initialMode,
    required this.onLogout,
  });

  final Role initialMode;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'App (${initialMode.name}) — komt in fase 3',
              style: const TextStyle(color: AppColors.textS),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onLogout,
              child: const Text('Uitloggen',
                  style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
