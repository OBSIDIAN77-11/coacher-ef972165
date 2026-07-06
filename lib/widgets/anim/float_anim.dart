import 'package:flutter/widgets.dart';

/// `.float`: 3s ease-in-out infinite, translateY 0 → -10 → 0.
class FloatAnim extends StatefulWidget {
  const FloatAnim({super.key, required this.child});

  final Widget child;

  @override
  State<FloatAnim> createState() => _FloatAnimState();
}

class _FloatAnimState extends State<FloatAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, -10 * anim.value), child: child),
      child: widget.child,
    );
  }
}
