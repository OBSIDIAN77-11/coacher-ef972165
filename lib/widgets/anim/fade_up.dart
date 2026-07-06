import 'package:flutter/widgets.dart';

import '../../app/theme/tokens.dart';

/// `.fade` uit styles.css: fadeUp 0.4s cubic-bezier(0.22,1,0.36,1),
/// opacity 0→1 en translateY 14→0. Optionele [delay] voor gestaffelde items.
class FadeUp extends StatefulWidget {
  const FadeUp({super.key, this.delay = Duration.zero, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<FadeUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final CurvedAnimation _anim =
      CurvedAnimation(parent: _controller, curve: AppCurves.easeOutExpoLike);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - _anim.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
