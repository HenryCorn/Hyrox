import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nothing design system — monochrome, typographic, industrial.
///
/// Core rules:
///   • Subtract, don't add. Every element earns its pixel.
///   • OLED black (#000000) as canvas.
///   • Type does the heavy lifting — scale + weight create hierarchy.
///   • Signal red (#D71921) is used ONCE per screen as the "one break".
///   • No gradients, no blur, no shadows. Flat surfaces + borders only.
///   • Space Grotesk for UI / body. Space Mono for labels, data, timers.
class NothingTheme {
  // ── Background layers ────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceRaised = Color(0xFF1A1A1A);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFF222222);
  static const Color borderVisible = Color(0xFF333333);

  // ── Text hierarchy ───────────────────────────────────────────────────────
  static const Color textDisabled = Color(0xFF666666);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textDisplay = Color(0xFFFFFFFF);

  // ── Accent / status ──────────────────────────────────────────────────────
  /// Hyrox yellow — primary brand accent (run segments, CTAs, fills).
  static const Color accent = Color(0xFFF5C400);
  /// Signal red — reserved for high-HR alerts only.
  static const Color danger = Color(0xFFD71921);
  static const Color success = Color(0xFF4A9E5C);
  static const Color warning = Color(0xFFD4A843);
  static const Color interactive = Color(0xFF5B9BF6);

  // ── Typography ───────────────────────────────────────────────────────────
  /// Hero timer / large numbers (Space Mono, tabular).
  static TextStyle heroNumber({double fontSize = 72, Color? color}) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? textDisplay,
        letterSpacing: -1,
        height: 1.0,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Instrument label — Space Mono ALL CAPS small.
  static TextStyle label({double fontSize = 11, Color? color}) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? textSecondary,
        letterSpacing: 0.08 * (fontSize),
      );

  /// Body / UI text — Space Grotesk.
  static TextStyle body({double fontSize = 16, Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textPrimary,
        letterSpacing: 0,
      );

  /// Section heading — Space Grotesk medium.
  static TextStyle heading({double fontSize = 24, Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? textDisplay,
        letterSpacing: -0.5,
      );

  // ── Borders helpers ──────────────────────────────────────────────────────
  static Border get subtleBorder => const Border.fromBorderSide(
        BorderSide(color: borderSubtle, width: 1),
      );

  static Border get visibleBorder => const Border.fromBorderSide(
        BorderSide(color: borderVisible, width: 1),
      );

  static Border get activeBorder => const Border.fromBorderSide(
        BorderSide(color: textDisplay, width: 1),
      );

  static Border get accentBorder => const Border.fromBorderSide(
        BorderSide(color: accent, width: 1),
      );

  // ── BoxDecoration presets ────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderSubtle),
      );

  static BoxDecoration get cardRaisedDecoration => BoxDecoration(
        color: surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderVisible),
      );

  // ── MaterialApp ThemeData ─────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        surface: black,
        primary: textDisplay,
        secondary: textSecondary,
        error: danger,
        onSurface: textPrimary,
        onPrimary: black,
      ),
      scaffoldBackgroundColor: black,
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: textDisplay,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textDisplay,
          letterSpacing: 0.08 * 14,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: heroNumber(fontSize: 72),
        displayMedium: heroNumber(fontSize: 48),
        displaySmall: heroNumber(fontSize: 36),
        headlineMedium: heading(fontSize: 24),
        headlineSmall: heading(fontSize: 20),
        titleLarge: body(fontSize: 18, weight: FontWeight.w600),
        bodyLarge: body(fontSize: 16),
        bodyMedium: body(fontSize: 14),
        bodySmall: label(fontSize: 12),
        labelSmall: label(fontSize: 11),
      ),
      dividerColor: borderSubtle,
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      useMaterial3: true,
    );
  }
}
