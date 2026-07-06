import 'package:flutter/widgets.dart';

/// `.dot-pulse`: softPulse 1.6s ease-in-out infinite, opacity 1 → 0.3 → 1.
class SoftPulse extends StatefulWidget {
  const SoftPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SoftPulse> createState() => _SoftPulseState();
}

class _SoftPulseState extends State<SoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = Tween(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    return FadeTransition(opacity: anim, child: widget.child);
  }
}
