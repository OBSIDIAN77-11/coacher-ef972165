import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import 'anim/spinner.dart';

enum ButtonVariant { primary, outline, ghost, muted, danger }

enum ButtonSize { sm, md, lg }

/// Port van archive/src/components/coacher/Button.tsx.
class CoacherButton extends StatelessWidget {
  const CoacherButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool fullWidth;

  bool get _disabled => onPressed == null || loading;

  @override
  Widget build(BuildContext context) {
    final (padding, fontSize, radius) = switch (size) {
      ButtonSize.sm => (
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          12.0,
          12.0
        ),
      ButtonSize.md => (
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          13.0,
          14.0
        ),
      ButtonSize.lg => (
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          15.0,
          16.0
        ),
    };

    final (Gradient? gradient, Color? bg, Color fg, BoxBorder? border,
        List<BoxShadow> shadows) = switch (variant) {
      ButtonVariant.primary => (
          AppGradients.primary,
          null,
          Colors.white,
          null,
          const [AppShadows.glowStrong]
        ),
      ButtonVariant.outline => (
          null,
          Colors.transparent,
          AppColors.textP,
          Border.all(color: AppColors.borderHover, width: 1.5),
          const <BoxShadow>[]
        ),
      ButtonVariant.ghost => (
          null,
          AppColors.primarySoft,
          AppColors.primary,
          null,
          const <BoxShadow>[]
        ),
      ButtonVariant.muted => (
          null,
          AppColors.card,
          AppColors.textS,
          Border.all(color: AppColors.border, width: 1),
          const <BoxShadow>[]
        ),
      ButtonVariant.danger => (
          null,
          const Color(0x1FFF4D6A),
          AppColors.red,
          null,
          const <BoxShadow>[]
        ),
    };

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: fg,
      height: 1.4,
    );

    Widget content = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spinner(color: fg),
              const SizedBox(width: 8),
              Text('Bezig…', style: textStyle),
            ],
          )
        : DefaultTextStyle.merge(
            style: textStyle,
            textAlign: TextAlign.center,
            child: IconTheme.merge(
              data: IconThemeData(color: fg, size: fontSize + 4),
              child: child,
            ),
          );

    return Opacity(
      opacity: _disabled && !loading ? 0.4 : 1,
      child: GestureDetector(
        onTap: _disabled ? null : onPressed,
        child: MouseRegion(
          cursor: _disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: fullWidth ? double.infinity : null,
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: bg,
              border: border,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadows,
            ),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }
}
