import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/shimmer.dart';
import '../../widgets/logo.dart';
import '../../widgets/shell.dart';

/// Port van Splash.tsx: zwevend logo + shimmerende laadbalk, na 2.2s door.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      scrollable: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CoacherLogo(float: true),
            const SizedBox(height: 48),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Shimmer(
                child: Container(
                  width: 120,
                  height: 2,
                  color: AppColors.border,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
