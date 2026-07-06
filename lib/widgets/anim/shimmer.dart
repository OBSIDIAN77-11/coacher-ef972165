import 'package:flutter/widgets.dart';

import '../../app/theme/tokens.dart';

/// `.shimmer`: lopende lichtband, 1.4s linear infinite.
/// Gebruikt voor de laadbalk op het splash-scherm.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final dx = (2 - 4 * _controller.value) * bounds.width;
            return LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0),
                AppColors.primary.withValues(alpha: 0.6),
                AppColors.primary.withValues(alpha: 0),
              ],
            ).createShader(bounds.shift(Offset(dx, 0)));
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
