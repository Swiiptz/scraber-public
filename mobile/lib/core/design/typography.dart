import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Styles de texte du système Scraber.
///
/// Trois familles :
/// - Roboto Slab (titres éditoriaux)
/// - Inter (corps, UI)
/// - JetBrains Mono (data, labels tracké, №edition)
class AppText {
  AppText._();

  // === Titres slab ===
  static TextStyle slab32(Color c) => GoogleFonts.robotoSlab(
        color: c,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        height: 1.05,
      );

  static TextStyle slab26(Color c) => GoogleFonts.robotoSlab(
        color: c,
        fontSize: 26,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.4,
        height: 1.12,
      );

  static TextStyle slab24(Color c) => GoogleFonts.robotoSlab(
        color: c,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        height: 1.15,
      );

  static TextStyle slab22(Color c) => GoogleFonts.robotoSlab(
        color: c,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.18,
      );

  static TextStyle slab17(Color c) => GoogleFonts.robotoSlab(
        color: c,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        height: 1.28,
      );

  // === Corps Inter ===
  static TextStyle body(Color c) => GoogleFonts.inter(
        color: c,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodySmall(Color c) => GoogleFonts.inter(
        color: c,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle button(Color c) => GoogleFonts.inter(
        color: c,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // === Labels & pills ===
  static TextStyle pillLevel(Color c) => GoogleFonts.inter(
        color: c,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  static TextStyle pillType(Color c) => GoogleFonts.inter(
        color: c,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // === Mono JetBrains ===
  static TextStyle monoLabel(Color c) => GoogleFonts.jetBrainsMono(
        color: c,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      );

  static TextStyle monoLabelSm(Color c) => GoogleFonts.jetBrainsMono(
        color: c,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      );

  static TextStyle monoData(Color c) => GoogleFonts.jetBrainsMono(
        color: c,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  static TextStyle monoEdition(Color c) => GoogleFonts.jetBrainsMono(
        color: c,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  static TextStyle monoTag(Color c) => GoogleFonts.jetBrainsMono(
        color: c,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );

  /// Construit le [TextTheme] Material à partir de la palette.
  static TextTheme textTheme(AppPalette p) {
    return TextTheme(
      displayLarge: slab32(p.ink),
      displayMedium: slab26(p.ink),
      displaySmall: slab24(p.ink),
      headlineMedium: slab22(p.ink),
      titleLarge: slab17(p.ink),
      bodyLarge: body(p.ink),
      bodyMedium: body(p.ink),
      bodySmall: bodySmall(p.inkSecondary),
      labelLarge: button(p.ink),
      labelMedium: monoLabel(p.inkTertiary),
      labelSmall: monoLabelSm(p.inkTertiary),
    );
  }
}
