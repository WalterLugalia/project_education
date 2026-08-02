import 'package:flutter/material.dart';

/// Learnly — App Color Palette
/// Dark-first design with deep navy backgrounds and indigo/violet accents.
class AppColors {
  AppColors._(); // prevent instantiation

  // ─── Backgrounds ────────────────────────────────────────────────────────────

  /// Deep navy — primary screen background (#0B0F1E)
  static const Color backgroundColor = Color(0xFF0B0F1E);

  /// Card / list-item surface (#141929)
  static const Color surfaceColor = Color(0xFF141929);

  /// Elevated surface — modals, drawers, bottom sheets (#1C2338)
  static const Color surfaceElevatedColor = Color(0xFF1C2338);

  /// Mid surface — section headers, input fields (#172033)
  static const Color surfaceMidColor = Color(0xFF172033);

  /// Deep surface — overlay tint, pressed states (#242D47)
  static const Color surfaceDeepColor = Color(0xFF242D47);

  /// Dark surface variant (#28314D)
  static const Color surfaceDarkColor = Color(0xFF28314D);

  // ─── Brand / Accent ─────────────────────────────────────────────────────────

  /// Primary accent — indigo-blue (#5B6CF5)
  static const Color primaryColor = Color(0xFF5B6CF5);

  /// Primary light — lighter indigo for hover/pressed (#7B8AFF)
  static const Color primaryLightColor = Color(0xFF7B8AFF);

  /// Secondary accent — soft violet (#A78BFA)
  static const Color secondaryColor = Color(0xFFA78BFA);

  // ─── Text ───────────────────────────────────────────────────────────────────

  /// Primary text — near-white with cool tint (#F0F4FF)
  static const Color textPrimaryColor = Color(0xFFF0F4FF);

  /// Body text — comfortable reading tone (#C8D0E8)
  static const Color textBodyColor = Color(0xFFC8D0E8);

  /// Secondary text — slate blue-gray (#8892B0)
  static const Color textSecondaryColor = Color(0xFF8892B0);

  /// Tertiary text — muted labels, placeholders (#4A5568)
  static const Color textTertiaryColor = Color(0xFF4A5568);

  // ─── Status ─────────────────────────────────────────────────────────────────

  /// Success / available-offline indicator — emerald (#34D399)
  static const Color successColor = Color(0xFF34D399);

  /// Warning / streak badge — amber (#FBBF24)
  static const Color warningColor = Color(0xFFFBBF24);

  /// Error / danger — soft red (#F87171)
  static const Color errorColor = Color(0xFFF87171);

  // ─── Miscellaneous Accents ───────────────────────────────────────────────────

  /// Google brand blue — social login button (#4285F4)
  static const Color googleBlue = Color(0xFF4285F4);

  /// Pink accent — category badge, design tag (#F472B6)
  static const Color pinkAccent = Color(0xFFF472B6);

  /// Light amber — highlight / pull-quote tint (#F6E5A8)
  static const Color lightAmber = Color(0xFFF6E5A8);

  // ─── Borders & Dividers (with alpha) ─────────────────────────────────────────

  /// Subtle border — card outlines (rgba(255,255,255, 0.06))
  static const Color borderSubtle = Color(0x0FFFFFFF);

  /// Default border (rgba(255,255,255, 0.07))
  static const Color borderDefault = Color(0x12FFFFFF);

  /// Input border (rgba(255,255,255, 0.08))
  static const Color borderInput = Color(0x14FFFFFF);

  // ─── Overlays & Shadows (with alpha) ─────────────────────────────────────────

  /// Primary tint overlay 10% — chip backgrounds (rgba(91,108,245, 0.10))
  static const Color primaryOverlay10 = Color(0x1A5B6CF5);

  /// Primary tint overlay 18% — focused states (rgba(91,108,245, 0.18))
  static const Color primaryOverlay18 = Color(0x2E5B6CF5);

  /// Primary tint overlay 22% — active backgrounds (rgba(91,108,245, 0.22))
  static const Color primaryOverlay22 = Color(0x385B6CF5);

  /// Primary glow 34% — orb / bloom effect (rgba(91,108,245, 0.34))
  static const Color primaryGlow = Color(0x575B6CF5);

  /// Secondary tint 12% — ambient glow (rgba(167,139,250, 0.12))
  static const Color secondaryOverlay12 = Color(0x1FA78BFA);

  /// Dark overlay 22% — image scrim light (rgba(0,0,0, 0.22))
  static const Color overlayLight = Color(0x38000000);

  /// Dark overlay 35% — image scrim medium (rgba(0,0,0, 0.35))
  static const Color overlayMedium = Color(0x59000000);

  /// Dark overlay 40% — card shadow (rgba(0,0,0, 0.40))
  static const Color overlayDark = Color(0x66000000);

  /// Dark overlay 50% — modal backdrop (rgba(0,0,0, 0.50))
  static const Color overlayHeavy = Color(0x80000000);

  // ─── Gradient Helpers ────────────────────────────────────────────────────────

  /// Primary gradient — indigo → violet (used on buttons, progress bars, logo)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  /// Radial glow — used for splash orb / background bloom
  static const RadialGradient splashGlow = RadialGradient(
    colors: [primaryGlow, secondaryOverlay12, Colors.transparent],
    stops: [0.0, 0.4, 0.72],
  );

  // ─── Box Shadow Presets ───────────────────────────────────────────────────────

  /// Standard card elevation shadow
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: overlayDark,
          blurRadius: 24,
          offset: Offset(0, 4),
        ),
      ];

  /// Glow shadow — used on logo / featured cards
  static List<BoxShadow> get primaryGlowShadow => const [
        BoxShadow(
          color: primaryOverlay22,
          blurRadius: 80,
          spreadRadius: 0,
        ),
      ];
}