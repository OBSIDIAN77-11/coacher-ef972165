import 'package:flutter/widgets.dart';

/// Licht thema, identiek aan de React-app: de donkere UI wordt geïnverteerd
/// met behoud van tint (CSS `invert(100%) hue-rotate(180deg)`).
/// Media (foto's) worden met dezelfde filter nogmaals gewrapt zodat ze hun
/// natuurlijke kleuren houden — zie [MediaReInvert].
///
/// Matrix = HueRotate(180°) ∘ Invert, samengesteld tot één 5x4 kleurmatrix.
const List<double> _invertHueRotateMatrix = <double>[
  0.574, -1.430, -0.144, 0, 255,
  -0.426, -0.430, -0.144, 0, 255,
  -0.426, -1.430, 0.856, 0, 255,
  0, 0, 0, 1, 0,
];

const ColorFilter invertHueRotateFilter =
    ColorFilter.matrix(_invertHueRotateMatrix);

/// Wrap de hele app-shell hiermee wanneer het lichte thema actief is.
class LightThemeFilter extends StatelessWidget {
  const LightThemeFilter({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ColorFiltered(colorFilter: invertHueRotateFilter, child: child);
  }
}

/// Wrap foto's/afbeeldingen hiermee zodat ze in het lichte thema opnieuw
/// geïnverteerd worden en dus hun echte kleuren tonen (parity met de
/// `img { filter: ... }` regel in styles.css).
class MediaReInvert extends StatelessWidget {
  const MediaReInvert({super.key, required this.lightTheme, required this.child});

  final bool lightTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!lightTheme) return child;
    return ColorFiltered(colorFilter: invertHueRotateFilter, child: child);
  }
}
