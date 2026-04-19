import 'package:flutter/material.dart';

/// Jeu de tokens "papier froid éditorial" vs "papier sombre".
/// Les variantes light/dark sont construites côté thème via [AppPalette.of].
class AppPalette {
  const AppPalette({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.border,
    required this.borderSoft,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.accent,
    required this.accentSoft,
    required this.critique,
    required this.critiqueBg,
    required this.elevee,
    required this.eleveeBg,
    required this.moyenne,
    required this.moyenneBg,
    required this.faible,
    required this.faibleBg,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color border;
  final Color borderSoft;
  final Color ink;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color accent;
  final Color accentSoft;

  final Color critique;
  final Color critiqueBg;
  final Color elevee;
  final Color eleveeBg;
  final Color moyenne;
  final Color moyenneBg;
  final Color faible;
  final Color faibleBg;

  static const AppPalette light = AppPalette(
    background: Color(0xFFEEF0F2),
    backgroundAlt: Color(0xFFE5E8EB),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFD6DBE0),
    borderSoft: Color(0xFFE4E8EC),
    ink: Color(0xFF1C2126),
    inkSecondary: Color(0xFF6B737C),
    inkTertiary: Color(0xFF9198A0),
    accent: Color(0xFF2D4A3E),
    accentSoft: Color(0xFFDDE6E1),
    critique: Color(0xFF8B1E22),
    critiqueBg: Color(0xFFF1DCDC),
    elevee: Color(0xFFA6522A),
    eleveeBg: Color(0xFFF0DDD0),
    moyenne: Color(0xFF7A6818),
    moyenneBg: Color(0xFFEEE8CE),
    faible: Color(0xFF3F6B47),
    faibleBg: Color(0xFFDDE6DC),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0F1318),
    backgroundAlt: Color(0xFF161B21),
    surface: Color(0xFF181D23),
    border: Color(0xFF262D35),
    borderSoft: Color(0xFF1F252C),
    ink: Color(0xFFE7ECF1),
    inkSecondary: Color(0xFF8B939C),
    inkTertiary: Color(0xFF5C646D),
    accent: Color(0xFF7FB99F),
    accentSoft: Color(0xFF1F2E28),
    critique: Color(0xFFE88A8E),
    critiqueBg: Color(0xFF2E1D1E),
    elevee: Color(0xFFD89F7F),
    eleveeBg: Color(0xFF2B2018),
    moyenne: Color(0xFFD4C37A),
    moyenneBg: Color(0xFF262213),
    faible: Color(0xFF8FC49B),
    faibleBg: Color(0xFF1B2620),
  );

  /// Récupère la palette active depuis le thème.
  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPaletteExtension>()!.palette;
  }

  /// Couple (texte, fond) pour un niveau donné.
  ({Color fg, Color bg}) forLevel(String level) {
    switch (level.toUpperCase()) {
      case 'CRITIQUE':
        return (fg: critique, bg: critiqueBg);
      case 'ELEVEE':
      case 'ÉLEVÉE':
        return (fg: elevee, bg: eleveeBg);
      case 'MOYENNE':
        return (fg: moyenne, bg: moyenneBg);
      case 'FAIBLE':
      default:
        return (fg: faible, bg: faibleBg);
    }
  }
}

/// Extension ThemeData permettant de récupérer la palette via Theme.of(context).
class AppPaletteExtension extends ThemeExtension<AppPaletteExtension> {
  const AppPaletteExtension(this.palette);

  final AppPalette palette;

  @override
  AppPaletteExtension copyWith({AppPalette? palette}) {
    return AppPaletteExtension(palette ?? this.palette);
  }

  @override
  AppPaletteExtension lerp(AppPaletteExtension? other, double t) {
    // Pas d'interpolation : on bascule d'un bloc à l'autre.
    return t < 0.5 ? this : (other ?? this);
  }
}

/// Espacements / rayons / tailles standardisés.
class AppDims {
  AppDims._();

  // Espacements (échelle de 4).
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp7 = 32;
  static const double sp8 = 48;

  // Rayons.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double pill = 100;

  // Épaisseurs.
  static const double borderThin = 1;

  // Tailles minimales.
  static const double tapTarget = 44;

  // Paddings d'écran.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
}
