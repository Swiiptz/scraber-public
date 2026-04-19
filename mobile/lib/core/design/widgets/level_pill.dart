import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Pill de niveau (CRITIQUE / ELEVEE / MOYENNE / FAIBLE).
/// Arrondie, fond pâle + texte coloré selon la palette.
class LevelPill extends StatelessWidget {
  const LevelPill(this.level, {super.key, this.dense = false});

  final String level;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final colors = palette.forLevel(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 11,
        vertical: dense ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppDims.pill),
      ),
      child: Text(
        _label(level),
        style: AppText.pillLevel(colors.fg),
      ),
    );
  }

  String _label(String level) {
    switch (level.toUpperCase()) {
      case 'CRITIQUE':
        return 'CRITIQUE';
      case 'ELEVEE':
      case 'ÉLEVÉE':
        return 'ÉLEVÉE';
      case 'MOYENNE':
        return 'MOYENNE';
      case 'FAIBLE':
        return 'FAIBLE';
      default:
        return level.toUpperCase();
    }
  }
}
