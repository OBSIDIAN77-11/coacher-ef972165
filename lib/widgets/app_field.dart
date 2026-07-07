import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Port van archive/src/components/coacher/Field.tsx.

class AppLabel extends StatelessWidget {
  const AppLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textS,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

InputDecoration _decoration({String? hint, bool error = false}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: 1.5),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppColors.textS,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    enabledBorder: border(error ? AppColors.red : AppColors.border),
    focusedBorder: border(error ? AppColors.red : AppColors.primary),
    errorBorder: border(AppColors.red),
    focusedErrorBorder: border(AppColors.red),
  );
}

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    this.controller,
    this.hint,
    this.error = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool error;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool enabled;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    // Focus-glow uit de bron: 0 0 0 3px rgba(37,99,235,0.12).
    return Focus(
      onFocusChange: (has) => setState(() => _focused = has),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: _focused && !widget.error
              ? const [
                  BoxShadow(
                    color: Color(0x1F2563EB),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          maxLines: widget.maxLines,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            color: AppColors.textP,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: _decoration(hint: widget.hint, error: widget.error),
        ),
      ),
    );
  }
}

class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.error = false,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: AppColors.surface,
      // Chevron-kleur exact uit de bron-SVG (#8BA89D).
      icon: const Icon(Icons.keyboard_arrow_down,
          color: Color(0xFF8BA89D), size: 20),
      style: const TextStyle(
        color: AppColors.textP,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: _decoration(hint: hint, error: error),
    );
  }
}

class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message!,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.red,
        ),
      ),
    );
  }
}
